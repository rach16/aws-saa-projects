#!/usr/bin/env bash
#
# S0 cost sweeper. Answers one question across every enabled region: is
# anything still billing?
#
# Describe calls only. This never deletes anything, because a tool that can
# delete is a tool you hesitate to run, and the point is to run it without
# thinking at the end of every session.
#
# Deliberately no 'set -e'. If eu-west-3 fails, the other sixteen regions still
# need checking, so failures are caught per call and reported loudly instead of
# ending the run.

set -uo pipefail

PROFILE="${SWEEP_PROFILE:-saa}"
FINDINGS=0
FAILURES=0
REGIONS_CHECKED=0
REGION_HAD_OUTPUT=0

# Run one describe call and report it.
#
# The trust property of this whole script lives here. A call that returns
# nothing and a call that failed both print nothing, so they have to be told
# apart by exit code or the sweeper can quietly stop working and still look
# clean.
check() {
  local label="$1"
  shift
  local out rc

  # Assign first, read $? second. Writing 'local out=$(...)' would capture the
  # exit code of 'local', not of the command, which is how this check silently
  # stops working.
  out=$("$@" 2>&1)
  rc=$?

  if [ "$rc" -ne 0 ]; then
    echo "   !! ${label}: call failed, exit ${rc}"
    echo "$out" | head -2 | sed 's/^/      /'
    FAILURES=$((FAILURES + 1))
    REGION_HAD_OUTPUT=1
    return
  fi

  # A JMESPath query that matches nothing prints the literal string "None"
  # under --output text rather than an empty line. Both mean the same thing.
  if [ -z "$out" ] || [ "$out" = "None" ]; then
    return
  fi

  echo "   ${label}"
  echo "$out" | sed 's/^/      /'
  FINDINGS=$((FINDINGS + 1))
  REGION_HAD_OUTPUT=1
}

# Customer managed KMS keys bill monthly. AWS managed keys do not, and
# list-keys returns both without saying which is which, so every key needs a
# second call to find out. This is the slow one.
kms_customer_keys() {
  local region="$1" ids id mgr out=""
  ids=$(aws kms list-keys --profile "$PROFILE" --region "$region" \
          --query 'Keys[].KeyId' --output text) || return 1
  for id in $ids; do
    mgr=$(aws kms describe-key --profile "$PROFILE" --region "$region" \
            --key-id "$id" --query 'KeyMetadata.KeyManager' --output text) || return 1
    if [ "$mgr" = "CUSTOMER" ]; then
      out="${out}${id}"$'\n'
    fi
  done
  printf '%s' "$out"
}

REGIONS=$(aws ec2 describe-regions --profile "$PROFILE" \
            --query 'Regions[].RegionName' --output text) || {
  echo "Could not list regions. Is the '${PROFILE}' profile set up?" >&2
  exit 1
}

echo "Sweeping with profile '${PROFILE}'."
echo

for REGION in $REGIONS; do
  REGION_HAD_OUTPUT=0
  REGIONS_CHECKED=$((REGIONS_CHECKED + 1))
  echo "== ${REGION}"

  check "EC2 instances" \
    aws ec2 describe-instances --profile "$PROFILE" --region "$REGION" \
      --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]' \
      --output text

  # Stopped instances are free themselves but keep their EBS volumes, which
  # are not, so the volume check below is the one that catches them.
  check "EBS volumes (available = unattached, still billing)" \
    aws ec2 describe-volumes --profile "$PROFILE" --region "$REGION" \
      --query 'Volumes[].[VolumeId,Size,State]' --output text

  # describe-nat-gateways takes --filter, singular, unlike almost every other
  # EC2 call. Deleted gateways linger in the API for hours, so filtering by
  # state keeps them out of the report.
  check "NAT gateways" \
    aws ec2 describe-nat-gateways --profile "$PROFILE" --region "$REGION" \
      --filter Name=state,Values=available,pending \
      --query 'NatGateways[].[NatGatewayId,State]' --output text

  check "Load balancers (ALB/NLB)" \
    aws elbv2 describe-load-balancers --profile "$PROFILE" --region "$REGION" \
      --query 'LoadBalancers[].[LoadBalancerName,Type,State.Code]' --output text

  check "RDS instances" \
    aws rds describe-db-instances --profile "$PROFILE" --region "$REGION" \
      --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' \
      --output text

  check "RDS clusters" \
    aws rds describe-db-clusters --profile "$PROFILE" --region "$REGION" \
      --query 'DBClusters[].[DBClusterIdentifier,Engine,Status]' --output text

  # Every public IPv4 address bills hourly since February 2024, attached or
  # not. An address auto-assigned to an instance is not an Elastic IP and so
  # does not appear here; the EC2 check above is what catches those.
  check "Elastic IPs (None in column 2 = unattached)" \
    aws ec2 describe-addresses --profile "$PROFILE" --region "$REGION" \
      --query 'Addresses[].[PublicIp,InstanceId]' --output text

  # Interface endpoints bill per hour per AZ. Gateway endpoints, which is what
  # S2 uses for S3 and DynamoDB, are free and deliberately excluded.
  check "Interface VPC endpoints" \
    aws ec2 describe-vpc-endpoints --profile "$PROFILE" --region "$REGION" \
      --filters Name=vpc-endpoint-type,Values=Interface \
      --query 'VpcEndpoints[].[VpcEndpointId,ServiceName,State]' --output text

  check "Config recorders" \
    aws configservice describe-configuration-recorders --profile "$PROFILE" \
      --region "$REGION" --query 'ConfigurationRecorders[].name' --output text

  check "KMS customer managed keys" kms_customer_keys "$REGION"

  if [ "$REGION_HAD_OUTPUT" -eq 0 ]; then
    echo "   nothing"
  fi
done

# Services with no region at all. Left out of the original S0 plan, which made
# the sweeper report an empty account while a hosted zone was billing monthly.
echo "== global"
REGION_HAD_OUTPUT=0

check "Route 53 hosted zones (billed monthly, each)" \
  aws route53 list-hosted-zones --profile "$PROFILE" \
    --query 'HostedZones[].[Id,Name]' --output text

check "CloudFront distributions" \
  aws cloudfront list-distributions --profile "$PROFILE" \
    --query 'DistributionList.Items[].[Id,DomainName,Enabled]' --output text

if [ "$REGION_HAD_OUTPUT" -eq 0 ]; then
  echo "   nothing"
fi

echo
echo "${REGIONS_CHECKED} regions checked, plus global."
echo "${FINDINGS} findings, ${FAILURES} failed calls."

# A failed call means a check never happened, which is not the same as a clean
# account. Exit non-zero so this is visible to anything calling the script.
if [ "$FAILURES" -gt 0 ]; then
  echo
  echo "Some checks did not run. Treat this sweep as incomplete."
  exit 2
fi

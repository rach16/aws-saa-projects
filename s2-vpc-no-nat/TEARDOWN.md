# S2 · Teardown

Same day. Two items here bill by the hour.

## Bills hourly, delete first

- [ ] Interface VPC endpoint for Secrets Manager. Billed per endpoint per AZ,
      per hour, whether or not anything calls it.
- [ ] EC2 instance in the private subnet. Terminate, do not stop; a stopped
      instance keeps billing for its EBS volume.
- [ ] Public IPv4 addresses. Billed per hour now, including addresses attached
      to a running instance. Release any Elastic IPs.

## Free, but delete to keep the account clean

- [ ] Gateway VPC endpoint for S3. No charge, but it leaves route table entries.
- [ ] NAT Gateway. There should not be one. Confirm.
- [ ] Subnets, route tables, internet gateway, then the VPC itself.
- [ ] Security groups and NACLs other than the defaults.

## Order matters

The VPC will refuse to delete while anything still lives in it. Work inwards:
instances, then endpoints, then the internet gateway detach, then subnets, then
the VPC.

## Verify

- [ ] Run S0 and confirm nothing from this project appears.
- [ ] Check the EBS volume list for an orphan left by the terminated instance.

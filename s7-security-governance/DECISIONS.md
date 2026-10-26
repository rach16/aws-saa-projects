# S7 · Decisions

Questions to answer here as the project gets built.

## Roles over users, everywhere

Record why the instance profile replaces an access key, and what an access key
on an instance exposes that a role does not.

## Identity policies, resource policies and permission boundaries

Three places a permission can be granted or denied, and the exam tests the
interaction. Record the evaluation order, record where an explicit deny wins,
and record what a permission boundary does that an identity policy cannot.

## ExternalId

Record what the confused deputy problem is and why ExternalId solves it. This
is a question the exam asks and most people answer by rote.

## KMS key policies against IAM policies

A KMS key policy is not optional and a key with a policy that omits you is a
key you have locked yourself out of. Record how access to a key is actually
evaluated, and record the difference between an AWS managed key and a customer
managed key, including the price of each.

## Denying unencrypted and non-TLS requests

Record the two condition keys used and why bucket default encryption is not the
same thing as a policy that refuses unencrypted uploads.

## Secrets Manager against Parameter Store

Record the price difference and what Secrets Manager adds for it. Rotation is
most of the answer.

## CloudTrail, Config and GuardDuty

Three detective controls that are often confused. Record what each one answers:
what happened, whether the configuration is compliant, and whether the activity
looks malicious. Record which are built here and why the others are not.

## Organizations and SCPs

Not built. An SCP needs a management account and member accounts, and a
misapplied one can lock you out of your own account. Record how SCPs interact
with IAM policies, because the exam asks even though this lab does not build
it.

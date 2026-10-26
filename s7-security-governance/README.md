# S7 · Security and governance

**Status:** Not built yet.
**Domain:** Design Secure Architectures (30%)

The largest domain gets the largest project.

## What it proves

A guardrail you have not tested is a guess.

## What gets built

- EC2 instance profile replacing long-lived access keys
- Cross-account role assumption with an ExternalId
- A permission boundary
- KMS customer managed key with a restrictive key policy
- Bucket policy denying both unencrypted PUT and non-TLS requests
- Secrets Manager with rotation enabled
- CloudTrail delivering to S3, queried through Athena
- AWS Config with one managed rule

## The measurement

Every guardrail gets attacked.

- Attempt the unencrypted PUT, capture the AccessDenied
- Attempt to exceed the permission boundary, capture the failure
- Attempt to decrypt with a principal the key policy excludes
- Find your own denied calls in CloudTrail via Athena, which is the skill that
  actually matters during an incident

A screenshot of a policy proves nothing. The captured denial proves the policy
works.

## Run

    TBD

## Results

TBD

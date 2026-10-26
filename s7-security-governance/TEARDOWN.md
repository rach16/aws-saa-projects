# S7 · Teardown

Two items here have waiting periods, so start the teardown before you need the
account clean.

## Has a mandatory waiting period

- [ ] KMS customer managed key. Schedule deletion; the minimum pending window
      is 7 days and the default is 30. The key bills monthly until it is
      actually deleted, so schedule it the day you finish. Disabling the key is
      not the same as deleting it and does not stop the charge.

## Bills while enabled

- [ ] AWS Config recorder. Billed per configuration item recorded and per rule
      evaluation. Stop the recorder, then delete the delivery channel and the
      rule.
- [ ] Secrets Manager secret. Billed per secret per month. Rotation adds Lambda
      invocations. Deleting a secret also has a recovery window, minimum 7 days.
- [ ] EC2 instance used for the instance profile demonstration, if S2 is not
      still standing.

## Leaves a recurring charge

- [ ] CloudTrail log objects in S3. The first trail is free but the storage is
      not. Set a lifecycle rule or empty the bucket.
- [ ] Athena query results bucket. Easy to forget; Athena writes a result file
      for every query you ran.
- [ ] Config history bucket.

## Delete

- [ ] IAM roles, the permission boundary policy, and any inline policies.
- [ ] The cross-account trust relationship, and the role in the second account.
- [ ] Bucket policies, then the buckets.

## Verify

- [ ] Run S0 and confirm the KMS key shows as pending deletion rather than
      enabled, and that no Config recorder is active.
- [ ] Confirm the CloudTrail trail is deleted, not just stopped.

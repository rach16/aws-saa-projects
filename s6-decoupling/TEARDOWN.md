# S6 · Teardown

Not urgent. Nothing in this project bills while idle, and the free tier covers
the volumes used here.

## Bills on use only

- [ ] SQS requests. Free tier covers a million a month.
- [ ] Lambda invocations and duration. Free tier is generous.
- [ ] SNS publishes and deliveries.
- [ ] EventBridge events. Custom bus events are billed per million.

## Delete when finished

- [ ] Purge and delete the main queue and the dead letter queue.
- [ ] Delete the Lambda function.
- [ ] Delete the SNS topic and its subscriptions.
- [ ] Delete the EventBridge rule and any custom bus.
- [ ] Delete the IAM execution role.

## Leaves behind

- [ ] CloudWatch log group for the Lambda. Check the retention setting; the
      default is Never Expire, which is a slow leak across every project in
      this repository.

## Verify

- [ ] Run S0. Nothing from this project should appear, because none of it is
      hourly billed. Confirm the log group retention anyway.

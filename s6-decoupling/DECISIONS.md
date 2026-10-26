# S6 · Decisions

Questions to answer here as the project gets built.

## SQS against SNS against EventBridge

All three decouple and they are not interchangeable. Record what each one is
for: a queue holds work for one consumer group, a topic fans out to many, an
event bus routes on content. Record which the exam scenarios signal with their
wording.

## Standard against FIFO

Record which this uses. Record what FIFO costs in throughput and what standard
costs in ordering and duplication.

## At-least-once delivery and idempotency

Standard queues can deliver a message more than once. Record how the consumer
is made idempotent and why "just make it idempotent" is easier to say than to
do.

## Visibility timeout and the redrive policy

Record what was set and why. A visibility timeout shorter than the consumer's
runtime turns one slow message into infinite duplicates.

## Queue depth as a scaling signal

Record why queue depth beats CPU as a scaling metric for this workload, and
connect it back to the measured scaling lag in S3.

## Long polling

Record the difference against short polling, and what it saves.

# S4 · The data tier

**Status:** Not built yet.
**Domains:** Design Resilient Architectures (26%), Design High-Performing Architectures (24%)

## What it proves

Multi-AZ is availability. Read replicas are throughput. Conflating them is a
wrong answer, and the exam asks in a way that rewards knowing the difference
cold.

## What gets built

- RDS instance with Multi-AZ enabled
- A read replica
- The same access pattern on DynamoDB with a global secondary index

## The measurement

- Force a Multi-AZ failover, time the DNS cutover, and note that the endpoint
  does not change
- Put write load on the primary and record replica lag, proving the replica is
  eventually consistent and therefore not a failover target
- On DynamoDB, run a query that needs the GSI and one that does not, and
  compare consumed capacity
- Copy a snapshot cross-region and time a restore, which gives a real RTO
  figure rather than a guessed one

## Run

    TBD

## Results

TBD

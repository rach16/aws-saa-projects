# S4 · Decisions

Questions to answer here as the project gets built.

## Multi-AZ against read replicas

The core distinction this project exists to prove. Record the measured failover
time, the measured replica lag, and what each one is actually for. Record what
Multi-AZ does not give you: no read scaling, and the standby is not reachable.

## RDS against Aurora

Aurora is exam material and is not built here, because the cheapest
configuration costs multiples of the smallest RDS instance and Serverless v2
bills its minimum capacity continuously. Record the comparison with real
figures from the Pricing API: storage architecture, replica count and
behaviour, failover time, and what the price difference buys.

## Relational against DynamoDB

Record why the same access pattern suits one or the other. Record what the GSI
cost in capacity and storage, and when a GSI is the wrong answer.

## On-demand against provisioned capacity

Record which DynamoDB mode this uses and at what request rate the other wins.

## Backup and recovery strategy

Record the measured cross-region restore time, then work through the four DR
strategies against it: backup and restore, pilot light, warm standby,
multi-site active-active. The measured number is what makes the reasoning real;
multi-region active-active is not built here because the exam wants the RTO and
RPO reasoning rather than the invoice.

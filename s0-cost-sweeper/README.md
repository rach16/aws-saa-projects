# S0 · Cost sweeper

**Status:** Not built yet.

Not a project. A tool, and the first thing in this repository, because every
other project here runs on services that bill by the hour whether or not
traffic arrives.

## What it does

Answers one question across every enabled region: is anything still billing?

Resources it reports:

- EC2 instances (running and stopped, since stopped instances keep their EBS)
- Application and Network Load Balancers
- NAT Gateways
- RDS instances and clusters
- EBS volumes, flagging unattached ones
- Public IPv4 addresses, both attached and unattached
- Interface VPC endpoints
- KMS customer managed keys
- AWS Config recorders

Output is a flat list with an hourly estimate per item and a total.

## Why all regions

A resource left in a region you used once is the charge you will not notice.
The console shows one region at a time; this does not.

## Run

    TBD

## Results

TBD

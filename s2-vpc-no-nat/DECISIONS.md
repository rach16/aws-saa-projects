# S2 · Decisions

Questions to answer here as the project gets built.

## No NAT Gateway

A NAT Gateway is the main hourly biller in a conventional VPC build and this
project does without one. Record what that costs in capability: which calls the
private instance can no longer make, and which VPC endpoints would be needed to
restore them.

Record the NAT Gateway hourly and per-GB rates from the Pricing API, so the
saving is a number rather than an assertion.

## Gateway endpoints against interface endpoints

S3 and DynamoDB get gateway endpoints, which are free and route-table based.
Everything else gets interface endpoints, which are ENIs and bill per hour per
AZ. Record why the two kinds exist and how to tell which a service supports.

## Security groups against network ACLs

Record the real guidance: security groups are the primary control and NACLs are
a coarse subnet-level backstop. Record why an NACL needs explicit ephemeral
port rules and a security group does not.

## Two AZs, not three

Record what the third AZ would buy and why it is not needed yet. S3 is the
project that makes the AZ count matter.

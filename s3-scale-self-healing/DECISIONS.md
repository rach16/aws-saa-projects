# S3 · Decisions

Questions to answer here as the project gets built.

## Target tracking against step scaling against scheduled

Record which this uses by default, what the measured response difference was,
and when each is the right answer. Scheduled scaling looks crude until the load
is predictable, at which point it beats both.

## ALB against NLB

Record why this is an ALB. Record what an NLB would change: layer 4, static IP
per AZ, no host or path routing, different health check semantics.

## EC2 health checks against ELB health checks

The Auto Scaling group can use either. Record the difference and why the
default one is not enough: an instance can be running perfectly while the
application on it returns 500s.

## Why the health check endpoint is not `/`

Record what the health check should actually test and what happens when it
tests too much. A health check that calls the database turns one database blip
into a full fleet replacement.

## Cooldown and warmup

Record what was set and why. These are the settings that decide whether the
group oscillates.

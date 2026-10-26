# S1 · Decisions

Questions to answer here as the project gets built.

## Origin Access Control over Origin Access Identity

OAI is the older mechanism and still appears in exam material. Record why OAC
replaced it and what OAI could not do.

## Why the origin bucket is private

A public bucket behind a CDN is a bucket that can be bypassed. Record what
bypassing the distribution would cost in both money and lost cache.

## Latency-based against geolocation and weighted routing

All three are exam material and they answer different questions. Record which
one this project uses, what the other two would have done differently, and
which one a real failover setup would need.

## What this does not need

No compute, no database, no VPC. Worth stating, because the instinct is to
reach for a server.

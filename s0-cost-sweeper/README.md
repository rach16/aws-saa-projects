# S0 · Cost sweeper

**Status:** Built and run, 29 October 2026.

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

Plus a **global** section for the services that have no region: Route 53 hosted
zones and CloudFront distributions. That was not in the original plan, and
omitting it was a real bug rather than a gap. Every one of the nine types above
is regional, and this account has none of them, so the sweeper as first
specified would have reported an empty account on its first run while a hosted
zone billed monthly.

## Why all regions

A resource left in a region you used once is the charge you will not notice.
The console shows one region at a time; this does not.

## It sweeps the account, not this repository

The sweeper is account-scoped. It has no idea which project created anything,
and it should not: the invoice is account-scoped too.

This account holds work from more than one repository, so a clean sweep of
these seven projects can still return findings. Those are not strays. The
question this tool answers is "is anything billing", not "did I leave something
behind", and the two have different answers whenever an account is shared.

The practical consequence is that output needs reading rather than scanning for
emptiness. A finding you recognise and are deliberately paying for is a pass.

## Run

```
./sweep.sh
```

Set `SWEEP_PROFILE` to use a profile other than `saa`.

Takes a minute or two. Roughly 170 API calls, issued serially. Serial was
chosen over parallel because a sweeper is a thing you need to trust more than
you need it fast, and the parallel version is meaningfully harder to read and
debug.

The exit code matters: `0` means every check ran, `2` means at least one did
not and the sweep should be treated as incomplete.

## How it tells empty apart from broken

A call that returns nothing and a call that failed both print nothing. If the
sweeper cannot tell them apart it can silently stop working and still look
clean, which is worse than having no sweeper at all, because you would trust
it.

So every call goes through one function that reads the exit code first and
reports a failure loudly, with the region named, before it considers the output
at all.

Two details that would otherwise break this quietly:

| Detail | Why it matters |
|---|---|
| `out=$(...)` and `rc=$?` on separate lines | `local out=$(...)` captures the exit code of `local`, not of the AWS call, so every failure would read as a success |
| A query matching nothing prints `None` | Under `--output text` an empty JMESPath result is the literal string `None`, not a blank line |

There is deliberately no `set -e`. If one region fails the other sixteen still
need checking, so errors are handled per call instead of ending the run.

**The failure path has never actually fired.** Across the first run, 170 calls
returned 0 failures, so the `!!` branch is reasoned about rather than observed.
It was tested in isolation against a bad profile, which returns exit `255`, but
not in place inside a real sweep.

## Results

First run, 29 October 2026. 17 regions, roughly 170 calls, 0 failed calls,
3 findings.

```
== us-west-2
   KMS customer managed keys
      61b07f26-34ae-4d76-8344-c2b437fb34bb
      c8d093e6-ebc4-4452-bfc0-4129efbe14c8
== global
   Route 53 hosted zones (billed monthly, each)
      /hostedzone/Z0627005XIHDA6RJMHJP  cedar.banik.dev.
   CloudFront distributions
      E3414HZ9GECD7Y    d37aucrxis75gt.cloudfront.net   True

17 regions checked, plus global.
3 findings, 0 failed calls.
```

The other sixteen regions reported `nothing` and are omitted above for length.
They are printed on every run, because seeing each region named is what proves
coverage.

| Finding | Expected | Note |
|---|---|---|
| Route 53 hosted zone | Yes | S1. Bills monthly, and is the only idle charge in the SAA work |
| CloudFront distribution | Yes | S1. Per request and per GB, so effectively nothing at this traffic |
| 2 KMS customer managed keys | **No** | Not from these projects. Another project in the same account, one key per environment. Both `Enabled`, created 16 and 17 October 2026 |

The KMS finding is the thing that justified building this. Customer managed
keys bill monthly per key whether or not anything decrypts with them, and
deletion carries a minimum seven day waiting period, so they are not a charge
you can clear on the evening you notice it. Nothing in these seven projects
uses KMS: S1's bucket is SSE-S3.

## What it cannot tell you yet

**How much.** Stage one answers whether anything is billing. It does not
attach a figure to any of it, so "three findings" could be pennies or real
money and this tool will not say which.

That is stage two, and the first run made the case for it better than any rule
could: two keys had been billing for twelve days before anything surfaced them,
and the sweeper still cannot say what that cost.

Estimates must come from the Pricing API rather than from memory, per the
repository rule, and some services publish no rates there at all. Which ones,
and where the fallback figure came from, gets recorded in `DECISIONS.md` as
that work happens.

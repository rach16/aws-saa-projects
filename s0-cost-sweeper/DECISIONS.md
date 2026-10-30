# S0 · Decisions

The tool is built and run. The pricing question below is still open; everything
after it was settled while writing `sweep.sh`.

## Where do the prices come from

The hourly estimates must come from the Pricing API, not from memory. Every
figure quoted in this repository needs the same treatment. A confidently wrong
cost claim is worse than no cost claim.

Open question: the Pricing API does not publish rates for every service. Record
which ones return nothing and where the fallback figure came from.

Deferred deliberately. Stage one reports what is billing with no figures
attached, because the inventory is useful the day it exists and the pricing
work is not small. Blocking the useful half on the hard half would have
produced neither.

## Describe calls only

The sweeper never deletes. A tool that can delete is a tool you hesitate to run,
and the point is to run it without thinking at the end of every session.
Teardown stays manual, per project, from each `TEARDOWN.md`.

## Why not AWS Budgets or Cost Explorer alone

Budgets alerts after money is spent and Cost Explorer lags by hours. Neither
tells you what is running right now, which is the thing you need before closing
the laptop.

Both still belong in the account. Budgets is the backstop for what this misses.

## Account-scoped, not repository-scoped

The sweeper reports everything billing in the account and makes no attempt to
work out which project created it.

That is the correct scope, because it is the invoice's scope. It also means a
clean sweep of these seven projects can still return findings, since this
account holds work from another repository as well. Those findings are not
strays and should not be chased.

The first run proved the point: the only unexpected items were two customer
managed KMS keys belonging to a different project, one per environment, which
had been billing for twelve days. A repository-scoped sweeper would have called
the account clean and been wrong about the bill.

The cost of this choice is that output has to be read rather than scanned for
emptiness. A finding you recognise and are deliberately paying for is a pass,
and only you can make that call.

## The global section was missing, and that was a bug

The original plan listed nine resource types. All nine are regional, and this
account has none of them, so the first run would have printed an empty account
while the Route 53 hosted zone from S1 billed monthly.

Route 53 hosted zones and CloudFront distributions were added in a `global`
section. The repository's own top-level cost list already named hosted zones as
a monthly idle charge, so the omission was not a lack of knowledge. It was a
plan written by enumerating services rather than by asking what the account is
actually paying for.

Recorded because a sweeper that misses the only charge you have is worse than
no sweeper, and because the failure mode was a confident empty result rather
than an error.

## Serial, not parallel

Seventeen regions times ten calls is roughly 170 requests, which takes a minute
or two in sequence. Running regions in parallel would cut that to seconds.

Rejected for now. Parallel means background jobs, buffered output per region
and counters that cannot be incremented from a subshell, all of which make the
script harder to read and much harder to debug when one region misbehaves. A
sweeper needs to be trusted more than it needs to be fast, and a minute is not
the thing stopping anyone from running it.

Worth revisiting only if the resource list grows enough that the wait starts
getting the tool skipped.

## No `set -e`, and an exit code of 2

The usual safety line at the top of a shell script is `set -euo pipefail`. The
`-e` is wrong here: if one region fails, the other sixteen still need checking,
so a single bad call must not end the run. Errors are caught per call instead,
and a comment in the script says so, because otherwise the omission reads as
carelessness.

The run then exits `2` if any check failed. An incomplete sweep and a clean
account print similar output and mean completely different things, and the exit
code is what lets anything calling the script tell them apart.

`-u` and `-o pipefail` are kept.

## Empty against broken

The central design problem. A call returning nothing and a call that failed
both print nothing, so the only thing separating "nothing is running" from "the
sweeper is lying to you" is the exit code.

Every call goes through one function that checks the exit code before it looks
at the output, and reports a failure loudly with the region named. Two details
would have broken this silently:

- `local out=$(...)` captures the exit code of `local`, not of the command.
  The assignment and the `$?` read have to be separate statements.
- A JMESPath query matching nothing prints the literal string `None` under
  `--output text`, so an emptiness test has to treat `None` as empty.

**The failure branch has not fired in a real sweep.** The first run returned
zero failures across 170 calls. The exit code behaviour was confirmed in
isolation, by pointing a call at a profile that does not exist and observing
`255`, but the reporting path inside the loop is reasoned about rather than
observed. Noted rather than claimed, because the whole value of this script
rests on that branch working.

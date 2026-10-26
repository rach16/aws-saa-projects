# S0 · Decisions

Questions to answer here as the tool gets built.

## Where do the prices come from

The hourly estimates must come from the Pricing API, not from memory. Every
figure quoted in this repository needs the same treatment. A confidently wrong
cost claim is worse than no cost claim.

Open question: the Pricing API does not publish rates for every service. Record
which ones return nothing and where the fallback figure came from.

## Describe calls only

The sweeper never deletes. A tool that can delete is a tool you hesitate to run,
and the point is to run it without thinking at the end of every session.
Teardown stays manual, per project, from each `TEARDOWN.md`.

## Why not AWS Budgets or Cost Explorer alone

Budgets alerts after money is spent and Cost Explorer lags by hours. Neither
tells you what is running right now, which is the thing you need before closing
the laptop.

Both still belong in the account. Budgets is the backstop for what this misses.

# S5 · Decisions

Questions to answer here as the project gets built.

## The crossover table

The deliverable. For a given object size and access frequency, which storage
class is cheapest. Record where the crossovers fall and which assumptions move
them.

## Intelligent-Tiering is not free

It carries a per-object monitoring charge, which dominates at small object
sizes. Record the object size below which Intelligent-Tiering costs more than
the class it would have moved you to. This is the detail that makes the
"just use Intelligent-Tiering" answer wrong sometimes.

## Early-delete minimums

Glacier Flexible Retrieval carries a 90-day minimum and Deep Archive 180 days.
An object written and deleted the same day still bills the full term. Record
the figures and record what this means for a lifecycle rule that transitions
objects too eagerly.

## Retrieval tiers within Glacier

Expedited, Standard and Bulk for Flexible; Standard and Bulk for Deep Archive.
Record the measured times against the documented ones, and the price difference
between tiers.

## Versioning and replication

Record what versioning costs: every overwrite keeps the old object, billed.
Record why cross-region replication requires versioning, and what replication
does and does not copy.

## Why tiny objects

Deliberate. The measurements are about time and rate, not volume, and the
early-delete minimums mean anything written here bills for months.

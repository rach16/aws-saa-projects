# S5 · Teardown

Not urgent, and not fully possible. This is the one project that bills after
you delete it.

## Expect residual charges

- [ ] Objects in Glacier Flexible Retrieval keep billing for the remainder of
      their 90-day minimum after deletion.
- [ ] Objects in Deep Archive keep billing for the remainder of their 180-day
      minimum.

This is why the project uses tiny objects. Record the residual in the results
rather than being surprised by it on the invoice.

## Delete

- [ ] Empty the source bucket, including all noncurrent versions. A versioned
      bucket is not empty when it looks empty, and it will refuse to delete.
- [ ] Empty the replication destination bucket the same way.
- [ ] Delete the replication configuration, then both buckets.
- [ ] Delete the IAM role created for replication.

## Leaves a recurring charge

- [ ] Nothing, once the minimums expire.

## Verify

- [ ] List all buckets and confirm both are gone.
- [ ] Check next month's bill for the Glacier residual and record the actual
      figure in the results. That number is the point of the project.

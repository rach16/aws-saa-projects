# S4 · Teardown

Same day. The running database instances are the most expensive thing in this
repository.

## Bills hourly

- [ ] Read replica. Delete this first; deleting the primary while a replica
      exists is refused or promotes it.
- [ ] RDS primary instance. Multi-AZ doubles the instance charge, so this is
      twice the rate the instance class suggests.
- [ ] DynamoDB table, if provisioned capacity rather than on-demand.

## Take the snapshot before you delete

- [ ] Final snapshot of the RDS instance. Snapshot storage is cheap and it means
      you can rebuild the project without rebuilding the data.
- [ ] Note that automated backups are deleted with the instance unless retained;
      a manual final snapshot is not.

## Leaves a recurring charge

- [ ] Snapshots, per GB-month. Cheap, but keep one rather than nine.
- [ ] The cross-region snapshot copy. Easy to forget, because it is in the
      region you were only visiting.
- [ ] DynamoDB storage, per GB-month. Pennies at this scale.

## Leaves behind

- [ ] DB subnet group. Free, delete for cleanliness.
- [ ] Parameter and option groups, if custom ones were created.
- [ ] Performance Insights data, if it was enabled beyond the free retention.

## Verify

- [ ] Run S0 and confirm no RDS instances or clusters appear, in any region.
- [ ] Check the snapshot list in both regions.

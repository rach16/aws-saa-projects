# S3 · Teardown

Same day, mandatory. Nothing in this project is free and everything bills by
the hour.

## Bills hourly

- [ ] Auto Scaling group. Set desired, minimum and maximum capacity to zero
      first, or it will helpfully replace the instances you just terminated.
- [ ] EC2 instances. Confirm all are terminated after the group drains.
- [ ] Application Load Balancer. Billed per hour plus capacity units.
- [ ] Target group. Free, but delete after the load balancer.
- [ ] Public IPv4 addresses on any instance that had one.

## Order matters

Scale the group to zero before deleting it, then delete the load balancer, then
the target group, then the launch template. Deleting the group first can leave
instances orphaned.

## Leaves behind

- [ ] CloudWatch alarms created by the scaling policies. Free at this volume
      but they clutter the console and some outlive the group.
- [ ] CloudWatch log groups, if the instances shipped logs. Check the retention
      setting; Never Expire is a slow leak.
- [ ] EBS volumes from terminated instances, if delete-on-termination was off.

## Verify

- [ ] Run S0 and confirm nothing from this project appears.
- [ ] Confirm the Auto Scaling group is gone, not just empty.

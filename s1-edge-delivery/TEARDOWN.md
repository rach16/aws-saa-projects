# S1 · Teardown

Nothing here bills meaningfully while idle, so teardown is not urgent. This is
the one project in the repository you can leave standing.

## Leaves a recurring charge

- [ ] Route 53 hosted zone, around $0.50/month. Keep it if the domain stays
      registered; the zone is the cheap part.
- [ ] Registered domain, annual. The only real spend in this project.

## Safe to leave running

- [ ] CloudFront distribution. Billed on requests and egress, nothing while
      idle.
- [ ] S3 bucket. Billed per GB stored; a static site is pennies.
- [ ] ACM certificate. Free when used with CloudFront.

## If you do want it gone

- [ ] Disable the CloudFront distribution, wait for it to finish deploying, then
      delete it. A distribution cannot be deleted while enabled.
- [ ] Empty and delete both origin buckets.
- [ ] Delete the Route 53 records, then the hosted zone.

## Verify

- [ ] Run S0 and confirm nothing from this project appears.

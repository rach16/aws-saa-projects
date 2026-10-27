# S1 · Teardown

Nothing here bills meaningfully while idle, so teardown is not urgent. This is
the one project in the repository you can leave standing.

Built 27 October 2026. Left standing at time of writing.

## Leaves a recurring charge

- [ ] Route 53 hosted zone `cedar.banik.dev`. Monthly, per zone. Keep it if the
      domain stays registered; the zone is the cheap part.
- [ ] Registered domain `banik.dev`, annual, at the registrar rather than AWS.
      The only real spend in this project.

No rate is quoted for either. Repository rule: a cost figure goes in only after
the Pricing API confirms it, and that check has not been run here.

## Safe to leave running

- [ ] CloudFront distribution `E3414HZ9GECD7Y`. Billed on requests and egress,
      nothing at rest.
- [ ] WAF core protections. Bundled with the CloudFront Free plan, $0.
- [ ] S3 bucket `cedar-clinic-site-7412`. 10 objects, roughly 20 KB total.
- [ ] ACM certificate in us-east-1. Free when used with CloudFront.

## If you do want it gone

Order matters. Each step blocks the one after it.

- [ ] **Disable** the CloudFront distribution and wait for it to reach
      `Deployed`. A distribution cannot be deleted while enabled, and the wait
      is several minutes rather than seconds.
- [ ] **Delete** the distribution. Check with:
      `aws cloudfront get-distribution --id E3414HZ9GECD7Y --profile saa --query 'Distribution.Status' --output text`
- [ ] Delete the alias A record at the apex of `cedar.banik.dev`. The hosted
      zone will not delete while non-default records remain.
- [ ] Empty, then delete, bucket `cedar-clinic-site-7412`. Both prefixes: the
      site at the root and the copy under `nocache/`.
- [ ] Delete the hosted zone `cedar.banik.dev`.
- [ ] Delete the ACM certificate in **us-east-1**, not us-west-2. It will not
      delete while still attached to a distribution, which is why it comes after
      the distribution.
- [ ] Remove the four `cedar` NS records at the registrar. Easy to forget, and
      leaving them means the parent keeps referring queries to name servers that
      no longer serve the zone.

## Order trap worth knowing

Deleting the ACM certificate while the distribution still references it fails,
and deleting the hosted zone while the alias record exists fails. Both failures
are clear. The one that fails *silently* is deleting the hosted zone and leaving
the registrar NS records in place: nothing errors, and `cedar.banik.dev` simply
stops resolving with a SERVFAIL rather than an NXDOMAIN.

## Verify

- [ ] `dig A cedar.banik.dev` returns nothing.
- [ ] `aws s3 ls --profile saa` does not list the bucket.
- [ ] Run S0 and confirm nothing from this project appears.

# S1 · Decisions

## Delegating a subdomain with NS records, not a CNAME

`cedar.banik.dev` needed to be served by Route 53 while `banik.dev` stayed at
the registrar. The mechanism is four NS records at the parent pointing at the
four name servers Route 53 assigned to the hosted zone. That creates a zone cut:
the parent stops answering for anything under `cedar` and returns a referral
instead.

A CNAME would not have worked. A CNAME maps one name to another name, it cannot
hand off authority for a whole subtree, and it cannot coexist with other records
at the same name.

The parent zone has a wildcard `*.banik.dev` pointing at unrelated hosts. It does
not shadow the delegation, because a name that explicitly exists in the zone
always beats a wildcard. Verified rather than assumed:

```
dig NS cedar.banik.dev @<registrar nameserver>     returns a referral
dig SOA cedar.banik.dev @ns-1048.awsdns-03.org     Route 53 is authoritative
dig A anything.cedar.banik.dev                     empty, wildcard does not reach
```

Doing DNS first paid off immediately: the ACM certificate validated in under a
minute, because the validation CNAME resolved the moment it was written.

## Origin Access Control over Origin Access Identity

OAI is the older mechanism and still appears in exam material, so it is worth
knowing why it was replaced.

| | OAI | OAC |
|---|---|---|
| SSE-KMS encrypted objects | not supported | supported |
| Regions | not all | all |
| HTTP methods | GET and HEAD only | all, including PUT and DELETE |
| Signing | legacy | SigV4, per request |

Nothing in this project needs KMS or PUT, so OAI would have worked. OAC was
chosen because OAI is on a deprecation path and there is no reason to learn the
old one as a default.

The current console wizard writes the bucket policy itself through a checkbox
labelled "Allow private S3 bucket access to CloudFront". An earlier plan for this
project involved copying a policy document out of CloudFront and pasting it into
S3 by hand. That step no longer exists.

## Why the origin bucket is private

A public bucket behind a CDN is a bucket that can be bypassed, and bypass costs
in three ways at once: origin egress is billed instead of the cheaper CDN
egress, the cache never warms for that traffic, and the WAF in front of
CloudFront never sees the request.

Confirmed working: the S3 REST endpoint returns `403` directly while the
distribution serves `200`.

Worth knowing why that is a `403` and not a `404`. The bucket policy grants
`s3:GetObject` to the CloudFront service principal and nothing else. Without
`s3:ListBucket`, S3 will not confirm or deny that a key exists, because doing so
would let an anonymous caller enumerate the bucket one guess at a time. So a
missing object and a forbidden object return the same answer. **A 403 from S3
frequently means "not found" in disguise**, and that distinction appears on the
exam as a troubleshooting question.

## A cache-disabled behaviour as the control, not a public bucket

The original plan was to measure TTFB against S3 directly, which required
temporarily making the bucket public.

That was rejected, for a reason that is about production rather than this lab.
With account-level Block Public Access on and a service control policy denying
anyone the ability to turn it off, making a bucket public is not a step you can
take. A measurement technique that only works when the guardrails are off is not
a technique worth learning.

The replacement is a second cache behaviour on `/nocache/*` using
`Managed-CachingDisabled`, with an identical copy of the site under that prefix.
It is better than the original on its own merits:

- Same edge, same TLS session, same geography. The original would have compared
  an edge in San Francisco against a bucket in Oregon, confounding the cache
  effect with a network distance effect.
- Bucket stays private throughout.
- Repeatable by anyone reading the repository without touching account settings.

Compression was switched off on the new behaviour. The default behaviour has it
on, and gzip on HTML changes the bytes on the wire; comparing a compressed
response against an uncompressed one would have measured compression, not
caching. Both paths returned `content-length: 2479`.

### Correction: compression was never switched off

The paragraph above says compression was switched off on the `/nocache/*`
behaviour so the comparison would not accidentally measure gzip. Reading the
live distribution config while writing the Terraform showed `Compress: true` on
**both** behaviours. It was never switched off.

The measurement survives. `curl` sends no `Accept-Encoding` header unless told
to, and CloudFront compresses only when the viewer asks for it, so neither
response was compressed. Both returned `content-length: 2479` because both were
the raw file, not because compression had been disabled. The two behaviours are
also identical on this setting, so it could not have skewed one against the
other.

What was wrong is the explanation, not the result. Recorded because a correct
number with a wrong reason attached is still a wrong claim, and because nothing
caught it until the infrastructure was described in code.

## Behaviour precedence

CloudFront evaluates path patterns in precedence order and takes the **first**
match, not the most specific one. `Default (*)` is pinned last and cannot be
moved, so with two behaviours this cannot be got wrong. With four it can: a
broad pattern above a narrow one silently swallows it, and the symptom is a
cache-disabled path that keeps returning cached content.

## WAF in monitor mode first

Core protections were enabled in monitor mode, left there while the site was
exercised, then switched to blocking. Monitor mode counts what a rule *would*
have blocked without blocking it.

The reason is that managed rule groups have false positives, and the cost of
discovering them in blocking mode is real users getting 403s. Count first, read
the counts, then enforce.

Measured cost of enforcing: 3 ms, which is inside the noise floor. The before and
after numbers are in `README.md`.

### Correction: WAF is not $5/month here

An earlier version of this plan budgeted roughly $5/month for WAF, on the basis
of the standalone WAFv2 web ACL price.

That figure does not apply. CloudFront's plan tiers now bundle WAF, and the Free
plan at $0/month includes it along with five WAF rules, five cache behaviours and
one alternate domain name. The $5 was the price of a thing this project is not
buying.

Left here as a correction rather than deleted, because a confidently wrong cost
figure is exactly what the repository rule about the Pricing API exists to catch.
This one was caught by reading the console, which is luck rather than process.

## Latency-based against geolocation and weighted routing

All three are exam material and they answer different questions.

| Policy | Routes on | Typical use |
|---|---|---|
| Simple | nothing, one answer | single endpoint |
| Weighted | a ratio you set | canary, blue/green |
| Latency | measured network latency to each region | performance |
| Failover | health check result | disaster recovery |
| Geolocation | the querier's country | legal and content restrictions |
| Geoproximity | geography, with a bias dial | shifting load between regions |
| Multivalue answer | up to eight healthy records | crude redundancy, explicitly not a load balancer |

**This project uses none of them.** The record at the apex is a simple alias to
the CloudFront distribution, and that is the correct answer.

The original scope called for "a second origin in another region behind a
latency-based routing policy". That combination is architecturally confused, and
working out why was more useful than building it would have been.

CloudFront already steers each viewer, and it does it mainly through DNS. When a
browser resolves the distribution's domain name, CloudFront's own DNS returns
edge addresses chosen for where the query came from, so a viewer in Frankfurt
gets Frankfurt edge addresses. Putting Route 53 latency-based routing in front of
that adds a second DNS decision on top of one CloudFront has already made with
better information: Route 53 would be choosing between two origins, while
CloudFront is choosing between hundreds of edges.

An earlier version of this file said "CloudFront is already an anycast network",
which is loose enough to be wrong. **Anycast Static IPs are a separate paid
CloudFront feature**, bought when a viewer needs a fixed set of IP addresses to
allowlist. This project does not use it, and the steering described above is DNS,
not BGP.

Latency-based routing belongs in front of **regional** endpoints: two ALBs, two
API Gateway deployments, two regional stacks. It is the right tool when there
genuinely are two places to send traffic and no CDN above them making the same
choice.

The thing that *would* have been correct here is a CloudFront **origin group**:
two origins, a primary and a failover, with CloudFront switching on origin
errors. That is origin failover, it involves no DNS at all, and conflating it
with latency routing is the mistake the exam tests.

### Correction: an origin group was never buildable here

An earlier version of this file implied the origin group was skipped for time.
It was not available to skip. **Origin groups require the CloudFront Premium
plan at $1,000/month**, which the console shows as an upgrade prompt on the
Origins tab. The Free plan this project runs on does not include them.

So the dropped scope item had two independent reasons, not one: the routing
policy as originally specified was the wrong construct, and the right construct
was behind a paywall three orders of magnitude above this project's budget.

The $1,000 figure was read off the CloudFront console's plan comparison, not the
Pricing API. Same provenance as the WAF correction above, and the same caveat
applies.

Recorded because knowing when a routing policy is wrong is harder and more
testable than knowing how to configure one, and because "not built, for time" was
a more flattering reason than the real one.

## Alias record, not CNAME, at the apex

The record is an A record with Alias enabled, targeting the distribution.

A CNAME is illegal at a zone apex. DNS requires SOA and NS records to exist
there, and a CNAME cannot coexist with other records at the same name. Alias is
AWS-specific, legal at the apex, free to query, and tracks the target's
addresses automatically as CloudFront changes them.

## The certificate lives in us-east-1

The bucket is in us-west-2 and the certificate is in us-east-1, which looks
wrong and is mandatory. CloudFront only reads certificates from us-east-1,
because it is a global service and its control plane lives there.

The same pattern covers CloudFront's CloudWatch metrics, Route 53 health check
metrics and billing metrics: **global services report to us-east-1**. The exam
disguises this as "the dashboard shows no data" or "the certificate does not
appear in the dropdown".

ACM certificates used with CloudFront are free, and DNS validation renews
automatically for as long as the validation CNAME stays in the zone. Deleting
that record quietly breaks renewal, and the failure surfaces up to a year later.

## Terraform by import, not by rebuild

The stack was built by hand in the console, then described in hand-written HCL
and imported. `terraform plan` now reports no changes. Details and layout are in
`terraform/README.md`.

The alternative was to destroy the console-built stack and `apply` a fresh one.
Rejected: it takes the site down, a new hosted zone means four new name servers
and a round of registrar edits and DNS propagation, and a successful `apply`
only proves the code builds *something*. A clean plan against live
infrastructure proves the code describes *this* thing, attribute by attribute.

It is also the realistic skill. Inheriting infrastructure somebody clicked
together is the normal case, and `import` plus an iterated plan is how you take
ownership of it without an outage.

Two attributes would have been silently overwritten on a first apply, because
anything absent from the HCL is filled with the provider default rather than the
real value: the hosted zone's empty `comment` would have become
`Managed by Terraform`, and the distribution's `Name` tag would have been
deleted. Stopping at "the import succeeded" would have shipped both.

## What this does not need

No compute, no database, no VPC, no load balancer, no NAT gateway.

Worth stating because the instinct is to reach for a server, and because the
list above is most of what bills by the hour. A static site with a CDN in front
is the cheapest useful architecture on AWS and it is a legitimate answer to a
surprising number of exam questions. When the requirement is static content,
global reach and low cost, adding EC2 is the wrong answer even when it works.

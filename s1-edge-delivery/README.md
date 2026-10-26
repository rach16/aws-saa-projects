# S1 · Edge and static delivery

**Status:** Not built yet.
**Domains:** Design High-Performing Architectures (24%), Design Cost-Optimized Architectures (20%)

## What it proves

Caching and geography are the cheapest performance wins available, and CDN
egress costs less per GB than serving from the origin.

## What gets built

- S3 bucket as a private origin, no public access
- CloudFront distribution with Origin Access Control
- ACM certificate
- Route 53 record
- A second origin in another region behind a latency-based routing policy

## The measurement

- TTFB from at least three geographies, before and after CloudFront
- Cache hit ratio from CloudFront metrics once the cache is warm
- The Route 53 record resolved from different vantage points, showing different
  answers
- Per-GB egress rate S3-direct against CloudFront

## Run

    TBD

## Results

TBD

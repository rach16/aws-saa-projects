# S3 · Scale and self-healing

**Status:** Not built yet.
**Domains:** Design Resilient Architectures (26%), Design High-Performing Architectures (24%)

## What it proves

Auto Scaling is not instant. That is precisely why the exam wants you scaling
on a leading signal rather than a trailing one.

## What gets built

- Application Load Balancer across both availability zones
- Auto Scaling group with a target tracking policy
- Health checks that actually fail when the application does, not just when the
  instance stops

## The measurement

- Terminate an instance, time the replacement reaching InService
- Load-test and time the full chain: alarm breach, scaling activity, new
  instance healthy and serving traffic
- Swap target tracking for step scaling and compare the response curves

The gap between "CPU crossed the threshold" and "new capacity is serving
requests" is minutes. Measuring it yourself changes how you answer every
scaling question on the exam.

## Run

    TBD

## Results

TBD

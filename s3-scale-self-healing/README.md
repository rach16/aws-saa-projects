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

## How it will fit together

> **This diagram is the plan, not a record.** Nothing here is built yet, so the
> shape is intended rather than observed. It gets corrected against reality once
> the project is built, the same way S1's was.

```mermaid
graph TB
    U["Users"]
    subgraph AWS["AWS Global Infrastructure"]
        subgraph REG["Region: us-west-2"]
            ALB["Application Load Balancer<br/>across both AZs"]
            subgraph AZA["AZ: us-west-2a"]
                I1["EC2 target<br/>health checked"]
            end
            subgraph AZB["AZ: us-west-2b"]
                I2["EC2 target<br/>health checked"]
            end
            ASG["Auto Scaling group<br/>target tracking"]
            CW["CloudWatch alarm<br/>CPU threshold"]
        end
    end
    U ==> ALB
    ALB ==> I1
    ALB ==> I2
    I1 -.->|"metrics"| CW
    CW -.->|"breach"| ASG
    ASG ==>|"launch: minutes, not seconds"| I2
    classDef aws fill:#FF9900,color:#232F3E,stroke:#CC7A00
    classDef edge fill:#146EB4,color:#FFFFFF,stroke:#0F5389
    classDef store fill:#569A31,color:#FFFFFF,stroke:#417525
    classDef ext fill:#232F3E,color:#FFFFFF,stroke:#131A23
    class ALB,ASG,CW aws
    class I1,I2 edge
    class U ext
```

The dotted path is the one being measured. Metrics reach CloudWatch on a
delay, the alarm needs consecutive breaching periods, and the launched instance
then has to boot and pass health checks before the load balancer sends it
anything. Each hop adds time, which is the whole reason the exam prefers a
leading signal.

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

# S7 · Security and governance

**Status:** Not built yet.
**Domain:** Design Secure Architectures (30%)

The largest domain gets the largest project.

## What it proves

A guardrail you have not tested is a guess.

## What gets built

- EC2 instance profile replacing long-lived access keys
- Cross-account role assumption with an ExternalId
- A permission boundary
- KMS customer managed key with a restrictive key policy
- Bucket policy denying both unencrypted PUT and non-TLS requests
- Secrets Manager with rotation enabled
- CloudTrail delivering to S3, queried through Athena
- AWS Config with one managed rule

## How it will fit together

> **This diagram is the plan, not a record.** Nothing here is built yet, so the
> shape is intended rather than observed. It gets corrected against reality once
> the project is built, the same way S1's was.

```mermaid
graph TB
    C["Caller<br/>every guardrail gets attacked"]
    subgraph AWS["AWS Global Infrastructure"]
        subgraph REG["Region: us-west-2"]
            IP["EC2 instance profile<br/>no long-lived keys"]
            PBND["Permission boundary"]
            KMS["KMS customer managed key<br/>restrictive key policy"]
            BP["Bucket policy<br/>deny unencrypted PUT<br/>deny non-TLS"]
            SEC["Secrets Manager<br/>rotation enabled"]
            CT["CloudTrail"]
            LOGS["S3: trail destination"]
            ATH["Athena<br/>find your own denials"]
            CFG["AWS Config<br/>one managed rule"]
        end
        subgraph ACC2["Second account"]
            XR["Cross-account role<br/>ExternalId required"]
        end
    end
    C ==> IP
    IP ==>|"sts:AssumeRole"| XR
    IP ==> SEC
    C -.->|"unencrypted PUT: AccessDenied"| BP
    C -.->|"exceed boundary: AccessDenied"| PBND
    C -.->|"decrypt as excluded principal: AccessDenied"| KMS
    CT ==> LOGS
    LOGS ==> ATH
    CFG -.->|"evaluates"| BP
    classDef aws fill:#FF9900,color:#232F3E,stroke:#CC7A00
    classDef edge fill:#146EB4,color:#FFFFFF,stroke:#0F5389
    classDef store fill:#569A31,color:#FFFFFF,stroke:#417525
    classDef ext fill:#232F3E,color:#FFFFFF,stroke:#131A23
    class IP,KMS,SEC,CT,CFG aws
    class PBND,BP,XR,ATH edge
    class LOGS store
    class C ext
```

Every dotted arrow is an attempt that is supposed to fail, and the captured
`AccessDenied` is the deliverable. The solid path is what the caller is allowed
to do. CloudTrail to S3 to Athena is the loop that closes it: a guardrail you
cannot find the denial for in the logs is a guardrail you cannot prove fired.

## The measurement

Every guardrail gets attacked.

- Attempt the unencrypted PUT, capture the AccessDenied
- Attempt to exceed the permission boundary, capture the failure
- Attempt to decrypt with a principal the key policy excludes
- Find your own denied calls in CloudTrail via Athena, which is the skill that
  actually matters during an incident

A screenshot of a policy proves nothing. The captured denial proves the policy
works.

## Run

    TBD

## Results

TBD

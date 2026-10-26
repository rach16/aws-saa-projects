# AWS Solutions Architect Associate projects

Seven small, self-contained infrastructure projects covering every domain of the
AWS Certified Solutions Architect Associate exam (SAA-C03), plus the tool that
keeps the lab account from bleeding money.

Each project is deliberately small enough to finish. Each one ends with a
`DECISIONS.md` explaining why that approach was chosen over the alternatives,
and a `TEARDOWN.md` that is a checklist rather than a description.

## Domain coverage

| Exam domain | Weight | Projects |
|---|---|---|
| Design Secure Architectures | 30% | S2, S7 |
| Design Resilient Architectures | 26% | S2, S3, S4, S5, S6 |
| Design High-Performing Architectures | 24% | S1, S3, S4, S6 |
| Design Cost-Optimized Architectures | 20% | S1, S5 |

Passing score is 720 on a scaled range of 100 to 1000. That is not 72% of
questions correct: results are scaled and questions are not equally weighted.
65 questions in 130 minutes, of which 50 are scored and 15 are unscored trial
items you cannot identify.

Confirm the domain weights on the AWS certification page before booking. They
change with each revision of the exam, and the figures above are SAA-C03.

## The projects

| | Project | What it proves | Status |
|---|---|---|---|
| **S0** | [Cost sweeper](./s0-cost-sweeper) | Not a project, a tool. One script, every region, answering whether anything is still billing. | Planned |
| **S1** | [Edge and static delivery](./s1-edge-delivery) | Caching and geography are the cheapest performance wins available, and CDN egress costs less than origin egress. | Planned |
| **S2** | [A VPC by hand, with no NAT Gateway](./s2-vpc-no-nat) | Private does not have to mean NAT. And stateful against stateless, proved with packets rather than definitions. | Planned |
| **S3** | [Scale and self-healing](./s3-scale-self-healing) | Auto Scaling is not instant, which is why the exam wants a leading signal. | Planned |
| **S4** | [The data tier](./s4-data-tier) | Multi-AZ is availability, read replicas are throughput, and conflating them is a wrong answer. | Planned |
| **S5** | [Storage classes and lifecycle economics](./s5-storage-lifecycle) | The retrieval tier is a latency decision disguised as a cost decision. | Planned |
| **S6** | [Decoupling](./s6-decoupling) | Correctly decoupled, a downstream failure becomes a backlog rather than an outage. | Planned |
| **S7** | [Security and governance](./s7-security-governance) | A guardrail you have not tested is a guess. | Planned |

## Order

Build **S0 first.** Not optional. Every other project here runs on services
that bill by the hour whether or not traffic arrives, and the sweeper is what
lets you build without worrying.

Then **S1**, which is the cheapest and fastest and ends with a working URL.
Then **S5**, early, because its lifecycle transitions take days to happen and
it can sit in the background costing pennies while you work on everything else.
**S2** before S3, S4 and S7, which build on its network.

If you only do four: **S1, S2, S4, S7.** That covers the two heaviest domains
properly and gives you a network and a data tier you can reason about. S3 and
S6 are the ones most people can already discuss credibly from work experience.

## Cost discipline

The hazard here is different from a token-billed lab. **Most of the services
this exam covers bill by the hour whether or not anything uses them.**

Hourly or monthly while idle:

- NAT Gateway, per hour plus per GB. S2 avoids it entirely with VPC endpoints.
- Load balancers, per hour plus capacity units.
- RDS instances, per hour, doubled by Multi-AZ.
- Public IPv4 addresses, per hour, including addresses attached to a running
  instance.
- Interface VPC endpoints, per hour per endpoint per availability zone.
- KMS customer managed keys, monthly, and deletion has a waiting period of at
  least 7 days.
- Route 53 hosted zones, monthly.
- EBS volumes, monthly, and they outlive a terminated instance when
  delete-on-termination is off.
- AWS Config, per configuration item and per rule evaluation.

Plus the charges that survive deletion: Glacier Flexible Retrieval has a 90-day
early-delete minimum and Deep Archive 180 days. S5 writes deliberately tiny
objects for that reason and records the residual rather than being surprised by
it.

Set a **Budgets alert with a working notification before creating the first
resource,** not after. S0 catches what you left running; the budget catches what
S0 missed.

**No cost figure appears in this repository until it has been through the
Pricing API.** Quoting a rate from memory is how a lab turns into an invoice
nobody predicted, and some services publish no rates through the API at all,
in which case the source gets named explicitly.

## What is not built here

| Topic | Why not |
|---|---|
| Direct Connect, Site-to-Site VPN, Transit Gateway | Direct Connect is not buildable at lab scale, a VPN needs a second endpoint, and Transit Gateway bills per attachment-hour. Exam-tested conceptually, so read rather than build. |
| Global Accelerator | Fixed monthly charge per accelerator regardless of traffic. Poor value for what it teaches. |
| Aurora | The cheapest configuration costs multiples of the smallest RDS instance, and Serverless v2 bills its minimum capacity continuously. Compared against RDS in S4's `DECISIONS.md` instead. |
| Organizations and service control policies | Needs a management account plus members, and a misapplied SCP can lock you out of your own account. The policy interaction is covered in S7's `DECISIONS.md`. |
| Shield Advanced | Priced for enterprises, not labs. WAF is affordable and could bolt onto S1. |
| FSx, Storage Gateway, Snowball | Either impractical to run or require hardware. |
| Multi-region active-active | The exam wants the RTO and RPO reasoning, which S4's measured cross-region restore already provides at a fraction of the cost. |

Each of these is a deliberate omission with a reason, not a gap. The reasoning
is the transferable part; the invoice is not.

## Conventions

**Console first, then Terraform, and commit the Terraform.** Building it by hand
once is how you learn the vocabulary the exam uses. Reproducing it in code is
what makes the repository worth reading. CloudFormation is what the exam
references, so its syntax is worth reading even though Terraform is what the job
market wants.

Each project directory contains:

- `README.md`: what it proves, what gets built, the measurement, and the results
- `DECISIONS.md`: the choices made and the alternatives rejected, with reasoning
- `TEARDOWN.md`: a checklist, ticked, ordered by what bills fastest
- `verify.sh`: proves the thing actually works
- Committed results, so the numbers can be read without running anything

Evidence is captured command output, not screenshots. Output is greppable and
screenshots rot.

Credentials come from the AWS CLI profile and are never committed.

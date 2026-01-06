# ADR 001: Adoption of LocalStack for Hybrid Cloud Simulation

## Context
Safari Bank requires a proof-of-concept (PoC) for a hybrid cloud architecture connecting AWS EKS to an on-premise mainframe.

## Decisions
We will use LocalStack to simulate the AWS environment.

## Rationale
1. **Cost:** Running a managed EKS cluster on AWS costs ~73/month (control plane) + worker nodes. LocalStack stack is free.
2. **Speed:** LocalStack allows "Hot Reloading" of Lambda and rapid infrastructure tearing down/spinning up without waiting for AWS CloudFormation provisioning times (15+ mins for EKS)
3. **Safety:** Eliminates the risk of accidental bill shock due to orphaned resources.

## Trade-offs
- **High Local Resource Usage:** Requires significant RAM (8GB+) on the developer machine.
- **Fidelity:** Some edge-case EKS behaviours may differ from production AWS.

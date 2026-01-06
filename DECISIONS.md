# Architecture Decision Records (ADR)

This document records the architectural choices I made during the development of the Safari Bank Hybrid Cloud Simulation.

## ADR-001: Use of LocalStack for Cloud Emulation
* **Status:** Accepted
* **Context:** I needed a way to simulate AWS EKS (Kubernetes) and RDS (Databases) without incurring real cloud costs or dealing with internet latency.
* **Decision:** I chose **LocalStack Pro** running in Docker.
* **Consequences:**
    * (+) Zero cost for spinning up clusters.
    * (+) Fast iteration loops (local deployment).
    * (-) Networking complexity: LocalStack creates a nested network environment ("Docker inside Docker") which complicates ingress/egress traffic routing.

## ADR-002: "Split-Horizon" Network Architecture
* **Status:** Accepted
* **Context:** Real banks do not expose their Mainframes to the public cloud directly. They use private lines (Direct Connect/VPN). I wanted to replicate this security constraint accurately.
* **Decision:** I created two distinct Docker networks:
    1.  `cloud-net`: Simulating the AWS VPC.
    2.  `on-prem-net`: Simulating the Bank's Physical Data Center.
* **Consequences:**
    * (+) Accurate simulation of enterprise security constraints.
    * (-) Requires manual "Virtual VPN" configuration (bridging networks) to allow traffic to flow, adding operational complexity to the deployment pipeline.

## ADR-003: Containerized Legacy Mainframe Mock
* **Status:** Accepted
* **Context:** I needed a reliable target to simulate a COBOL mainframe response. My initial attempts using inline shell scripts in Docker Compose proved fragile and hard to debug.
* **Decision:** I refactored the mainframe logic into a dedicated Python/Flask microservice with its own `Dockerfile`.
* **Consequences:**
    * (+) Stability: The service restarts automatically and has clear, accessible logs.
    * (+) Extensibility: I can easily add more "banking logic" later without breaking the underlying infrastructure.

## ADR-004: Host Networking Strategy (`hostNetwork: true`)
* **Status:** Accepted
* **Context:** The Kubernetes CNI (Container Network Interface) inside LocalStack isolates Pods from the host Docker network. This prevented my application from reaching the "On-Prem" mainframe IP, even after I had successfully connected the underlying Node.
* **Decision:** I enabled `hostNetwork: true` on the Kubernetes Deployment.
* **Consequences:**
    * (+) Solves the routing issue by allowing the Pod to share the Node's network stack directly.
    * (-) Reduces security isolation (acceptable for a simulation/portfolio project, but discouraged in multi-tenant production).
    * (-) Limits scaling: I cannot run multiple replicas of the app on the same node because they would contend for port 8000.

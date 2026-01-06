# Safari Bank: Hybrid Cloud Banking Simulation

![Status](https://img.shields.io/badge/Status-Complete-success)
![Tech](https://img.shields.io/badge/Stack-LocalStack_|_Terraform_|_Kubernetes_|_Django-blue)

## Architecture
graph TD
    subgraph "Local Laptop (Host Machine)"
        user[User / Browser] -->|HTTP :8080| tunnel[Kubectl Port-Forward]
        
        subgraph "LocalStack (Docker Container)"
            tunnel -->|Forward to :8000| k8s_service[K8s Service]
            
            subgraph "Kubernetes Cluster (EKS/K3s)"
                k8s_service --> pod[Django Wallet Pod]
                pod -->|Env Vars| rds_config[DB Config]
            end
            
            subgraph "AWS Cloud Resources"
                rds[(RDS Postgres DB)] 
                pod -->|SQL :4510| rds
            end
        end

        subgraph "Legacy Data Center (Docker Container)"
            mainframe[Python Mainframe API]
            pod -.->|HTTP :8000 (VPN Bridge)| mainframe
        end
    end

    classDef legacy fill:#f9f,stroke:#333,stroke-width:2px;
    class mainframe legacy;
    classDef cloud fill:#bae1ff,stroke:#333,stroke-width:2px;
    class pod,rds cloud;

## 📖 Overview

**Safari Bank** is a high-fidelity simulation of a modern banking infrastructure. It replicates a common enterprise scenario: a **Cloud-Native Microservice** (running on AWS EKS) that must securely communicate with a **Legacy Mainframe** (running in an isolated On-Premise Data Center).

I built this project to demonstrate advanced infrastructure skills—specifically, how to architect **Hybrid Connectivity**, orchestrate **Kubernetes** clusters, and automate resources with **Terraform**, all within a local development environment using **LocalStack**.

---

## 🏗 Architecture

The system mimics a "Split-Horizon" network architecture where the Cloud and the Data Center are network-isolated by default.



### The Components
1.  **The Cloud (AWS Region `us-east-1`):**
    * **EKS Cluster:** Hosted on LocalStack (K3s), running a Django Wallet Application.
    * **RDS Database:** A PostgreSQL instance provisioning the wallet ledger.
    * **Network:** `cloud-net` (Simulated VPC).

2.  **The On-Premise Data Center:**
    * **Legacy Mainframe:** A containerized Python/Flask service simulating a COBOL banking core.
    * **Network:** `on-prem-net` (Simulated Private Data Center).

3.  **The Bridge (Hybrid Connectivity):**
    * A simulated **VPN Tunnel** established by manually attaching the Kubernetes Node to the On-Premise physical network.

---

## 🚀 Key Features

* **Infrastructure as Code (IaC):** Full provisioning of AWS resources (RDS, Security Groups) using **Terraform**.
* **Kubernetes Orchestration:** Deployment, Service, and Pod management using `kubectl` manifests.
* **Legacy Integration:** Custom-built "Mainframe" microservice that mimics legacy API responses.
* **Network Engineering:** Solved complex routing challenges (CNI overlays vs. Docker Bridges) to enable cross-network communication.
* **Service Discovery:** Dynamic injection of database and mainframe endpoints into the Kubernetes runtime.

---

## 🛠 Prerequisites

* **Docker Desktop** (with Docker Compose)
* **LocalStack** (CLI installed)
* **Terraform**
* **Kubectl**
* **Python 3.9+**

---

## ⚡ Quick Start Guide

Follow these steps to spin up the entire banking infrastructure on your local machine.

### 1. Initialize the Infrastructure
Start the simulated Cloud and On-Prem environments:
```bash
docker-compose up -d
```

### 2. Provision Cloud Resources
Use Terraform to create the RDS Database in LocalStack:
```bash
cd terraform
tflocal init
tflocal apply --auto-approve
cd ..
```

### 3. Build & Deploy the Application
Build the wallet image and deploy it to the Kubernetes cluster:
```bash
# Build the image
docker build -t safari-wallet:v1 .

# Sideload image into the Kubernetes Runtime (Crucial Step for LocalStack)
# Note: Check 'kubectl get nodes' to find your specific node container name
docker save safari-wallet:v1 | docker exec -i localstack_pro ctr -n k8s.io images import -

# Deploy
kubectl apply -f kubernetes/deployment.yaml
```

### 4. Establish the VPN Tunnel
**This is the most critical step.** By default, the Cloud App cannot see the Mainframe. I manually bridge the networks:
```bash
# Connect the Kubernetes Node to the On-Prem Network
docker network connect safari-datacenter localstack_pro (or your k3d-node-name)
```

### 5. Verify the Transaction
Tunnel into the cluster and request a balance check from the legacy system:
```bash
# Terminal 1: Open Tunnel
kubectl port-forward deployment/wallet-deployment 8080:8000

# Terminal 2: Run Transaction
curl http://localhost:8080/api/balance/
```

**Success Output:**
```json
{
  "status": "success",
  "source": "Legacy Mainframe (On-Prem)",
  "data": {
    "account": "1234567890",
    "balance": 50000.0,
    "currency": "KES"
  }
}
```

## 🧠 Technical Challenges & Solutions
Building this simulation required solving several advanced engineering problems.

### Challenge 1: The "Split-Brain" Network
**Problem:** The Kubernetes Pods were trapped inside the CNI overlay network and couldn't route traffic to the Docker Bridge network where the Mainframe lived.
**Solution:** I implemented `hostNetwork: true` in the deployment manifest. This allowed the Pods to bypass the overlay and utilize the Node's direct attachment to the `on-prem-net`. See `DECISIONS.md`(ADR-004).

### Challenge 2: Image Availability
**Problem:** The Kubernetes runtime (containerd) inside LocalStack could not see the Docker images built on my host machine.
**Solution:** I built a sideloading pipeline using `docker save | docker exec ... ctr import` to manually inject the binary into the cluster's registry. See `TROUBLESHOOTING.md`(Issue 2).

## 📂 Project Structure
```bash
├── app/                  # Django Cloud Application (The Wallet)
├── legacy/               # Python Mainframe Simulation (The Legacy Core)
├── kubernetes/           # K8s Deployment & Service Manifests
├── terraform/            # IaC for RDS & Network Security
├── docker-compose.yml    # LocalStack & Network Orchestration
├── DECISIONS.md          # Architectural Decision Records (ADR)
└── TROUBLESHOOTING.md    # Log of complex bugs and resolutions
```

## 🔮 Future Improvements
* **CI/CD Pipeline:** Automate the "Build -> Sideload -> Deploy" workflow using GitHub Actions.
* **Service Mesh:** Implement Istio or Linkerd to handle the mTLS connection between Cloud and On-Prem instead of raw routing.
* **Monitoring:** Add Prometheus/Grafana to visualize the latency between the Cloud App and the Mainframe.

## 💻 Author
**Kariũki** *Solutions Architect & Backend Engineer*

This project is part of my technical portfolio demonstrating proficiency in Hybrid Cloud Architecture.

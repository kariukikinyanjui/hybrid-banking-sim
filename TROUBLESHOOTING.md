# Troubleshooting Log

A record of the significant technical challenges I encountered during the build and the methodologies I used to resolve them.

---

## Issue 1: Kubernetes Pods Stuck in `Pending`
**Symptom:** Upon applying the deployment, pods remained in a `Pending` state indefinitely.
`kubectl get pods` showed 0/1 ready.

**Root Cause Analysis:** I inspected the scheduler events using `kubectl describe pod`. The output revealed a "Taint" issue:
> `0/1 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: true}`

Since I was running a single-node cluster (LocalStack/K3s), the node was marked as a "Control Plane" and refused to schedule application workloads by default.

**Resolution:** I manually untainted the node to allow workload scheduling:
```bash
kubectl taint nodes <node_name> node-role.kubernetes.io/control-plane:NoSchedule-
```

## Issue 2: `ErrImageNeverPull`/Image Not Found
**Symptom:** Pods failed with `ErrImageNeverPull`. The Kubernetes scheduler could not find my local docker image `safari-wallet:v1`, even though `docker images` showed it existed on my machine.

**Root Cause Analysis:** Kubernetes (running inside LocalStack via K3s) uses `containerd` as its runtime, which has a separate image store from the standard Docker Daemon on my host machine. The K3s cluster cannot "see" images built locally in Docker.

**Resolution:** I developed a "Sideloading" pipeline to pipe the image binary directly from Docker into the cluster's runtime:
```bash
docker save safari-wallet:v1 | docker exec -i <node_container> ctr -n k8s.io images import -
```

## Issue 3: The "Split Brain" Network (503 Service Unavailable)
**Symptom:** The application health check passed, but requests to the Mainframe returned `503 Service Unavailable`.
* **Layer 3 Check:** `ping` from the Node container to the Mainframe IP succeeded.
* **Layer 7 Check:** `curl` from the Node container succeeded.
* **Pod Check:** Python requests *inside* the Pod failed with `ConnectTimeout`.

**Root Cause Analysis:** This was a routing failure between the Kubernetes Overlay Network (CNI) and the underlying Docker Bridge Network. The Pods were trapped in the overlay and could not route packets out to the `on-prem-net` interface attached to the Node.

**Resolution:** I identified that the Kubernetes Node was running in a sibling container (`k3d-safari-bank...`) rather than the main LocalStack container. I executed two fixes:
1. **Physical Link:** Manually attached the Docker network to the correct K3s container:
`docker network connect safari-datacenter k3d-safari-bank-server-0`
2. **Network Mode:** Updated `deployment.yaml` to use `hostNetwork: true`, allowing the Pod to bypass the overlay and utilize the Node's verified connection.

## Issue 4: Terraform State Drift
**Symptom:** Terraform failed to create the RDS instance with `DBInstanceAlreadyExists`, even though `terraform state rm` had been run and the Docker container was gone.

**Root Cause Analysis:** LocalStack maintains an internal persistence layer that outlived the Terraform state file. Removing the resource from Terraform state did not remove the entry from LocalStack's internal registry.

**Resolution:** I performed a manual cleanup using the AWS CLI wrapper before re-applying Terraform:
```bash
awslocal rds delete-db-instance --db-instance-identifier safari-wallet-db
terraform apply --auto-approve
```

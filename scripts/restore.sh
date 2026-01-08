#!/bin/bash

echo "Starting Safari Bank Infrastructure..."
docker-compose up -d

echo "Waiting for LocalStack to be ready..."
# Simple wait loop (or use localstack wait -t 30)
sleep 15

echo "Restoring Cloud State..."
localstack pod load safari-bank-snapshot-v1

echo "Re-establishing Hybrid VPN..."
NODE_CONTAINER=$(docker ps --format "{{.Name}}" | grep -E "k3d-.*-server-0|localstack_pro" | head -n 1)
docker network connect safari-datacenter $NODE_CONTAINER

echo "System Restored. Testing connectivity..."
kubectl port-forward deployment/wallet-deployment 8080:8000 &
sleep 2
curl http://localhost:8080/api/balance/

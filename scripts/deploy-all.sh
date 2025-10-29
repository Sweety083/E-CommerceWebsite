#!/usr/bin/env bash
# Apply configmaps, deployments, and service for the ecommerce app
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Applying configmaps..."
kubectl apply -f "$ROOT_DIR/k8s/configmap-blue.yaml"
kubectl apply -f "$ROOT_DIR/k8s/configmap-green.yaml"

echo "Applying deployments..."
kubectl apply -f "$ROOT_DIR/k8s/blue-deployment.yaml"
kubectl apply -f "$ROOT_DIR/k8s/green-deployment.yaml"

echo "Applying service..."
kubectl apply -f "$ROOT_DIR/k8s/service.yaml"

echo "All resources applied."
echo "Check pods: kubectl get pods -l app=ecommerce -L version"

#!/usr/bin/env bash
set -euo pipefail

# Deploy blue version
deploy_blue() {
  echo "Deploying BLUE version..."
  kubectl apply -f k8s/configmap-blue.yaml
  kubectl apply -f k8s/blue-deployment.yaml
  # Ensure service points to blue
  kubectl patch service ecommerce-service -p '{"spec":{"selector":{"app":"ecommerce","version":"blue"}}}'
}

# Deploy green version
deploy_green() {
  echo "Deploying GREEN version..."
  kubectl apply -f k8s/configmap-green.yaml
  kubectl apply -f k8s/green-deployment.yaml
  # Keep service pointing to blue until ready to switch
}

# Initial setup - deploy both versions, route to blue
echo "Setting up Blue/Green deployment..."
deploy_blue
deploy_green

# Apply service (points to blue by default)
kubectl apply -f k8s/service.yaml

# Show status
echo -e "\nService is routing to:"
kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo

echo -e "\nPods status:"
kubectl get pods -l app=ecommerce -L version

echo -e "\nAccess the app:"
echo "1. Using port-forward (recommended):"
echo "   kubectl port-forward svc/ecommerce-service 8080:80"
echo "   Then open: http://localhost:8080"
echo
echo "2. Using minikube:"
echo "   minikube service ecommerce-service --url"

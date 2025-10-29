#!/usr/bin/env bash
set -euo pipefail

# Switch service to route traffic to green version
echo "Switching traffic to GREEN version..."
kubectl patch service ecommerce-service -p '{"spec":{"selector":{"app":"ecommerce","version":"green"}}}'

# Show new routing
echo -e "\nService is now routing to:"
kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo

# Show pod status
echo -e "\nPods status:"
kubectl get pods -l app=ecommerce -L version

# Monitor pod readiness
echo -e "\nMonitoring GREEN pods readiness..."
kubectl wait --for=condition=ready pod -l "app=ecommerce,version=green" --timeout=60s

echo -e "\nAccess the app to verify GREEN version:"
echo "1. Using port-forward (recommended):"
echo "   kubectl port-forward svc/ecommerce-service 8080:80"
echo "   Then open: http://localhost:8080"
echo
echo "2. Using minikube:"
echo "   minikube service ecommerce-service --url"
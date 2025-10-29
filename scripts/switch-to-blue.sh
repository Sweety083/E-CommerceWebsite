#!/usr/bin/env bash
set -euo pipefail

echo "Patching service selector to route to blue..."
kubectl patch svc ecommerce-service -p '{"spec":{"selector":{"app":"ecommerce","version":"blue"}}}'
echo "Service selector now:" 
kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo

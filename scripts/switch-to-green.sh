#!/usr/bin/env bash
set -euo pipefail

echo "Patching service selector to route to green..."
kubectl patch svc ecommerce-service -p '{"spec":{"selector":{"app":"ecommerce","version":"green"}}}'
echo "Service selector now:" 
kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo

#!/usr/bin/env bash
set -euo pipefail

# Switch traffic between blue/green versions and verify the switch
switch_version() {
  local target_version="$1"
  
  echo "Switching traffic to version: $target_version"
  
  # Patch the service selector
  kubectl patch service ecommerce-service -p "{\"spec\":{\"selector\":{\"app\":\"ecommerce\",\"version\":\"${target_version}\"}}}"
  
  # Confirm the switch
  local current_version
  current_version=$(kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}')
  echo "Service now routing to: $current_version"
  
  # Show pods for the new version
  echo "Pods for version $current_version:"
  kubectl get pods -l "app=ecommerce,version=${current_version}" -o wide
  
  # Verify a pod exists and show its content
  local pod
  pod=$(kubectl get pods -l "app=ecommerce,version=${current_version}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  if [[ -n "$pod" ]]; then
    echo "Content from pod $pod:"
    kubectl exec -it "$pod" -- cat /usr/share/nginx/html/index.html || true
  else 
    echo "No pod found for version=$current_version"
    return 1
  fi
}

# Main execution
if [[ "${1:-}" == "--help" || $# -eq 0 ]]; then
  echo "Usage: $0 <target-version>"
  echo "Example: $0 green"
  exit 1
fi

switch_version "$1"
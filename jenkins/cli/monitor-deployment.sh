#!/usr/bin/env bash
set -euo pipefail

# Monitor deployment status and version switch
monitor_deployment() {
  local target_version="$1"
  local timeout="${2:-300}"  # default 5 minutes timeout
  local interval="${3:-2}"   # check every 2 seconds
  local attempts=$((timeout / interval))
  
  echo "Monitoring deployment switch to version: $target_version"
  echo "Timeout: ${timeout}s, checking every ${interval}s"
  
  for ((i=1; i<=attempts; i++)); do
    # Check service selector version
    local current_version
    current_version=$(kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}')
    echo "[$(date +%H:%M:%S)] Service routing to version: $current_version"
    
    # Get pods for current version
    local pods
    pods=$(kubectl get pods -l "app=ecommerce,version=${current_version}" -o wide)
    echo "$pods"
    
    # Check if target version is reached and pods are ready
    if [[ "$current_version" == "$target_version" ]]; then
      local ready_pods
      ready_pods=$(kubectl get pods -l "app=ecommerce,version=${target_version}" \
        -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | tr ' ' '\n' | grep -c "true" || echo "0")
      local total_pods
      total_pods=$(kubectl get pods -l "app=ecommerce,version=${target_version}" \
        -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | tr ' ' '\n' | wc -l)
      
      if [[ "$ready_pods" == "$total_pods" && "$total_pods" -gt 0 ]]; then
        echo "✅ Deployment complete: $ready_pods/$total_pods pods ready"
        return 0
      fi
    fi
    
    sleep "$interval"
  done
  
  echo "❌ Deployment monitoring timed out after ${timeout}s"
  return 1
}

# Check app health by curling the service
check_app_health() {
  local retries=3
  local wait=5
  
  echo "Checking application health..."
  
  # Try both NodePort and minikube service URL
  for ((i=1; i<=retries; i++)); do
    # Try NodePort first (30080)
    if curl -sSf "http://127.0.0.1:30080" >/dev/null 2>&1; then
      echo "✅ App is healthy on NodePort 30080"
      return 0
    fi
    
    # Try minikube service URL as fallback
    local url
    url=$(minikube service ecommerce-service --url 2>/dev/null || true)
    if [[ -n "$url" ]] && curl -sSf "$url" >/dev/null 2>&1; then
      echo "✅ App is healthy on $url"
      return 0
    fi
    
    echo "Attempt $i/$retries failed, waiting ${wait}s..."
    sleep "$wait"
  done
  
  echo "❌ Health check failed after $retries attempts"
  return 1
}

# Main execution
if [[ "${1:-}" == "--help" || $# -eq 0 ]]; then
  echo "Usage: $0 <target-version> [timeout-seconds] [check-interval-seconds]"
  echo "Example: $0 green 300 2"
  exit 1
fi

target_version="$1"
timeout="${2:-300}"
interval="${3:-2}"

monitor_deployment "$target_version" "$timeout" "$interval" && check_app_health
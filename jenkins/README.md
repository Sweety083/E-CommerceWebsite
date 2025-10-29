# Jenkins Integration for Blue/Green Deployment

## Setup Instructions

1. **Set Jenkins Credentials**
   ```bash
   export JENKINS_USER=your_username
   export JENKINS_TOKEN=your_jenkins_api_token
   ```

2. **Available Scripts**

   - `jenkins/cli/build-job.sh`: Trigger Jenkins pipeline builds
   - `jenkins/cli/monitor-deployment.sh`: Monitor deployment status and health
   - `jenkins/cli/switch-version.sh`: Switch traffic between blue/green versions

3. **Usage Examples**

   Switch to blue version and build green:
   ```bash
   # Switch to blue
   ./jenkins/cli/switch-version.sh blue
   
   # Trigger Jenkins build for green
   ./jenkins/cli/build-job.sh \
     --url http://127.0.0.1:8080 \
     --job ecommerce-pipeline \
     --param TARGET_VERSION=green
   
   # Monitor deployment (5 min timeout)
   ./jenkins/cli/monitor-deployment.sh green 300
   ```

   Complete deployment sequence:
   ```bash
   # Set credentials
   export JENKINS_USER=your_username
   export JENKINS_TOKEN=your_jenkins_token
   
   # Switch to blue, build green, and monitor
   ./jenkins/cli/switch-version.sh blue && \
   ./jenkins/cli/build-job.sh --url http://127.0.0.1:8080 --job ecommerce-pipeline --param TARGET_VERSION=green && \
   ./jenkins/cli/monitor-deployment.sh green
   ```

4. **Verification Commands**

   Check current routing:
   ```bash
   kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo
   ```

   Check pods by version:
   ```bash
   kubectl get pods -l app=ecommerce -L version
   ```

   Get pod content:
   ```bash
   VERSION=$(kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}')
   POD=$(kubectl get pods -l version=$VERSION -o jsonpath='{.items[0].metadata.name}')
   kubectl exec -it $POD -- cat /usr/share/nginx/html/index.html
   ```

## Jenkins Pipeline Configuration

1. Create a new Pipeline job named `ecommerce-pipeline`
2. Add string parameter: `TARGET_VERSION` (values: blue/green)
3. Pipeline should:
   - Build Docker image for target version
   - Push to registry
   - Apply k8s manifests
   - Switch traffic (optional - can use CLI)
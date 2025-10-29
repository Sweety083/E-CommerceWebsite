pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')   // DockerHub credentials ID in Jenkins
        DOCKER_IMAGE = "sweetyraj22/ecommerce"             // DockerHub image repo
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/Sweety083/E-CommerceWebsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🛠️ Building Docker image..."
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "📦 Pushing image to DockerHub..."
                    sh """
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Blue-Green Deployment to Kubernetes') {
            steps {
                script {
                    echo "🚀 Starting Blue-Green Deployment..."
                    
                    // Determine target version based on current version
                    def currentVersion = sh(
                        script: "kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}' || echo 'blue'",
                        returnStdout: true
                    ).trim()
                    
                    def targetVersion = currentVersion == 'blue' ? 'green' : 'blue'
                    echo "Current version: ${currentVersion}, Target version: ${targetVersion}"
                    
                    // Tag the new image with target version
                    sh """
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:${targetVersion}
                        docker push ${DOCKER_IMAGE}:${targetVersion}
                    """
                    
                    // Deploy new version
                    sh """
                        kubectl apply -f k8s/configmap-${targetVersion}.yaml
                        kubectl apply -f k8s/${targetVersion}-deployment.yaml
                        kubectl rollout status deployment/ecommerce-${targetVersion} -n default
                    """
                    
                    // Wait for user confirmation before switching traffic
                    input message: "Switch traffic to ${targetVersion} version?"
                    
                    // Switch traffic
                    sh """
                        kubectl patch service ecommerce-service -p '{"spec":{"selector":{"app":"ecommerce","version":"${targetVersion}"}}}'
                    """
                    
                    echo "✅ Traffic switched to ${targetVersion} version"
                    
                    // Verify deployment
                    sh """
                        echo "Current service routing:"
                        kubectl get svc ecommerce-service -o=jsonpath='{.spec.selector.version}'; echo
                        echo "\\nPod status:"
                        kubectl get pods -l app=ecommerce,version=${targetVersion} -o wide
                    """
                }

                        def newColor = (currentColor == 'blue') ? 'green' : 'blue'

                        echo "🔹 Current Active Color: ${currentColor}"
                        echo "🟢 Deploying New Version to: ${newColor}"

                        // Apply the new deployment manifest
                        sh "kubectl apply -f k8s/${newColor}-deployment.yaml"

                        // Update deployment image
                        sh "kubectl set image deployment/ecommerce-${newColor} ecommerce=${DOCKER_IMAGE}:${BUILD_NUMBER}"

                        // Wait for rollout to complete
                        sh "kubectl rollout status deployment/ecommerce-${newColor}"

                        // Switch service traffic to the new deployment
                        sh "kubectl patch svc ecommerce-service -p '{\"spec\":{\"selector\":{\"app\":\"ecommerce\",\"version\":\"${newColor}\"}}}'"

                        echo "✅ Traffic successfully switched to ${newColor} deployment!"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment successful — Blue-Green switch completed."
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs for more details."
        }
    }
}

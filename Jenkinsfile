pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')   // DockerHub credentials ID in Jenkins
        DOCKER_IMAGE = "sweetyraj22/ecommerce"            // DockerHub image repo
    }

    parameters {
        choice(name: 'TARGET_VERSION', choices: ['green', 'blue'], description: 'Select the target version to deploy')
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
                    
                    def targetVersion = params.TARGET_VERSION
                    echo "Target version: ${targetVersion}"
                    
                    // Tag the new image with target version
                    sh """
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:${targetVersion}
                        docker push ${DOCKER_IMAGE}:${targetVersion}
                    """
                    
                    // Deploy new version
                    sh """
                        kubectl apply -f k8s/configmap-${targetVersion}.yaml
                        kubectl apply -f k8s/${targetVersion}-deployment.yaml
                        kubectl set image deployment/ecommerce-${targetVersion} ecommerce=${DOCKER_IMAGE}:${BUILD_NUMBER}
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

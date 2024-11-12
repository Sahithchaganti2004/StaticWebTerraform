pipeline {
    agent any

    environment {
        DOCKERHUB_REPOSITORY = 'chsks2004/myapp'             // Docker Hub repository in the format 'username/repo'
        IMAGE_TAG = "${env.BUILD_ID}"                        // Unique image tag using Jenkins build ID
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub repository
                git url: 'https://github.com/Sahithchaganti2004/StaticWebTerraform.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKERHUB_REPOSITORY}:${IMAGE_TAG}")   // Build Docker image for Docker Hub
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                    }
                    // Push Docker image to Docker Hub
                    sh "docker push ${DOCKERHUB_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    withAWS(region: "us-east-1", credentials: 'aws-credentials') {   // Adjust AWS region and credentials if needed
                        // Initialize Terraform with backend S3 bucket and key (adjust values as needed)
                        sh "terraform init -backend-config='bucket=myapp-terraform-state' -backend-config='key=terraform.tfstate'"
                        // Apply Terraform configurations with the Docker image tag variable
                        sh "terraform apply -auto-approve -var 'image_tag=${IMAGE_TAG}'"
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    withAWS(region: "us-east-1", credentials: 'aws-credentials') {   // Adjust AWS region and credentials if needed
                        // Update ECS service with the new Docker image version
                        sh "aws ecs update-service --cluster myapp-cluster --service myapp-service --force-new-deployment"
                    }
                }
            }
        }

        stage('Post-Deployment Testing') {
            steps {
                echo "Running post-deployment tests..."
                // Add testing commands here, if any
            }
        }
    }

    post {
        always {
            cleanWs()                                    // Clean up workspace after completion
        }
        success {
            echo "Deployment succeeded!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}

pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'                          // Change if deploying to a different AWS region
        ECR_REPOSITORY = 'myapp-repo'                     // Amazon ECR repository name
        IMAGE_TAG = "${env.BUILD_ID}"                     // Unique image tag using Jenkins build ID
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub repository
                git url: 'https://github.com/Sahithchaganti2004/StaticWebTerraform', branch: 'main'   // Adjust to match repo URL and branch
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("myapp:${IMAGE_TAG}")   // Build Docker image; update "myapp" if necessary
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com", 'aws-ecr-credentials') {
                        sh "docker tag myapp:${IMAGE_TAG} ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"  // Tag Docker image
                        sh "docker push ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"                   // Push image to ECR
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
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
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
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

pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'                         // Change to your AWS region if different
        ECR_REPOSITORY = 'myapp-repo'                    // Change to your Amazon ECR repository name
        IMAGE_TAG = "${env.BUILD_ID}"                    // Image tag; typically the Jenkins build ID
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm                               // Checks out the code from the linked Git repository
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("myapp:${IMAGE_TAG}")    // "myapp" is the image name; change if required
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com", 'aws-ecr-credentials') {
                        sh "docker tag myapp:${IMAGE_TAG} ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"  // Change if ECR repo path differs
                        sh "docker push ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"                    // Pushes image to ECR
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                        sh "terraform init -backend-config='bucket=myapp-terraform-state' -backend-config='key=terraform.tfstate'"    // Change S3 bucket and key names if needed
                        sh "terraform apply -auto-approve -var 'image_tag=${IMAGE_TAG}'"                                            // Adjust variable name if Terraform config requires it
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    // Deploys or updates ECS service to use the new image
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                        sh "aws ecs update-service --cluster myapp-cluster --service myapp-service --force-new-deployment"            // Update cluster and service names if different
                    }
                }
            }
        }

        stage('Post-Deployment Testing') {
            steps {
                echo "Running post-deployment tests..."
                // Add specific test commands or paths here
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Deployment succeeded!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}

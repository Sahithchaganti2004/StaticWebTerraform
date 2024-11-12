pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'                          // AWS region for ECR and ECS
        ECR_REPOSITORY = 'myapp-repo'                     // Amazon ECR repository name
        IMAGE_TAG = "${env.BUILD_ID}"                     // Unique image tag using Jenkins build ID
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
                    docker.build("myapp:${IMAGE_TAG}")   // Build Docker image; update "myapp" if necessary
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    // Log in to ECR
                    withCredentials([usernamePassword(credentialsId: 'aws-ecr-credentials', passwordVariable: 'AWS_SECRET_KEY', usernameVariable: 'AWS_ACCESS_KEY')]) {
                        sh '''
                            aws configure set aws_access_key_id $AWS_ACCESS_KEY
                            aws configure set aws_secret_access_key $AWS_SECRET_KEY
                            aws configure set default.region ${AWS_REGION}
                        '''
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    }
                    // Tag and push Docker image
                    sh "docker tag myapp:${IMAGE_TAG} ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    sh "docker push ${AWS_REGION}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
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

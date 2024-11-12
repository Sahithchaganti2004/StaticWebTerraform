pipeline {
    agent any

    environment {
        DOCKERHUB_REPOSITORY = 'chsks2004/myapp'            // Docker Hub repository in the format 'username/repo'
        IMAGE_TAG = "${env.BUILD_ID}"                        // Unique image tag using Jenkins build ID
    }

    stages {
        stage('Checkout') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    git url: 'https://github.com/Sahithchaganti2004/StaticWebTerraform.git', branch: 'main'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    script {
                        docker.build("${DOCKERHUB_REPOSITORY}:${IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                            sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                        }
                        sh "docker push ${DOCKERHUB_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    script {
                        withAWS(region: "us-east-1", credentials: 'aws-credentials') {
                            sh "terraform init -backend-config='bucket=myapp-terraform-state' -backend-config='key=terraform.tfstate'"
                            sh "terraform apply -auto-approve -var 'image_tag=${IMAGE_TAG}'"
                        }
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    script {
                        withAWS(region: "us-east-1", credentials: 'aws-credentials') {
                            sh "aws ecs update-service --cluster myapp-cluster --service myapp-service --force-new-deployment"
                        }
                    }
                }
            }
        }

        stage('Post-Deployment Testing') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    echo "Running post-deployment tests..."
                    // Add testing commands here, if any
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean up workspace after completion
        }
        success {
            echo "Deployment succeeded!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}

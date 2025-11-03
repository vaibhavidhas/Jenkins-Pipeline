pipeline {
    agent any
    
    environment {
        // Docker registry configuration
        DOCKER_REGISTRY = 'docker.io'  // Change to your registry (e.g., 'gcr.io', 'your-registry.com')
        DOCKER_IMAGE_NAME = 'your-username/nodejs-app'  // Change to your image name
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'  // Jenkins credentials ID
        
        // Artifact configuration
        ARTIFACT_URL = 'https://your-artifact-storage.com/artifact.zip'  // Change to your artifact URL
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    
                    // Build the Docker image with build argument
                    docker.build(
                        "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}",
                        "--build-arg ARTIFACT_URL=${ARTIFACT_URL} ."
                    )
                    
                    // Also tag as 'latest'
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo 'Testing Docker image...'
                    
                    // Run a simple test to verify the image works
                    sh """
                        docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} node --version
                    """
                }
            }
        }
        
        stage('Push to Docker Registry') {
            steps {
                script {
                    echo "Pushing image to ${DOCKER_REGISTRY}..."
                    
                    // Login to Docker registry and push
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        // Push the tagged version
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        
                        // Push the latest tag
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    echo 'Cleaning up local images...'
                    
                    // Remove local images to save space
                    sh """
                        docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} || true
                        docker rmi ${DOCKER_IMAGE_NAME}:latest || true
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "Docker image successfully built and pushed!"
            echo "Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            echo "Registry: ${DOCKER_REGISTRY}"
        }
        
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
        
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
pipeline {
    agent any

    environment {
        APP_NAME = "cl-backend"
        DOCKER_USER = "vaibhavi2808"
        DOCKER_REGISTRY = "docker.io"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vaibhavidhas/cl-backend.git'
            }
        }

        stage('Install & Build') {
            steps {
                echo "Installing dependencies and building project..."
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Create Artifact') {
            steps {
                script {
                    env.VERSION = sh(script: "node -p \"require('./package.json').version\"", returnStdout: true).trim()
                }
                sh 'zip -r ${APP_NAME}-${VERSION}.zip dist/'
                archiveArtifacts artifacts: '${APP_NAME}-${VERSION}.zip', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_USER}/${APP_NAME}:${VERSION} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${DOCKER_REGISTRY}"
                    sh "docker push ${DOCKER_USER}/${APP_NAME}:${VERSION}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Successfully built and pushed ${DOCKER_USER}/${APP_NAME}:${VERSION}"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}

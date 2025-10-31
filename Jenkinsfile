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
                git branch: 'main', url: 'https://github.com/vaibhavidhas/Jenkins-Pipeline.git'
            }
        }

        stage('Install & Build') {
            steps {
                echo "Installing dependencies and building project..."
                bat 'npm install'
                bat 'npm run build'
            }
        }

        stage('Create Artifact') {
            steps {
                script {
                    env.VERSION = bat(script: 'node -p "require(\'./package.json\').version"', returnStdout: true).trim()
                }
                bat """
                powershell Compress-Archive -Path dist\\* -DestinationPath ${APP_NAME}-${VERSION}.zip -Force
                """
                archiveArtifacts artifacts: "${APP_NAME}-${VERSION}.zip", fingerprint: true
            }   
        }


        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${DOCKER_USER}/${APP_NAME}:${VERSION} ."
            }
        }

        stage('Pubat Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${DOCKER_REGISTRY}"
                    bat "docker pubat ${DOCKER_USER}/${APP_NAME}:${VERSION}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Successfully built and pubated ${DOCKER_USER}/${APP_NAME}:${VERSION}"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}

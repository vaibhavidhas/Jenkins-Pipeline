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
                echo 'Creating versioned artifact...'
                bat '''
                    for /f "tokens=2 delims=:," %%v in ('findstr "version" package.json') do (
                        set ver=%%~v
                    )
                    set ver=%ver:"=%
                    echo Detected version: %ver%
                    powershell Compress-Archive -Path dist\\* -DestinationPath cl-backend-%ver%.zip -Force
                '''
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

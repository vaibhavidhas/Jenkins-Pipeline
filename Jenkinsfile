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
                bat 'dir dist'
            }
        }

        stage('Create Artifact') {
            steps {
                echo 'Creating versioned artifact...'
                bat '''
                for /F "tokens=2 delims=:," %%v in ('findstr "version" package.json') do (set ver=%%~v)
                set ver=%ver: =%
                echo Detected version: %ver%
                powershell -Command "Compress-Archive -Path 'dist' -DestinationPath 'cl-backend-%ver%.zip' -Force"
                echo VERSION=%ver% >> version.txt
                '''
                script {
                    env.VERSION = readFile('version.txt').trim().split('=')[1].replaceAll('"', '')
                    echo "Pipeline VERSION variable set to ${env.VERSION}"
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t ${DOCKER_USER}/${APP_NAME}:${VERSION} ."
                }
            }
        }

        stage('Publish Docker Image') {
            steps {
                script {
                    bat "docker push ${DOCKER_USER}/${APP_NAME}:${VERSION} ."
                }
            }
        }

    }

    post {
        success {
            echo "✅ Successfully built and published ${DOCKER_USER}/${APP_NAME}:${VERSION}"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
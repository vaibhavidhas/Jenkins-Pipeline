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
                for /F "tokens=2 delims=:," %%v in ('findstr "version" package.json') do (set ver=%%~v)
                set ver=%ver:"=%
                set ver=%ver: =%
                echo Detected version: %ver%
                powershell Compress-Archive -Path dist\\* -DestinationPath cl-backend-%ver%.zip -Force
                echo VERSION=%ver% >> version.txt
                '''
                script {
                    env.VERSION = readFile('version.txt').trim().split('=')[1]
                    echo "Pipeline VERSION variable set to ${env.VERSION}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                bat """
                echo "Building Docker image..."
                docker build --build-arg ARTIFACT_URL=file:///C:/ProgramData/Jenkins/.jenkins/workspace/Jenkins_Pipeline/cl-backend-1.0.4.zip -t vaibhavi2808/cl-backend:1.0.4 .
                """
            }
        }
        stage('Publish Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    echo Logging in to Docker Hub...
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker push %DOCKER_USER%/cl-backend:1.0.4
                    """
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

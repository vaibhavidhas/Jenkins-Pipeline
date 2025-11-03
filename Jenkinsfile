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

                REM Ensure we only zip the dist/server.js file, preserving folder structure (dist/server.js)
                powershell -Command "Compress-Archive -Path (Get-ChildItem -Recurse -Path dist) -DestinationPath cl-backend-%ver%.zip -Force"

                echo VERSION=%ver% >> version.txt
                '''
                script {
                    env.VERSION = readFile('version.txt').trim().split('=')[1]
                    echo "Pipeline VERSION variable set to ${env.VERSION}"
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                    echo Logging into Docker Hub...
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    """
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


FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

ENV APP_HOME=/usr/src/app
ENV NODE_ENV=production
WORKDIR $APP_HOME

# Copy the artifact
COPY ./cl-backend-*.zip artifact.zip

# Unzip the artifact (this will create /usr/src/app/dist/)
RUN unzip artifact.zip && rm artifact.zip

# Install only production dependencies (if needed)
RUN if [ -f package.json ]; then npm install --omit=dev; fi

EXPOSE 3000

ENTRYPOINT ["node", "dist/server.js"]

where should i make changes
Show less
You need to make changes in both files. Here are the specific fixes:

1. Fix the Jenkinsfile
Change the Create Artifact stage to use the correct PowerShell command:

groovy
stage('Create Artifact') {
    steps {
        echo 'Creating versioned artifact...'
        bat '''
        for /F "tokens=2 delims=:," %%v in ('findstr "version" package.json') do (set ver=%%~v)
        set ver=%ver: =%
        echo Detected version: %ver%

        REM Create zip with proper path separators
        powershell -Command "Compress-Archive -Path 'dist' -DestinationPath 'cl-backend-%ver%.zip' -Force"

        echo VERSION=%ver% >> version.txt
        '''
        script {
            env.VERSION = readFile('version.txt').trim().split('=')[1].replaceAll('"', '')
            echo "Pipeline VERSION variable set to ${env.VERSION}"
        }
    }
}
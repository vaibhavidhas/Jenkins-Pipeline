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
            bat '''
            powershell -NoProfile -Command ^
              "$p = Get-Content -Raw package.json | ConvertFrom-Json; ^
               $ver = $p.version; ^
               Write-Host \"Detected version: $ver\"; ^
               $zipName = \"cl-backend-$ver.zip\"; ^
               if (Test-Path $zipName) { Remove-Item $zipName -Force }; ^
               Compress-Archive -Path 'dist' -DestinationPath $zipName -Force; ^
               Write-Output \"VERSION=$ver\" | Out-File -Encoding ascii version.txt"
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



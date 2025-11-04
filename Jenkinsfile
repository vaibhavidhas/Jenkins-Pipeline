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

        stage('Read Version') {
            steps {
                script {
                    def pkg = readJSON file: 'package.json'
                    env.VERSION = pkg.version
                    echo "📦 Version set to ${env.VERSION}"
                }
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

stage('Package Artifact') {
    steps {
        echo "📦 Creating versioned artifact..."
        powershell '''
            $version = (Get-Content package.json | ConvertFrom-Json).version.Trim('"')
            $artifact = "cl-backend-$version.zip"

            if (Test-Path $artifact) { Remove-Item $artifact }

            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::CreateFromDirectory("dist", $artifact)

            # Normalize paths inside the ZIP
            $tempDir = "zip_normalized"
            if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
            Expand-Archive -Path $artifact -DestinationPath $tempDir -Force
            Remove-Item $artifact
            Compress-Archive -Path (Get-ChildItem -Recurse $tempDir | ForEach-Object { $_.FullName -replace '\\\\', '/' }) -DestinationPath $artifact -Force

            Write-Host "✅ Linux-friendly ZIP created: $artifact"
        '''
    }
}

        stage('Archive Artifact') {
            steps {
                echo "Archiving build artifact..."
                archiveArtifacts artifacts: "cl-backend-${VERSION}.zip", fingerprint: true
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
                echo "🛠 Building Docker image using local artifact..."
                bat """
                    copy cl-backend-%VERSION%.zip .\\artifact.zip
                    docker build --build-arg ARTIFACT_FILE=artifact.zip -t %DOCKER_USER%/%APP_NAME%:%VERSION% .
                """
            }
        }

        stage('Publish Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                        echo Logging in to Docker Hub...
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_USER%/%APP_NAME%:%VERSION%
                    """
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

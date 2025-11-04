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
        echo "📦 Creating versioned artifact (with dist folder)..."
        powershell '''
            $version = (Get-Content package.json | ConvertFrom-Json).version
            $artifact = "cl-backend-$version.zip"

            if (Test-Path $artifact) { Remove-Item $artifact }

            # Prepare temp folder containing dist/
            $temp = "temp_zip_dir"
            if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
            New-Item -ItemType Directory -Path $temp | Out-Null
            Copy-Item -Recurse dist $temp/dist

            # Create ZIP (with dist folder included)
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::CreateFromDirectory($temp, $artifact)

            # Cleanup temp folder
            Remove-Item $temp -Recurse -Force

            Write-Host "✅ Artifact created: $artifact"
            Write-Host "📂 Verifying ZIP contents..."
            Expand-Archive -Path $artifact -DestinationPath "verify_zip_final" -Force
            Get-ChildItem -Recurse "verify_zip_final"
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

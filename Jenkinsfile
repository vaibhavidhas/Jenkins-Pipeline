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
stage('Package Artifact') {
    steps {
        echo "📦 Creating versioned artifact (with dist folder)..."
        powershell '''
            Write-Host "📦 Creating versioned artifact (with dist folder)..."
            $version = (Get-Content package.json | ConvertFrom-Json).version
            $artifact = "cl-backend-$version.zip"

            Add-Type -AssemblyName System.IO.Compression.FileSystem

            if (Test-Path $artifact) { Remove-Item $artifact }

            [System.IO.Compression.ZipFile]::CreateFromDirectory("dist", $artifact)

            Write-Host "✅ Artifact created: $artifact"

            # Output version for Jenkins to capture
            Write-Output "VERSION=$version" | Out-File -FilePath version.txt -Encoding UTF8
        '''
        script {
            env.VERSION = readFile('version.txt').trim().split('=')[1]
            echo "✅ Pipeline VERSION variable set to ${env.VERSION}"
        }
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



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
        echo "📦 Creating versioned artifact (including dist folder)..."
        powershell '''
            Write-Host "📦 Creating versioned artifact (including dist folder)..."
            $version = (Get-Content package.json | ConvertFrom-Json).version
            $artifact = "cl-backend-$version.zip"

            # Clean up previous zips if any
            if (Test-Path $artifact) { Remove-Item $artifact -Force }

            # Create a temporary folder to hold dist/
            $tempDir = "package_temp"
            if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
            New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

            # Copy the dist folder inside it
            Copy-Item -Recurse -Path "dist" -Destination $tempDir

            # Load compression library
            Add-Type -AssemblyName System.IO.Compression.FileSystem

            # Create the zip (now contains the dist/ directory)
            [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $artifact)

            # Cleanup temp directory
            Remove-Item $tempDir -Recurse -Force

            Write-Host "✅ Artifact created: $artifact"

            # Optional verification
            if (Test-Path verify_zip) { Remove-Item verify_zip -Recurse -Force }
            Expand-Archive -Path $artifact -DestinationPath verify_zip -Force
            Write-Host "📂 Verifying ZIP contents..."
            Get-ChildItem -Recurse verify_zip

            # Export version for Jenkins
            "VERSION=$version" | Out-File -Encoding ascii version.txt
        '''
        script {
            env.VERSION = readFile('version.txt').trim().split('=')[1]
            echo "✅ VERSION set to ${env.VERSION}"
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



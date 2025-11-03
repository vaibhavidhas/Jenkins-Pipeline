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
            # Ensure we are at project root (one level above dist)
            if (-not (Test-Path "dist/server.js")) {
                Write-Host "⚠️ dist/server.js not found — changing to parent directory..."
                Set-Location ..
                if (-not (Test-Path "dist/server.js")) {
                    Write-Error "❌ dist folder not found in expected location!"
                    exit 1
                }
            }

            # Read version from package.json
            $p = Get-Content -Raw "package.json" | ConvertFrom-Json
            $ver = $p.version.Trim()
            Write-Host "Detected version: $ver"

            # Save version to version.txt for Jenkins
            "VERSION=$ver" | Out-File -Encoding ascii version.txt

            # Define zip name
            $zipPath = "cl-backend-$ver.zip"

            # Remove old zip if exists
            if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

        # Fix Windows backslashes in ZIP paths
$zipTemp = Join-Path $env:TEMP "artifact.zip"
if (Test-Path $zipTemp) { Remove-Item $zipTemp -Force }

Compress-Archive -Path (Get-ChildItem -Recurse -Path "dist" | ForEach-Object { $_.FullName -replace '\\\\', '/' }) -DestinationPath $zipTemp -Force
Copy-Item $zipTemp $zipPath -Force
Remove-Item $zipTemp -Force


            # Verify ZIP content for debugging
            Write-Host "📦 Verifying ZIP contents..."
            Expand-Archive -Path $zipPath -DestinationPath "verify_zip" -Force
            Get-ChildItem -Recurse "verify_zip"

            Write-Host "✅ Artifact created: $zipPath"
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
        bat '''
            echo "Building Docker image..."
            bat "copy cl-backend-%VERSION%.zip ."
            docker build -t vaibhavi2808/cl-backend:%VERSION% .
        '''
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



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
            # Ensure we are at project root
            if (-not (Test-Path "dist/server.js")) {
                Write-Host "⚠️ dist/server.js not found — changing to parent directory..."
                Set-Location ..
                if (-not (Test-Path "dist/server.js")) {
                    Write-Error "❌ dist folder not found!"
                    exit 1
                }
            }

            # Read version
            $p = Get-Content -Raw "package.json" | ConvertFrom-Json
            $ver = $p.version.Trim()
            Write-Host "Detected version: $ver"
            "VERSION=$ver" | Out-File -Encoding ascii version.txt

            # Define output file
            $zipPath = "cl-backend-$ver.zip"

            # Use a UNIQUE temp zip name to avoid conflicts
            $tempZip = Join-Path $env:TEMP ("artifact_{0}.zip" -f (Get-Random))

            # Cleanup any old files
            if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
            if (Test-Path $tempZip) { Remove-Item $tempZip -Force }

            # Create zip (includes full dist folder)
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::CreateFromDirectory("dist", $tempZip)
            Copy-Item $tempZip $zipPath -Force
            Remove-Item $tempZip -Force

            # Verify contents
            Write-Host "📦 Verifying ZIP contents..."
            if (Test-Path "verify_zip") { Remove-Item "verify_zip" -Recurse -Force }
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



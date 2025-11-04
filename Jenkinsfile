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
        echo "📦 Creating versioned artifact (keeping dist/ folder)..."
        bat '''
        REM === Read version from package.json ===
        for /f "tokens=2 delims=:," %%v in ('findstr "version" package.json') do set VERSION=%%~v
        set VERSION=%VERSION:"=%

        echo Version detected: %VERSION%

        REM === Clean old zips ===
        if exist cl-backend-%VERSION%.zip del /f cl-backend-%VERSION%.zip

        REM === Use PowerShell to zip dist folder INCLUDING folder name ===
        powershell -NoLogo -NoProfile -Command ^
          "$version = '%VERSION%';" ^
          "$src = 'dist';" ^
          "$temp = 'package_temp';" ^
          "$dest = 'cl-backend-' + $version + '.zip';" ^
          "if (Test-Path $temp) { Remove-Item -Recurse -Force $temp };" ^
          "New-Item -ItemType Directory -Path $temp | Out-Null;" ^
          "Copy-Item -Recurse $src $temp\\dist;" ^
          "Add-Type -AssemblyName 'System.IO.Compression.FileSystem';" ^
          "[System.IO.Compression.ZipFile]::CreateFromDirectory($temp, $dest);" ^
          "Remove-Item -Recurse -Force $temp;" ^
          "Write-Host '✅ Artifact created:' $dest;"
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
                     docker build --build-arg ARTIFACT_FILE=cl-backend-%VERSION%.zip -t %DOCKER_USER%/%APP_NAME%:%VERSION% .
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

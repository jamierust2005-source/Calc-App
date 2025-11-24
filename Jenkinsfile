pipeline {
    agent {
        docker {
            image 'python:3.11-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Install deps') {
            steps {
                sh '''
                  python --version
                  pip install --break-system-packages pytest
                '''
            }
        }

        stage('Run tests') {
            steps {
                sh 'pytest -q'
            }
        }

        stage('Build Docker image') {
            steps {
                sh "docker build -t calc:${env.BUILD_NUMBER} ."
            }
        }
    }
}

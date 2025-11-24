pipeline {
    agent any   // IMPORTANT: no docker {} here

    stages {
        stage('Show environment') {
            steps {
                sh '''
                  echo "PATH = $PATH"
                  which python3 || echo "python3 not found"
                  which docker || echo "docker not found"
                '''
            }
        }

        stage('Set up venv & install pytest') {
            steps {
                sh '''
                  set -e
                  python3 -m venv venv
                  . venv/bin/activate
                  pip install --upgrade pip
                  pip install pytest
                '''
            }
        }

        stage('Run tests') {
            steps {
                sh '''
                  set -e
                  . venv/bin/activate
                  pytest -q
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                sh '''
                  set -e
                  docker --version
                  docker build -t calc:${BUILD_NUMBER} .
                '''
            }
        }
    }
}

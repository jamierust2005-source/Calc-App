// Jenkins Declarative Pipeline for the calculator project
//
// This pipeline demonstrates how to check out code from a Git repository,
// run a simple Python script as a build step, and build a Docker image
// from the repository's Dockerfile.  When integrated with GitHub, this
// pipeline will run automatically whenever new commits are pushed (via a
// webhook).  The Docker Pipeline plugin must be installed for the
// `docker.build` syntax to work.

pipeline {
    // Use a Docker container with Python installed as the build agent.
    // Mount the host's Docker socket so that Docker commands executed in
    // the pipeline can communicate with the Docker daemon on the host.
    agent {
        docker {
            image 'python:3.11-slim'
            args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from the configured repository.
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                // Ensure pytest is installed in the build environment.  The
                // --no-cache-dir flag reduces the size of the layer and avoids
                // caching wheels between runs.
                sh 'pip install --no-cache-dir pytest'
            }
        }

        stage('Run tests') {
            steps {
                // Execute the unit tests.  Pytest will discover tests in
                // files matching ``test_*.py``.  A non‑zero exit status
                // causes the build to fail.
                sh 'pytest -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build a Docker image using the Dockerfile in the
                    // repository.  The resulting image will be tagged with
                    // the Jenkins build number.  The built image can be
                    // pushed to a registry if desired by calling `push()`.
                    def img = docker.build("calculator-app:${env.BUILD_NUMBER}")
                    echo "Built Docker image ${img.id}"
                    // Optionally push the image to a registry:
                    // img.push('latest')
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
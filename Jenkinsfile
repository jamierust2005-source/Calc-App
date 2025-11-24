// Jenkins Declarative Pipeline for the calculator project
//
// This pipeline demonstrates how to check out code from a Git repository,
// run a simple Python script as a build step, and build a Docker image
// from the repository's Dockerfile.  When integrated with GitHub, this
// pipeline will run automatically whenever new commits are pushed (via a
// webhook).  The Docker Pipeline plugin must be installed for the
// `docker.build` syntax to work.

pipeline {
    // Use any available agent (the Jenkins controller) for this build.  The
    // custom Jenkins image includes Python, pip and the docker CLI, so we can
    // run Python commands and build Docker images without needing a nested
    // Docker agent.
    agent any

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
                // --break-system-packages flag allows installation in the
                // system Python when the environment is marked as externally
                // managed (PEP 668).  Without this flag pip would refuse
                // to install packages globally.
                sh 'pip install --break-system-packages --no-cache-dir pytest'
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
                // Build a Docker image using the Dockerfile in the repository.
                // Tag the image with the Jenkins build number.  Because the
                // Jenkins container includes the docker CLI and mounts the
                // host’s Docker socket, this command can talk to the host
                // Docker daemon directly.  Specify the full path to the
                // Docker binary to avoid PATH issues.
                sh "/usr/bin/docker build -t calculator-app:${env.BUILD_NUMBER} ."
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
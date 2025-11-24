# Jenkins CI/CD Pipeline for a Python Calculator

## Overview

This project demonstrates how to build and test a small Python application with Jenkins using a declarative pipeline.  When you commit changes to your GitHub repository, a webhook triggers Jenkins to check out the code, install dependencies, run unit tests with `pytest`, and build a Docker image from the repository’s `Dockerfile`.

The solution uses Docker to run both the Jenkins controller and the pipeline’s build agent.  The provided Docker Compose configuration builds a **custom Jenkins image** (via `jenkins.Dockerfile`) that pre‑installs the Pipeline (`workflow‑aggregator`), Docker (`docker‑workflow`) and GitHub plugins, ensuring that the **Pipeline** job type is available immediately.  By mounting the host’s Docker socket into Jenkins, the pipeline can invoke Docker commands to build images.  The instructions below guide you through setting up Jenkins, configuring GitHub, and verifying that the pipeline works end‑to‑end.

## Key Concepts

- **GitHub webhooks** – On your GitHub repository’s **Settings** > **Webhooks** page, you can add a webhook pointing to `http://<jenkins‑host>:8080/github-webhook/` with the content type `application/json`.  The Jenkins documentation notes that you should choose the “Pushes” event when configuring which events trigger the webhook【195438494564866†L242-L251】.  When GitHub sends a webhook on a push event, Jenkins starts a build.
- **Running Python scripts in Jenkins** – A Jenkins build step simply calls the Python interpreter in a shell.  The Digital.ai Jenkins documentation for Python jobs explains that you can add an “Execute Shell” step and run a command like `python -m unittest ...`【268160408836039†L88-L100】.  In a Jenkins pipeline, the `sh` step performs the same function.
- **Building Docker images with the Docker Pipeline plugin** – The Jenkins documentation explains that the `docker.build()` method creates a new image from the `Dockerfile` in the repository and returns an image object that can be pushed to a registry【713532891104427†L470-L516】.  Tagging the image with `env.BUILD_NUMBER` makes each build unique.

## Directory Structure

| File                      | Purpose |
|--------------------------|---------|
| **calculator.py**        | A command‑line calculator supporting add, subtract, multiply and divide operations.  It prints the result or an error if dividing by zero. |
| **Dockerfile**           | Defines a minimal container based on `python:3.11-slim` that runs `calculator.py` as its entrypoint. |
| **Jenkinsfile**          | Declarative pipeline that installs dependencies, runs unit tests using `pytest`, and calls `docker.build()` to build a Docker image. |
| **test_calculator.py**   | Pytest unit tests that verify the calculator functions. |
| **docker-compose.yml**   | Builds and starts a custom Jenkins controller with the Pipeline, GitHub and Docker plugins already installed, then mounts `/var/run/docker.sock` from the host so that pipeline steps can access Docker. |
| **jenkins.Dockerfile**   | Custom Dockerfile that extends `jenkins/jenkins:lts`, installs Python and pip, and uses `jenkins-plugin-cli` to install the Pipeline (`workflow‑aggregator`), Docker (`docker‑workflow`) and GitHub plugins. |

## Setup Instructions

### 1. Prepare the Environment

1. Ensure **Docker** and **Docker Compose** are installed on your host.
2. Clone your fork of this repository and navigate into the directory:

   ```bash
   git clone <your‑fork‑url>.git
   cd jenkins_calculator_pipeline
   ```

3. Build and start Jenkins using Docker Compose:

   ```bash
   docker compose up -d
   ```

   This command builds the custom Jenkins image defined in `jenkins.Dockerfile`, runs the Jenkins controller in a container, maps port 8080 to the host, and mounts the host’s Docker socket so that pipeline steps can build images.

4. Retrieve the initial admin password by running:

   ```bash
   docker exec -it jenkins-calculator cat /var/jenkins_home/secrets/initialAdminPassword
   ```

   Use this password to log in to Jenkins at `http://localhost:8080`.  Because the custom image pre‑installs the Pipeline (`workflow‑aggregator`), Docker (`docker‑workflow`) and GitHub plugins, the **Pipeline** job type will appear under **New Item** without further plugin installation.  You may still install any additional suggested plugins, but the essentials are already present.  The Docker Pipeline plugin makes the `docker.build()` method available【713532891104427†L470-L511】.

### 2. Configure Jenkins

1. In Jenkins, create a **Pipeline** job and point it to your GitHub repository under **Pipeline script from SCM**.
2. In the **Build Triggers** section, enable **GitHub hook trigger for GITScm polling**.  This tells Jenkins to listen for webhook events rather than poll the repository.
3. If your repository is private, add credentials under **Credentials** and configure the job to use them.

### 3. Configure GitHub Webhook

1. In your GitHub repository, navigate to **Settings** → **Webhooks** and click **Add webhook**.
2. Set the **Payload URL** to `http://<jenkins‑host>:8080/github-webhook/` and choose the content type **application/json**【195438494564866†L242-L246】.
3. Select **Let me select individual events** and tick **Pushes** (and optionally pull requests)【195438494564866†L248-L251】.
4. Save the webhook.  Whenever you push a commit, GitHub will call Jenkins to trigger the pipeline.

## How the Pipeline Works

1. **Checkout** – The `checkout scm` step clones your GitHub repository into the workspace.
2. **Install dependencies** – The pipeline calls `pip install --no-cache-dir pytest` to ensure that the `pytest` framework is available inside the agent container.  Additional dependencies can be installed similarly.
3. **Run tests** – The pipeline invokes `pytest -v` to execute the tests in `test_calculator.py`.  If any test fails, the build stops.  Running Python commands in Jenkins simply requires invoking the interpreter in a shell step【268160408836039†L88-L100】.
4. **Build Docker Image** – Finally, the pipeline executes `docker build -t calculator-app:${env.BUILD_NUMBER} .` to build a container from the repository’s `Dockerfile`.  Because the custom Jenkins image installs the Docker CLI and mounts the host’s Docker socket, this command communicates directly with the host’s Docker daemon to build the image.  If you prefer to use the Docker Pipeline plugin instead, you can substitute this step with `docker.build()` and call `push()` as explained in the Jenkins documentation【713532891104427†L470-L516】.

After a successful build, you can see the new Docker image on the host by running `docker images`.  If you wish to push the image to Docker Hub or another registry, wrap the build in `docker.withRegistry()` and call `img.push()`, supplying appropriate credentials【713532891104427†L594-L626】.

## Files for Download

You can download the complete project—including the Python script, Jenkinsfile, Dockerfile, and Docker Compose configuration—using the following tarball:

{{file:file-JpKDeCK4YSfYhWHp2GZaEA}}

## Conclusion

This example shows how to combine GitHub, Jenkins and Docker into a simple CI/CD pipeline.  Pushing code to your GitHub repository triggers a Jenkins build via a webhook; the build runs Python code and produces a Docker image using the Docker Pipeline plugin.  By following this pattern, you can expand the pipeline to include testing, security scans and deployment as needed.
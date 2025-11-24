# Jenkins Calculator Pipeline

This repository contains a tiny Python application, a `Dockerfile` that
packages the application into a container, and a declarative
`Jenkinsfile` that demonstrates a simple CI/CD pipeline.  The goal of
this project is to show how to run a Jenkins pipeline inside a
Dockerized Jenkins controller, execute a Python script during the
build, and build a Docker image as the final stage.  The pipeline is
designed to be triggered automatically whenever new commits are pushed
to a GitHub repository via a webhook.

## Contents

| File                       | Purpose                                                       |
|---------------------------|---------------------------------------------------------------|
| `calculator.py`           | A command‑line calculator that supports add/subtract/multiply/divide operations. |
| `Dockerfile`              | Defines a minimal image based on `python:3.11-slim` that runs the calculator script. |
| `Jenkinsfile`             | Declarative pipeline that installs dependencies, runs unit tests with `pytest`, and builds a Docker image using the Docker CLI. |
| `test_calculator.py`      | Pytest unit tests that verify the behavior of the calculator functions. |
| `docker-compose.yml`      | Builds and starts a custom Jenkins controller with the Pipeline, GitHub and Docker plugins already installed, and mounts the host’s Docker socket so that the pipeline can build images. |
| `jenkins.Dockerfile`      | Custom Dockerfile that extends `jenkins/jenkins:lts`, installs Python and pip, and preinstalls the Pipeline, Docker and GitHub plugins using `jenkins-plugin-cli`. |

## Prerequisites

* **Docker and Docker Compose** installed on your host machine.  On Linux, ensure that your user can access `/var/run/docker.sock` (by adding it to the `docker` group or running with `sudo`).
* An available TCP port (default is 8080) for the Jenkins web UI.
* A GitHub account and a repository that will contain this code.  You should push the contents of this directory to a GitHub repository of your own.

## Running Jenkins

1. Clone this repository to your local machine and change into the directory:

   ```bash
   git clone <your‑fork‑url>.git
   cd jenkins_calculator_pipeline
   ```

2. Build and start Jenkins using the provided `docker-compose.yml`:

   ```bash
   docker compose up -d
   ```

   This will download the `jenkins/jenkins:lts` image, create a
   persistent volume at `jenkins_home`, map port 8080, and mount
   `/var/run/docker.sock` so that the pipeline can build Docker images.

3. After the container starts, browse to <http://localhost:8080>.  To obtain the initial administrator password, run:

   ```bash
   docker exec -it jenkins-calculator cat /var/jenkins_home/secrets/initialAdminPassword
   ```

4. Log in using that password.  Because the custom image pre‑installs the required plugins (`workflow‑aggregator`, `docker‑workflow` and `github`), the **Pipeline** job type will be available immediately under **New Item**.  You may still wish to install any additional suggested plugins, but the essentials are already present.  The Docker CLI is also installed inside the Jenkins container so that the pipeline can build images without additional tools.

## Creating the Pipeline Job

1. In Jenkins, click **“New Item”**, give the job a name (e.g. *calculator-pipeline*), and select **“Pipeline”**.
2. Under **Pipeline** > **Definition**, select **“Pipeline script from SCM”**.  Choose **Git** and provide the URL of your GitHub repository.
3. Under **Build Triggers**, check **“GitHub hook trigger for GITScm polling”**.  This tells Jenkins to listen for GitHub webhook events rather than polling.

## Configuring GitHub

1. Push the contents of this directory to a new GitHub repository.
2. In the GitHub repository, navigate to **Settings** > **Webhooks** and click **“Add webhook”**.
3. In the **Payload URL** field, enter your Jenkins URL with a `/github-webhook/` suffix (for example, `http://<your‑host>:8080/github-webhook/`).  Use the content type **`application/json`**【195438494564866†L242-L246】.  Leave the secret empty for a test setup.
4. Under **Which events would you like to trigger this webhook?**, choose **“Let me select individual events.”**  Select **Pushes** (and optionally **Pull Requests**)【195438494564866†L248-L251】.
5. Click **Add webhook**.  From now on, each push to the repository will trigger the Jenkins job.

## What the Pipeline Does

When a commit is pushed to the repository, Jenkins runs the declarative pipeline defined in `Jenkinsfile`.  The custom Jenkins image includes Python, pip and the Docker CLI, so the build runs directly on the Jenkins controller without needing a separate container.  The stages are:

1. **Checkout** – Jenkins checks out the latest code from your GitHub repository (`checkout scm`).
2. **Install dependencies** – The pipeline executes `pip install --break-system-packages pytest` to install the `pytest` framework.  The `--break-system-packages` flag allows installation in Debian’s externally‑managed Python environment (PEP 668).
3. **Run tests** – Pytest is invoked via `pytest -v` to run all tests in `test_calculator.py`.  If any test fails, the build stops.  Running Python commands in Jenkins is simply a matter of invoking the interpreter in a shell step【268160408836039†L88-L100】.
4. **Build Docker image** – Finally, the pipeline builds a Docker image from the repository’s `Dockerfile` using the command `docker build -t calculator-app:${env.BUILD_NUMBER} .`.  Because the Jenkins container has the Docker CLI installed and mounts the host’s Docker socket, it can build images directly.  If you prefer to use the Docker Pipeline plugin instead of the CLI, you can call `docker.build()` and `push()` as described in the Jenkins documentation【713532891104427†L470-L516】.

After a successful build, you will see the new image tagged with the Jenkins build number when you run `docker images` on the host.

## Notes

* The Jenkins controller is configured to run as the root user to simplify access to the Docker socket.  In a production environment, you should tighten security by following best practices, such as using a dedicated Docker group and controlling which agents can build images.
* For GitHub Enterprise or self‑hosted installations, adjust the webhook URL accordingly and ensure that Jenkins can receive inbound HTTP requests from GitHub.
* The `Dockerfile` included here only packages the `calculator.py` script.  You can modify it to include dependencies, tests, or additional files as needed.
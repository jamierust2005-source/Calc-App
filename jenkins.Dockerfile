# Custom Jenkins image that installs required plugins and Python.
#
# This Dockerfile extends the official Jenkins LTS image, adds Python and
# Pip, and installs Jenkins plugins non‑interactively using the
# ``jenkins-plugin-cli``.  Installing the workflow-aggregator plugin
# enables the Pipeline job type, and docker-workflow provides the
# `docker.build()` step used in the Jenkinsfile.

FROM jenkins/jenkins:lts

# Use root for installing packages and plugins
USER root

# Install Python 3 and pip.  The base image is Debian-based so we can use apt-get.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip docker.io \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a docker group (matching typical host group) and add the Jenkins user to
# it so that the Jenkins process can communicate with the Docker daemon via
# /var/run/docker.sock.  Also ensure that the `docker` command points to
# `docker.io` if the Debian package installs the binary with a suffix.  The
# symbolic link is created only if it doesn't already exist.
RUN set -eux; \
    if ! getent group docker; then groupadd --gid 994 docker; fi; \
    usermod -aG docker jenkins; \
    if [ -f /usr/bin/docker.io ] && [ ! -f /usr/bin/docker ]; then ln -s /usr/bin/docker.io /usr/bin/docker; fi

# Install Jenkins plugins.  The jenkins-plugin-cli is available in the base
# image and will install dependencies automatically.  See Jenkins docs for
# details on plugin installation.
RUN jenkins-plugin-cli --plugins \
        workflow-aggregator \
        docker-workflow \
        github

# Switch back to the jenkins user
USER jenkins
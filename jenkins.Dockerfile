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
    && apt-get install -y --no-install-recommends python3 python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Jenkins plugins.  The jenkins-plugin-cli is available in the base
# image and will install dependencies automatically.  See Jenkins docs for
# details on plugin installation.
RUN jenkins-plugin-cli --plugins \
        workflow-aggregator \
        docker-workflow \
        github

# Switch back to the jenkins user
USER jenkins
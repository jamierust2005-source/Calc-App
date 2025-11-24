FROM jenkins/jenkins:lts

USER root

# Install Docker CLI and Python tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       docker.io \
       python3 \
       python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Make sure docker is on PATH and named `docker`
RUN if [ ! -x /usr/bin/docker ] && [ -x /usr/bin/docker.io ]; then \
      ln -s /usr/bin/docker.io /usr/bin/docker; \
    fi

# Add jenkins user to docker group so it can talk to the daemon
RUN groupadd -f docker && usermod -aG docker jenkins

USER jenkins

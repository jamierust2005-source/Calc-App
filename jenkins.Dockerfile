FROM jenkins/jenkins:lts

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       docker.io \
       python3 \
       python3-venv \
       python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Ensure docker cli is named 'docker'
RUN if [ ! -x /usr/bin/docker ] && [ -x /usr/bin/docker.io ]; then \
      ln -s /usr/bin/docker.io /usr/bin/docker; \
    fi

# Let Jenkins talk to docker socket (if you mount it)
RUN groupadd -f docker && usermod -aG docker jenkins

USER jenkins

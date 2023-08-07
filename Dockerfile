# Use Ubuntu as base
FROM ubuntu:20.04

# Set work directory
WORKDIR /usr/src/app

# Declare Ubuntu settings
ARG DEBIAN_FRONTEND=noninteractive

# Use bash for all RUN commands
SHELL ["/bin/bash", "-lc"]

# Declare specific versions
ENV PYTHON_VERSION=3.9.17
ENV PYTHON_MAJOR=3.9
ENV POETRY_VERSION=1.1.7
ENV NVM_VERSION=0.39.0
ENV NODE_VERSION=18.17.0
ENV GO_VERSION=1.20.3
ENV AWS_CLI_VERSION=2.13.7
ENV KUBECTL_VERSION=1.27.1
ENV HELM_VERSION=3.12.2
ENV TERRAFORM_VERSION=1.5.4
ENV TERRAGRUNT_VERSION=0.48.6
ENV SOPS_VERSION=3.7.3
ENV ARGOCD_VERSION=2.7.10

# Update and install apt packages
RUN apt-get update -qq && apt-get clean && \
    apt-get install -y --no-install-recommends \
        git \
        tzdata \
        curl \
        wget \
        libssl-dev\
        openssl \
        gnupg \
        unzip \
        jq \
        gettext \
        build-essential \
        libbz2-dev \
        libc6-dev \
        libgdbm-dev \
        libffi-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libnode-dev \
        llvm \
        make \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
        ca-certificates \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen "en_US.UTF-8"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Install yq
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH} -O /usr/bin/yq &&\
    chmod u+x /usr/bin/yq && \
    yq --version

# Set the desired version of Python
ARG PYTHON_VERSION=${PYTHON_VERSION}
ARG PYTHON_MAJOR=${PYTHON_MAJOR}
# Download and compile Python from source
RUN mkdir /usr/src/python && \
    cd /usr/src/python && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xvf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    rm -rf /usr/src/python && \
    ln -s /usr/local/bin/python${PYTHON_MAJOR} /usr/local/bin/python && \
    ln -s /usr/local/bin/python${PYTHON_MAJOR} /usr/local/bin/python3 && \
    python --version && python3 --version

# Install pip
ARG PIP_ROOT_USER_ACTION=ignore
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    chmod u+x get-pip.py && \
    python3 get-pip.py && \
    pip --version && pip3 --version

# Install poetry
ARG POETRY_VERSION=${POETRY_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    ln -f $HOME/.local/bin/poetry /usr/bin/poetry && \
    poetry --version

# Install AWS CLI v2
ARG AWS_CLI_VERSION=${AWS_CLI_VERSION}
RUN export ARCH=$(uname -m) && \
    if [ "${ARCH}" = "x86_64" ]; then export ARCH="x86_64"; \
    elif [ "${ARCH}" = "aarch64" ]; then export ARCH="aarch64"; \
    else echo "Unsupported architecture"; exit 1; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \    
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip ./aws  && \
    aws --version

# Install Node.js y npm with NVM
ARG NODE_VERSION=${NODE_VERSION}
ARG NVM_VERSION=${NVM_VERSION}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && \
    NVM_DIR="/root/.nvm" && \
    . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} && \
    . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} && \
    . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION} && \
    PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}" && \
    npm install -g npm yarn && \
    ln -s /root/.nvm/versions/node/v${NODE_VERSION}/bin/node /usr/local/bin/node && \
    ln -s /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm /usr/local/bin/npm && \
    ln -s /root/.nvm/versions/node/v${NODE_VERSION}/bin/yarn /usr/local/bin/yarn && \
    node --version && \
    npm --version && \
    yarn --version

# Install Go
ARG GO_VERSION=${GO_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sL https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz \
    | tar xzvf - --directory /usr/local/ && \ 
    ln -f /usr/local/go/bin/go /usr/bin/go && \
    go version

# Install kubectl
ARG KUBECTL_VERSION=${KUBECTL_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl && \
    chmod +x kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    kubectl version --client

# Install helm
ARG HELM_VERSION=${HELM_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar zx && \
    mv linux-${ARCH}/helm /usr/local/bin/helm && \
    rm -rf linux-${ARCH} && \
    helm version

# Install Terraform
ARG TERRAFORM_VERSION=${TERRAFORM_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip -o terraform.zip && \
    unzip terraform.zip && \
    install -o root -g root -m 0755 terraform /usr/local/bin/terraform && \
    rm terraform.zip terraform && \
    terraform --version

# Install Terragrunt
ARG TERRAGRUNT_VERSION=${TERRAGRUNT_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sSL https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${ARCH} -o terragrunt && \
    install -o root -g root -m 0755 terragrunt /usr/local/bin/terragrunt && \
    rm terragrunt && \
    terragrunt --version

# Install SOPS
ARG SOPS_VERSION=${SOPS_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    wget --progress=dot:giga -O /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCH} && \
    chmod +x /usr/local/bin/sops && \
    sops --version

# Install ArgoCD
ARG ARGOCD_VERSION=${ARGOCD_VERSION}
RUN set -ex && \
    ARCH=$(arch | sed 's|x86_64|amd64|g' | sed 's|aarch64|arm64|g') && \
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-${ARCH} && \
    chmod +x /usr/local/bin/argocd && \
    argocd version --client

# Export PATH
ENV PATH="/usr/local/bin:${PATH}"

# Clean APT
RUN apt-get purge -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

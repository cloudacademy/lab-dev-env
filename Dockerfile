FROM ghcr.io/cloudacademy/ca-code-server:latest

USER coder

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip jq wget -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Branding: Set custom favicon
COPY deploy-container/favicon.ico /usr/lib/code-server/src/browser/media/favicon.ico
RUN sudo cp /usr/lib/code-server/src/browser/media/favicon.ico /usr/lib/code-server/src/browser/media/favicon.svg && \
    sudo cp /usr/lib/code-server/src/browser/media/favicon.ico /usr/lib/code-server/src/browser/media/favicon-dark-support.svg && \
    sudo cp /usr/lib/code-server/src/browser/media/favicon.ico /usr/lib/code-server/lib/vscode/resources/server/favicon.ico && \
    sudo cp /usr/lib/code-server/src/browser/media/favicon.ico /usr/lib/code-server/lib/vscode/extensions/microsoft-authentication/media/favicon.ico && \
    sudo cp /usr/lib/code-server/src/browser/media/favicon.ico /usr/lib/code-server/lib/vscode/extensions/github-authentication/media/favicon.ico

# Copy in custom config (disable password authentication)
COPY deploy-container/config.yaml .config/code-server/config.yaml

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local && \
    sudo chown -R coder:coder /home/coder/.config

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension from OpenVSX Registry:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# Use multiple --install-extension flags to install multiple extensions
RUN code-server \
    --install-extension 4ops.terraform \
    --install-extension DavidAnson.vscode-markdownlint \
    --install-extension dbaeumer.vscode-eslint \
    --install-extension DotJoshJohnson.xml \
    --install-extension foxundermoon.shell-format \
    --install-extension hashicorp.terraform \
    --install-extension ms-azuretools.vscode-docker \
    --install-extension ms-dotnettools.vscode-dotnet-runtime \
    --install-extension ms-python.python \
    --install-extension ms-toolsai.jupyter \
    --install-extension ms-toolsai.jupyter-keymap \
    --install-extension ms-toolsai.jupyter-renderers \
    --install-extension ms-toolsai.vscode-jupyter-cell-tags \
    --install-extension ms-toolsai.vscode-jupyter-slideshow \
    --install-extension ms-vscode.azure-account \
    --install-extension redhat.java \
    --install-extension redhat.vscode-commons \
    --install-extension redhat.vscode-yaml \
    --install-extension samuelcolvin.jinjahtml \
    --install-extension streetsidesoftware.code-spell-checker \
    --install-extension telesoho.vscode-markdown-paste-image \
    --install-extension VisualStudioExptTeam.intellicode-api-usage-examples \
    --install-extension VisualStudioExptTeam.vscodeintellicode \
    --install-extension vsls-contrib.codetour

RUN mkdir -p /home/coder/.local/share/code-server/extensions/foxundermoon.shell-format-7.0.1-universal/bin/ && \
    curl -L https://github.com/mvdan/sh/releases/download/v3.0.1/shfmt_v3.0.1_linux_amd64 -o /home/coder/.local/share/code-server/extensions/foxundermoon.shell-format-7.0.1-universal/bin/shfmt_v3.0.1_linux_amd64 && \
    chmod +x /home/coder/.local/share/code-server/extensions/foxundermoon.shell-format-7.0.1-universal/bin/shfmt_v3.0.1_linux_amd64

# Install a VS Code extension from a .vsix file (using gist to avoid marketplace throttling & not every extension repo has vsix release)
# Copilot Chat prepared based on https://github.com/coder/code-server/discussions/4363#discussioncomment-7244791 (renaming .vsix->.zip, changing package.json engines.vscode version requirement, re-zipping)
RUN curl -sSLo /tmp/vscode-ltex-13.1.0-offline-linux-x64.vsix https://github.com/valentjn/vscode-ltex/releases/download/13.1.0/vscode-ltex-13.1.0-offline-linux-x64.vsix && \
    curl -sSLo /tmp/ms-python.autopep8.vsix https://gist.github.com/lrakai/413d454bebca896ab72236f906c4fb7a/raw/354e77ace3eaec5420a0b7f6e51858aa4f57786a/ms-python.autopep8-2023.9.13201008.vsix && \
    curl -sSLo /tmp/clemenspeters.format-json.vsix https://gist.github.com/lrakai/413d454bebca896ab72236f906c4fb7a/raw/354e77ace3eaec5420a0b7f6e51858aa4f57786a/ClemensPeters.format-json-1.0.3.vsix && \
    curl -sSLo /tmp/github.copilot.vsix https://gist.github.com/lrakai/413d454bebca896ab72236f906c4fb7a/raw/354e77ace3eaec5420a0b7f6e51858aa4f57786a/GitHub.copilot-1.138.570.vsix && \
    #curl -sSLo /tmp/github.copilot-chat.vsix https://gist.github.com/lrakai/413d454bebca896ab72236f906c4fb7a/raw/ce1187f6d80cc51e206063053b4f4be8be6395da/GitHub.copilot-chat-0.11.2023112701.vsix && \
    curl -sSLo /tmp/VisualStudioExptTeam.vscodeintellicode.vsix https://gist.github.com/lrakai/413d454bebca896ab72236f906c4fb7a/raw/354e77ace3eaec5420a0b7f6e51858aa4f57786a/VisualStudioExptTeam.vscodeintellicode-1.2.30.vsix && \
    code-server -vvv \
        --install-extension /tmp/ms-python.autopep8.vsix \
        --install-extension /tmp/clemenspeters.format-json.vsix \
        --install-extension /tmp/github.copilot.vsix \
        #--install-extension /tmp/github.copilot-chat.vsix \
        --install-extension /tmp/VisualStudioExptTeam.vscodeintellicode.vsix \
        --install-extension /tmp/vscode-ltex-13.1.0-offline-linux-x64.vsix && \
    rm -f /tmp/ms-python.autopep8.vsix \
        /tmp/clemenspeters.format-json.vsix \
        /tmp/github.copilot.vsix \
        #/tmp/github.copilot-chat.vsix \
        /tmp/VisualStudioExptTeam.vscodeintellicode.vsix \
        /tmp/vscode-ltex-13.1.0-offline-linux-x64.vsix 

# gcloud
RUN sudo apt-get install -y apt-transport-https ca-certificates gnupg lsb-release && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    sudo apt-get update && sudo apt-get install google-cloud-cli
RUN sudo apt-get install -y python3-pip python3-dev build-essential libffi-dev
RUN echo "source /usr/lib/google-cloud-sdk/completion.bash.inc" >> /home/coder/.bashrc && \
    echo "export CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1" >> /home/coder/.bashrc && \
    sudo ln -sf /usr/bin/python3 /usr/bin/python

## VCF dependencies
COPY aws-vcf-env/requirements.txt /tmp/aws-requirements.txt
COPY azure-vcf-env/requirements.txt /tmp/azure-requirements.txt
COPY azure-vcf-env/prune_azure_mgmt_libs.sh /tmp/prune_azure_mgmt_libs.sh
COPY gcp-vcf-env/requirements.txt /tmp/gcp-requirements.txt
RUN python -m pip install boto3 -r /tmp/aws-requirements.txt -r /tmp/azure-requirements.txt -r /tmp/gcp-requirements.txt python-dotenv==1.0.0 && \
    sudo sed -i 's|mgmt_client_dir=.*|mgmt_client_dir=/home/coder/.local/lib/python3.10/site-packages/azure/mgmt|g' /tmp/prune_azure_mgmt_libs.sh && \
    bash /tmp/prune_azure_mgmt_libs.sh

## semtag
ARG SEMTAG_VERSION=0.1.1
RUN curl -L https://github.com/nico2sh/semtag/archive/refs/tags/v${SEMTAG_VERSION}.tar.gz -o /tmp/semtag.tar.gz && \
    tar -zxvf /tmp/semtag.tar.gz -C /tmp && \
    sudo mv /tmp/semtag-${SEMTAG_VERSION}/semtag /usr/bin && \
    rm -rf /tmp/semtag.tar.gz /tmp/semtag-${SEMTAG_VERSION}/

## yq
ARG YQ_VERSION=4.35.2
RUN sudo curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq && \
    sudo chmod a+x /usr/bin/yq

## imagemagick
RUN sudo apt-get install -y imagemagick

## nvm, node
ARG NODE_VERSION=20.9.0
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

## title-cli
RUN PATH=$PATH:/home/coder/.nvm/versions/node/v20.9.0/bin/ && npm install -g @jarmentor/title-cli

## AWS CLI
ARG AWS_CLI_VERSION=2.13.33
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "/tmp/awscliv2.zip" && \
    sudo unzip /tmp/awscliv2.zip -d /tmp && \
    sudo /tmp/aws/install && \
    echo 'complete -C "/usr/local/bin/aws_completer" aws' >> /home/coder/.bashrc

## Azure CLI
ARG AZ_CLI_VERSION=2.53.1
RUN sudo mkdir -p /etc/apt/keyrings && \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg && \
    AZ_DIST=$(lsb_release -cs) && \
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" | sudo tee /etc/apt/sources.list.d/azure-cli.list && \
    sudo apt-get update && \
    sudo apt-get install -y azure-cli=$AZ_CLI_VERSION-1~$AZ_DIST && \
    echo 'source /etc/bash_completion.d/azure-cli' >> /home/coder/.bashrc

## Terraform
ARG TERRAFORM=1.6.3
RUN curl -O https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip && \
    sudo unzip terraform_${TERRAFORM}_linux_amd64.zip && \
    sudo mv terraform /usr/local/bin/ && \
    sudo rm terraform_${TERRAFORM}_linux_amd64.zip && \
    terraform version

## Docker
RUN sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    sudo install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update && \
    VERSION_STRING=5:24.0.7-1~ubuntu.22.04~jammy && \
    sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin && \
    sudo usermod -aG docker coder && \
    echo "sudo chgrp docker /var/run/docker.sock" >> /home/coder/.bashrc && \
    echo "sudo chmod g+rwx /var/run/docker.sock" >> /home/coder/.bashrc

## Github CLI
RUN type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y) && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg  && \
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg  && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null  && \
    sudo apt update  && \
    sudo apt install gh -y

# Copy files: 
COPY deploy-container/docker-compose /usr/local/bin/docker-compose
COPY deploy-container/server.crt /etc/ssl/certs
COPY deploy-container/server.key /etc/ssl/private
RUN sudo chown coder:coder /etc/ssl/certs/server.crt && \
    sudo chown coder:coder /etc/ssl/private/server.key && \
    sudo chmod og+rx /etc/ssl/private
COPY deploy-container/keybindings.json /home/coder/.local/share/code-server/User/keybindings.json

COPY labs-cli/lab /usr/local/bin/lab
COPY labs-cli-helpers /home/coder/labs-cli-helpers/

# -----------

RUN sudo mkdir -p /home/project && \
    sudo chown -R coder:coder /home/project && \
    echo "alias cloudacademy-labs-cli='docker run --platform linux/amd64 -p5500:5500 -v \$HOST_PROJECT:/data -it --rm ghcr.io/cloudacademy-labs/cli'" >> /home/coder/.bashrc && \
    echo "PS1=\"${debian_chroot:+($debian_chroot)}\[\033[01;32m\]dev@calabs\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \"" >> /home/coder/.bashrc && \
    echo "if [ -e /home/project/.init.sh ]; then source /home/project/.init.sh; fi" >> /home/coder/.bashrc && \
    echo "export labs_cli_helpers_path=/home/coder/labs-cli-helpers" >> /home/coder/.bashrc && \
    git config --global user.email "dev@cloudacademylabs.com" && \
    git config --global user.name "Developer"

# Port
ENV PORT=1485

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]

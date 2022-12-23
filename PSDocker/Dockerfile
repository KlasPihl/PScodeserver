FROM codercom/code-server

ARG GITusername="klaspihl"
ARG GITuseremail="klas.pihl@atea.se"

#
# Add PowerShell
#

ARG PS_VERSION=7.3.1
ARG PS_PACKAGE=powershell_${PS_VERSION}-1.ubuntu.20.04_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/powershell_7.3.1-1.deb_amd64.deb
#ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG LANGcode=en_US
#sv_SE
#en_US

RUN echo ${PS_PACKAGE_URL}
# Download the Linux package and save it
ADD ${PS_PACKAGE_URL} /tmp/powershell.deb


# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=${LANGcode}.UTF-8                          \
    LANG=${LANGcode}.UTF-8                            \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache
USER root
#Download Azure AZ and Terraform
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
    az bicep install

# Install dependencies and clean up

RUN \
    echo "**** install runtime dependencies ****" && \
    apt-get update && \
    apt-get install -y \
    less \
    locales \
    ca-certificates \
    gss-ntlmssp \
    wget \
    gnupg \
    software-properties-common \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen $LANG && update-locale \
    && apt-get install -y /tmp/powershell.deb \
    # remove powershell package
    && rm /tmp/powershell.deb \
    #\
    # intialize powershell module cache
    && pwsh -NoLogo -NoProfile -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) { \
        Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
        Start-Sleep -Seconds 6 ; \
        }" \
    && git config --global user.name ${GITusername} \
    && git config --global user.email ${GITuseremail}
#https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
COPY ./terraform.sh /tmp/terraform.sh
RUN bash /tmp/terraform.sh
#
# Add PowerShell extension
#
RUN for i in \
    ms-vscode.azurecli \
    \ms-vscode.azure-account \
    \ms-vscode.powershell-preview \
    \msazurermtools.azurerm-vscode-tools \
    \ms-azuretools.vscode-azureresourcegroups \
    \ms-azuretools.vscode-azureterraform \
    \ms-azuretools.vscode-bicep \
    \gerane.theme-dimmed-monokai \
    \usernamehw.errorlens \
    \ms-azuretools.vscode-docker \
    \vscode-icons-team.vscode-icons \
    \hashicorp.terraform \
    ; do code-server --install-extension "$i" ; done


# Set default configuration of VScode
COPY ./settings.json /root/.local/share/code-server/User/settings.json
COPY ./PSProfile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
ARG VCS_REF="none"
ARG IMAGE_NAME=PScodeserver:stable

LABEL maintainer="Klas Pihl <Klas.Pihl@gmail.com>" \
      readme.md="https://github.com/KlasPihl/PScodeserver/main/README.md" \
      description="Coder.com's code-server, PowerShell, and the PowerShell extension for vscode - all in one container." \
      org.label-schema.url="https://github.com/KlasPihl/PScodeserver" \
      org.label-schema.vcs-url="https://github.com/KlasPihl/PScodeserver" \
      org.label-schema.name="KlasPihl" \
      org.label-schema.vendor="KlasPihl" \
      org.label-schema.version=${PS_EXTENSION_VERSION} \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd="docker run -t -p 127.0.0.1:8443:8443 -v '\${PWD}:/root/project' ${IMAGE_NAME} pscodeserver:4 --allow-http --no-auth"
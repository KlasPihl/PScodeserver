FROM codercom/code-server

#
# Add PowerShell
#

ARG PS_VERSION=7.2.7
ARG PS_PACKAGE=powershell_${PS_VERSION}-1.ubuntu.20.04_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/powershell-lts_7.2.7-1.deb_amd64.deb
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


# Install dependencies and clean up
USER root
RUN \
    echo "**** install runtime dependencies ****" && \
    apt-get update && \
    apt-get install -y \
    less \
    locales \
    ca-certificates \
    gss-ntlmssp \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen $LANG && update-locale \
    && apt-get install -y /tmp/powershell.deb \
    # remove powershell package
    #&& rm /tmp/powershell.deb
    #\
    # intialize powershell module cache
    && pwsh -NoLogo -NoProfile -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) { \
        Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
        Start-Sleep -Seconds 6 ; \
        }"

#
# Add PowerShell extension
#

ARG PS_EXTENSION_VERSION=2022.10.2-preview
ARG PS_EXTENSION_PACKAGE=powershell-preview-2022.10.2.vsix

#ARG PS_EXTENSION_PACKAGE_URL=https://github.com/PowerShell/vscode-powershell/releases/download/v${PS_EXTENSION_VERSION}/${PS_EXTENSION_PACKAGE}
ARG PS_EXTENSION_PACKAGE_URL=https://github.com/PowerShell/vscode-powershell/releases/download/v2022.10.2-preview/powershell-preview-2022.10.2.vsix

RUN echo ${PS_EXTENSION_PACKAGE_URL}
ADD ${PS_EXTENSION_PACKAGE_URL} /tmp/vscode-powershell.zip

RUN pwsh -NoLogo -NoProfile -Command "                                                          \
    \$ErrorActionPreference = 'Stop' ;                                                          \
    \$ProgressPreference = 'SilentlyContinue' ;                                                 \
    Expand-Archive /tmp/vscode-powershell.zip /tmp/vscode-powershell/ ;                         \
    \$null = New-Item -Force -ItemType Directory ~/.local/share/code-server/extensions/ ;        \
    Move-Item /tmp/vscode-powershell/extension                                                  \
        ~/.local/share/code-server/extensions/ms-vscode.powershell-${PS_EXTENSION_VERSION} ;    \
    Remove-Item -Recurse -Force /tmp/vscode-powershell/                                         \
    "

ARG VCS_REF="none"
ARG IMAGE_NAME=PScodeserver:stable

LABEL maintainer="Klas Pihl <Klas.Pihl@gmail.com>" \
      readme.md="https://github.com/KlasPihl/PScodeserver/main/README.md" \
      description="Coder.com's code-server, PowerShell, and the PowerShell extension for vscode - all in one container." \
      org.label-schema.url="https://github.com/KlasPihl/PScodeserver" \
      org.label-schema.vcs-url="https://github.com/KlasPihl/powershell-code-server" \
      org.label-schema.name="KlasPihl" \
      org.label-schema.vendor="KlasPihl" \
      org.label-schema.version=${PS_EXTENSION_VERSION} \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd="docker run -t -p 127.0.0.1:8443:8443 -v '\${PWD}:/root/project' ${IMAGE_NAME} PScodeserver --allow-http --no-auth"
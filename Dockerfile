FROM swissgrc/azure-pipelines-openjdk:17.0.4.1

LABEL org.opencontainers.image.vendor="Swiss GRC AG"
LABEL org.opencontainers.image.authors="Swiss GRC AG <opensource@swissgrc.com>"
LABEL org.opencontainers.image.title="azure-pipelines-sonarscannermsbuild"
LABEL org.opencontainers.image.documentation="https://github.com/swissgrc/docker-azure-pipelines-sonarscannermsbuild"

# Make sure to fail due to an error at any stage in shell pipes
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Git

#Disabled renovate: datasource=repology depName=debian_11/git versioning=loose
ENV GIT_VERSION=1:2.30.2-1

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends git=${GIT_VERSION} && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  git version
  
# Install Git LFS

# renovate: datasource=github-tags depName=git-lfs/git-lfs extractVersion=^v(?<version>.*)$
ENV GITLFS_VERSION=3.3.0

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash  && \
  apt-get install -y --no-install-recommends git-lfs=${GITLFS_VERSION}  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  git lfs version

# Install NodeJS

# renovate: datasource=github-tags depName=nodejs/node extractVersion=^v(?<version>.*)$
ENV NODE_VERSION=16.19.0

# Install .NET

RUN apt-get update -y && \
  # Add NodeJS PPA
  curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
  # Install NodeJs
  apt-get install -y --no-install-recommends nodejs=${NODE_VERSION}-deb-1nodesource1 && \
  # Clean up
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  node -v

# renovate: datasource=github-tags depName=dotnet/sdk extractVersion=^v(?<version>.*)$
ENV DOTNET_VERSION=7.0.102

ENV \
    # Do not show first run text
    DOTNET_NOLOGO=true \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true \
    # Disable telemetry
    DOTNET_CLI_TELEMETRY_OPTOUT=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip

RUN curl -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb && \
  dpkg -i /tmp/packages-microsoft-prod.deb && \
  rm -rf /tmp/* && \
  apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-6.0=${DOTNET_VERSION}-1 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  dotnet --info

# Install Dependencies required for dotnet test coverage

#Disabled renovate: datasource=repology depName=debian_11/libxml2 versioning=loose
ENV LIBXML_VERSION=2.9.10+dfsg-6.7+deb11u3

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends libxml2=${LIBXML_VERSION} && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

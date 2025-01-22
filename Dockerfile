# kpa-marp-pandoc
#
# This Dockerfile will build a container with all the tools and dependencies to
# be used by KPA [1].
#
# Specifically:
#
# - ansible & ansible-lint
# - curl & git
# - yamllint & mdl (linter)
# - Marp & Pandoc
#
# [1] https://github.com/mmul-it/kpa

# Set Debian container version
ARG DEBIAN_VERSION='12.9-slim'

# We rely on Debian Stable
FROM docker.io/debian:${DEBIAN_VERSION}

# Set specific apt bits
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set Software components versions
ENV NODE_VERSION='20'
ENV MARP_VERSION='v4.1.1'

# Install required system packages
RUN apt update &&\
    apt -y install curl git ansible ansible-lint yamllint rubygems ca-certificates curl gnupg && \
    apt clean

# Install mdl (Mardown linter)
RUN gem install mdl

# Install Marp with nodejs and chrome 
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" > \
    /etc/apt/sources.list.d/nodesource.list && \
    apt update && \
    apt install -y nodejs chromium && \
    npm install -g @marp-team/marp-cli@${MARP_VERSION} && \
    apt clean

# Install pandoc with texlive
RUN apt -y install pandoc texlive texlive-base texlive-binaries \
      texlive-fonts-recommended texlive-latex-base texlive-latex-extra \
      texlive-latex-recommended texlive-pictures texlive-plain-generic texlive-xetex && \
    apt clean

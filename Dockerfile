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

# We rely on Debian Stable
FROM docker.io/debian:stable-slim

# Set specific apt bits
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

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
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > \
    /etc/apt/sources.list.d/nodesource.list && \
    apt update && \
    apt install -y nodejs chromium && \
    npm install -g @marp-team/marp-cli && \
    apt clean

# Install pandoc with texlive
RUN apt -y install pandoc texlive texlive-base texlive-binaries \
      texlive-fonts-recommended texlive-latex-base texlive-latex-extra \
      texlive-latex-recommended texlive-pictures texlive-plain-generic texlive-xetex && \
    apt clean

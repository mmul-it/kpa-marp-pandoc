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

# Start from ansible-core
FROM docker.io/ubuntu:22.04

# Update repo contents
RUN apt update

# Install requiremets
RUN apt -y install python3-pip curl git

# Upgrade pip & install ansible & ansible-lint
RUN pip3 install --upgrade pip && \
    pip3 install ansible ansible-lint

# Install yamllint (Yaml linter)
RUN pip3 install yamllint

# Install mdl (Mardown linter)
RUN apt -y install rubygems
RUN gem install mdl

# Install Marp with nodejs and chrome 
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    curl -s https://dl.google.com/linux/linux_signing_key.pub -o - | apt-key add - && \
    gpg --refresh-keys && \
    apt update
RUN apt -y install nodejs google-chrome-stable
RUN npm install -g @marp-team/marp-cli

# Install pandoc with texlive
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt -y install pandoc texlive texlive-base texlive-binaries \
      texlive-fonts-recommended texlive-latex-base texlive-latex-extra \
      texlive-latex-recommended texlive-pictures texlive-plain-generic texlive-xetex

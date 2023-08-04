variable "source_image" {
  type    = string
  default = "docker.io/ubuntu:focal"
  # Selecting ubuntu:focal instead of ubuntu:22.04 because of glibc problem on my podman
  # See https://stackoverflow.com/a/73701049/2707870
  description = "Base image to extend."
}

variable "version" {
  type = string
  default = "latest"
  description = "Version of the base image."
}

variable "base_packages" {
  type        = list(string)
  description = "Base OS packages to be added to the image."
  default = [
    "bash",
    "curl",
    "git",
    "nodejs",
    "pandoc",
    "python3-pip",
    "python3.9",
    "rubygems",
    "texlive",
    "texlive-base",
    "texlive-binaries",
    "texlive-fonts-recommended",
    "texlive-latex-base",
    "texlive-latex-extra",
    "texlive-latex-recommended",
    "texlive-pictures",
    "texlive-plain-generic",
    "texlive-xetex"
  ]
}

variable "google_signing_key_url" {
  description = "URL of the Google apt repo signing key"
  type        = string
  default     = "https://dl.google.com/linux/linux_signing_key.pub"
}

variable "nodejs_version" {
  description = "Version of NodeJS we want to provision"
  type = string
  default = "18.x"
}

source "docker" "default" {
  image  = var.source_image
  commit = true
  changes = [
    "ENV TZ=Etc/UTC",
    "ENV DEBIAN_FRONTEND=noninteractive",
    "ENTRYPOINT /bin/bash",
    "LABEL version=${var.version}"
  ]
}

data "http" "google_signing_key" {
  url = var.google_signing_key_url
}

data "http" "nodejs_install_script" {
  url = join("",["https://deb.nodesource.com/setup_",var.nodejs_version])
}

data "http" "nodejs_signing_key" {
  url = "https://deb.nodesource.com/gpgkey/nodesource.gpg.key"
}

build {
  sources = ["source.docker.default"]
  provisioner "shell" {
    inline = [
      "apt-get update -qq",
      "apt-get install -qq gpg gnupg2 ca-certificates"
    ]
  }

  # Add the python requirements for the image
  provisioner "file" {
    source      = "image_requirements.txt"
    destination = "/image_requirements.txt"
  }

  # Ensure deb string for nodejs
  provisioner "file" {
    content = join(" ", [
      "deb",
      // "[signed-by=/usr/local/keyrings/nodejs.gpg]",
      "https://deb.nodesource.com/node_${var.nodejs_version}",
      "focal",
      "main"
    ])
    destination = "/etc/apt/sources.list.d/nodesource.list"
  }

  # Configure Google repo for chrome browser
  provisioner "file" {
    // content     = "deb [signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main"
    content     = "deb http://dl.google.com/linux/chrome/deb/ stable main"
    destination = "/etc/apt/sources.list.d/google-chrome.list"
  }

  # Package installation
  provisioner "shell" {
    inline = [
      "echo \"${data.http.google_signing_key.body}\" | gpg --dearmor | apt-key add -",
      "echo \"${data.http.nodejs_signing_key.body}\" | apt-key add -",
      # Update the apt cache after adding the signing keys for google and nodejs repos
      "apt-get update -qq",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y ${join(" ", var.base_packages)}",
      # Add pip packages
      "python3.9 -m pip install -r /image_requirements.txt",
      # Add nodejs packages
      "npm install -g @marp-team/marp-cli"
    ]
  }
  post-processors {
    post-processor "docker-tag" {
        repository =  "kpa-marp-pandoc"
        tags = distinct([var.version, "latest"])
      }
    // post-processor "docker-push" {}
  }
}

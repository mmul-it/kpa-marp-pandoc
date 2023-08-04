variable "source_image" {
  type    = string
  default = "docker.io/ubuntu:focal"
  # Selecting ubuntu:focal instead of ubuntu:22.04 because of glibc problem on my podman
  # See https://stackoverflow.com/a/73701049/2707870
  description = "Base image to extend."
}

variable "base_packages" {
  type        = list(string)
  description = "Base OS packages to be added to the image."
  default = [
    "python3.9",
    "python3-pip",
    "curl",
    "git"
    // "rubygems",
    // "pandoc",
    // "texlive",
    // "texlive-base",
    // "texlive-binaries",
    // "texlive-fonts-recommended",
    // "texlive-latex-base",
    // "texlive-latex-extra",
    // "texlive-latex-recommended",
    // "texlive-pictures",
    // "texlive-plain-generic",
    // "texlive-xetex"
  ]
}

variable "google_signing_key_url" {
  description = "URL of the Google apt repo signing key"
  type        = string
  default     = "https://dl.google.com/linux/linux_signing_key.pub"
}
source "docker" "default" {
  image  = var.source_image
  commit = true
  changes = [
    "ENV TZ=Etc/UTC",
    "ENV DEBIAN_FRONTEND=noninteractive"
  ]
}

data "http" "google_signing_key" {
  url = var.google_signing_key_url
}

build {
  sources = ["source.docker.default"]
  provisioner "shell" {
    inline = [
      "apt-get update -qq",
      "apt-get install -qq gpg gnupg2"
    ]
  }

  # Add the python requirements for the image
  provisioner "file" {
    source      = "image_requirements.txt"
    destination = "/image_requirements.txt"
  }
  # Add the google signing key for the chrome browser we need later.
  provisioner "file" {
    content     = data.http.google_signing_key.body
    destination = "/google.gpg"
  }
  provisioner "file" {
    content     = "deb [signed-by=/usr/local/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main"
    destination = "/etc/apt/sources.list.d/google-chrome.list"
  }

  # Package installation
  provisioner "shell" {
    inline = [
      "echo \"${data.http.google_signing_key.body}\" | apt-key add -",
      // "curl -sL https://deb.nodesource.com/setup_18.x | bash -",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y ${join(" ", var.base_packages)}",
      # Add pip packages
      "python3.9 -m pip install -r /image_requirements.txt",
      "npm install -g @marp-team/marp-cli"
    ]
  }
}
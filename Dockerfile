FROM debian:bullseye-slim

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install LaTeX, and dependencies
RUN apt-get update --quiet && \
    apt-get install --quiet --yes \
    texlive-full \
    curl \
    perl && \
    # Install getnonfreefonts
    curl --remote-name https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts && \
    texlua install-getnonfreefonts && \
    # Install nonfreefonts
    getnonfreefonts --sys --all && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Create the /data directory
RUN mkdir /data

# Create a non-root user with a home directory and set permissions
RUN useradd -m nicholas && chown -R nicholas:nicholas /data
USER nicholas

# Setup working directory and volume to access cv.tex
WORKDIR /data
VOLUME ["/data"]

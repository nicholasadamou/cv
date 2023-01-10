FROM ubuntu:jammy@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e
ENV DEBIAN_FRONTEND noninteractive

# Install LaTeX and dependencies
RUN apt-get update --quiet && apt-get install --quiet --yes \
    texlive-full \
    curl

# Install getnonfreefonts
RUN curl --remote-name https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts && \
    texlua install-getnonfreefonts

# Install nonfreefonts
RUN getnonfreefonts --sys --all

# Setup working directory and volume to access cv.tex
WORKDIR /data
VOLUME ["/data"]

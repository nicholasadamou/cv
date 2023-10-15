# Using Ubuntu 20.04 as the base image because pdf2htmlEX is not supported in later versions of Ubuntu
FROM ubuntu:20.04

# Set environment variables to non-interactive (this reduces output and potential errors during build)
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        apt-transport-https \
        ca-certificates \
        gnupg \
		lsb-release \
		perl \
		wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x using nodesource
RUN export NODE_MAJOR_VERSION=20 && \
	mkdir -p /etc/apt/keyrings/ && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install browser-sync
RUN npm install -g browser-sync

# Install texlive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive \
		texlive-latex-recommended \
		texlive-extra-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pdf2htmlex dependencies
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		libjpeg-turbo-progs \
		libxml2 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Install pdf2htmlEX
RUN wget -O pdf2htmlEX.deb https://github.com/pdf2htmlEX/pdf2htmlEX/releases/download/continuous/pdf2htmlEX-0.18.8.rc2-master-20200820-ubuntu-20.04-x86_64.deb && \
	apt install -y ./pdf2htmlEX.deb && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
	rm pdf2htmlEX.deb

# Install getnonfreefonts and nonfreefonts
RUN curl --remote-name https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts && \
    texlua install-getnonfreefonts && \
    getnonfreefonts --sys --all

# Copy the cv.tex file and other required files to the container
# Set permissions and ownership in the same layer to avoid duplicating the file in another layer
COPY cv.tex script.sh /data/
RUN chmod +x /data/script.sh && \
    chown -R nobody:nogroup /data

# Switch to a non-root user for better security
USER nobody

# Set the working directory
WORKDIR /data

# Expose the port for the browser-sync server
EXPOSE 3000

# Run the script to watch for changes and start the browser-sync server
CMD ["/data/script.sh"]

# Set the default volume
VOLUME [ "/data" ]

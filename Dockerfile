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
		wget \
		inotify-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the keyrings directory
RUN mkdir -p /etc/apt/keyrings/

# Install Node.js 20.x
RUN export NODE_MAJOR_VERSION=20 && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install browser-sync globally
RUN npm install -g browser-sync

# Install TeX Live dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-lang-english \
        texlive-xetex && \
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

# Copy the cv.tex file and other required files to the container
# Set permissions and ownership in the same layer to avoid duplicating the file in another layer
COPY cv.tex script.sh /data/
RUN chmod +x /data/script.sh && \
    chown -R nobody:nogroup /data

# Switch to a non-root user for better security
USER nobody

# Set the working directory
WORKDIR /data

# Expose the ports for the live reload server and HTTP server
EXPOSE 3000 8080

# Run the script to watch for changes and start the live reload server
CMD ["/data/script.sh"]

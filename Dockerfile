# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV NODE_VERSION=20.x
ENV NODE_HOME=/usr/local/node
ENV PATH=$NODE_HOME/bin:$PATH

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl unzip && \
    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download and extract artifact
# Replace ARTIFACT_URL with your actual artifact URL
ARG ARTIFACT_URL
RUN curl -L ${ARTIFACT_URL} -o artifact.zip && \
    unzip artifact.zip && \
    rm artifact.zip

# Expose port (adjust if needed)
EXPOSE 3000

# Start the application
CMD ["node", "dist/server.js"]
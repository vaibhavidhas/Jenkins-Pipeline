# -----------------------------
# Base image: Ubuntu + Node.js
# -----------------------------
FROM ubuntu:22.04

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Install Node.js and dependencies
# -----------------------------
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# -----------------------------
# Set environment variables
# -----------------------------
ENV APP_HOME=/usr/src/app
ENV NODE_ENV=production

RUN mkdir -p $APP_HOME
# Create app directory
WORKDIR $APP_HOME
RUN ls -ltra

# -----------------------------
# Copy artifact directly from Jenkins workspace
# -----------------------------
# The wildcard (*) allows copying any versioned zip, e.g. cl-backend-1.0.4.zip
COPY cl-backend-*.zip artifact.zip

RUN unzip artifact.zip && rm artifact.zip

# -----------------------------
# Install Node.js dependencies (if package.json is inside the artifact)
# -----------------------------
RUN if [ -f package.json ]; then npm install --production; fi

# -----------------------------
# Expose the app port
# -----------------------------
EXPOSE 3000

# -----------------------------
# Define the entry command
# -----------------------------
ENTRYPOINT ["node", "dist/server.js"]

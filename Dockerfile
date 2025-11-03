# Use Ubuntu base and install Node.js
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl unzip ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

WORKDIR /usr/src/app

# Copy artifact from Jenkins workspace (no curl, no ARTIFACT_URL)
COPY cl-backend-*.zip ./artifact.zip

# Unzip into /usr/src/app
RUN unzip artifact.zip -d /usr/src/app && rm artifact.zip

# Show contents for debug
RUN echo "📂 App contents:" && ls -R /usr/src/app

EXPOSE 3000

CMD ["node", "dist/server.js"]

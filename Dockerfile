# Use Node.js base image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Install unzip
RUN apk add --no-cache unzip

# Copy dependency manifests
COPY package*.json ./

# Install production dependencies
RUN npm install --production

# Build argument for Jenkins artifact
ARG ARTIFACT_FILE

# Copy and unzip artifact
COPY ${ARTIFACT_FILE} ./artifact.zip
RUN unzip -o artifact.zip -d /usr/src/app && rm artifact.zip

# Expose the backend port
EXPOSE 3000

# Start the server
CMD ["node", "dist/server.js"]

# Use Node.js base image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Install unzip for Alpine
RUN apk add --no-cache unzip

# Build argument for artifact file
ARG ARTIFACT_FILE

# Copy the artifact zip from Jenkins build
COPY ${ARTIFACT_FILE} ./artifact.zip

# Unzip the artifact into /usr/src/app
RUN unzip artifact.zip -d . || true && rm artifact.zip

# Expose your backend port (optional)
EXPOSE 3000

# Run the server from the dist folder
CMD ["node", "dist/server.js"]

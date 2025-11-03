# Use Node.js base image
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy the Jenkins artifact zip into the container
ARG ARTIFACT_FILE
COPY ${ARTIFACT_FILE} ./artifact.zip

# Install unzip and extract the dist folder
RUN apk add --no-cache unzip && \
    unzip artifact.zip -d . && \
    rm artifact.zip

# Set working directory to dist (since the app is inside dist)
WORKDIR /usr/src/app/dist

# Install production dependencies (if needed)
RUN npm install --omit=dev || true

# Start the app
CMD ["node", "server.js"]

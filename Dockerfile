# Use Node.js base image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Install unzip (alpine) and any tools for debugging
RUN apk add --no-cache unzip

# Copy and unzip your Jenkins artifact
COPY cl-backend-*.zip ./artifact.zip
RUN unzip artifact.zip -d /usr/src/app && rm artifact.zip

# If the artifact contains a package.json, install its production deps
# (this ensures node_modules match the extracted artifact)
RUN if [ -f /usr/src/app/package.json ]; then npm install --only=production --prefix /usr/src/app; fi

# Debug listing to confirm files are where you expect
RUN echo "✅ Contents of /usr/src/app after unzip:" && ls -R /usr/src/app

# Expose the port your app runs on
EXPOSE 3000

# Run the app
ENTRYPOINT ["node", "dist/server.js"]

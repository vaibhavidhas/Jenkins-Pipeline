# Use Node.js base image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Install unzip (for Alpine)
RUN apk add --no-cache unzip

# Copy Jenkins artifact (ZIP file)
COPY cl-backend-*.zip ./artifact.zip

# ✅ Unzip artifact so that the /dist folder is extracted as-is
RUN unzip artifact.zip -d /usr/src/app && rm artifact.zip

# Show extracted structure (for debug)
RUN echo "📂 Final structure after unzip:" && ls -R /usr/src/app

# Install dependencies if a package.json exists inside dist
RUN if [ -f "/usr/src/app/dist/package.json" ]; then \
      cd /usr/src/app/dist && npm install --only=production; \
    fi

# Expose app port
EXPOSE 3000

# Start the app from the dist folder
ENTRYPOINT ["node", "dist/server.js"]

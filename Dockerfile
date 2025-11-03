# Start from a lightweight Node base image (includes Node & npm)
FROM node:20-alpine

# Install unzip (Alpine uses apk instead of apt)
RUN apk add --no-cache unzip

# Set the working directory
WORKDIR /usr/src/app

# Copy package files (required for dependency install)
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy your Jenkins artifact (contains dist/server.js)
COPY ./cl-backend-*.zip ./artifact.zip

# Extract the artifact (unzip creates dist/server.js)
RUN unzip artifact.zip && rm artifact.zip

# (Optional) verify contents for debugging
RUN ls -R /usr/src/app

# Expose the app port
EXPOSE 3000

# Run your built server
CMD ["node", "dist/server.js"]

# Start from a lightweight Node base image (includes Node & npm)
FROM node:20-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package files (required for dependency install)
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy your Jenkins artifact (contains dist/server.js)
COPY ./cl-backend-*.tar ./artifact.tar

# Extract the artifact
RUN tar -xf artifact.tar && rm artifact.tar

# (Optional) verify contents for debugging
RUN ls -R /usr/src/app

# Expose the app port
EXPOSE 3000

# Run your built server
CMD ["node", "dist/server.js"]

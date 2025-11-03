# Use Node.js base image
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy and install dependencies
COPY package*.json ./
RUN npm install --only=production

# Copy your Jenkins artifact ZIP
COPY cl-backend-*.zip ./artifact.zip

# Unzip it into /usr/src/app
RUN unzip artifact.zip && rm artifact.zip

# Check structure for debugging
RUN ls -R /usr/src/app

# Expose the port your app runs on
EXPOSE 3000

# Run the app
CMD ["node", "dist/server.js"]

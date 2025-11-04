FROM node:20-alpine

WORKDIR /usr/src/app
RUN apk add --no-cache unzip

ARG ARTIFACT_FILE
COPY ${ARTIFACT_FILE} ./artifact.zip

# Extract dist folder
RUN unzip artifact.zip -d . && rm artifact.zip

WORKDIR /usr/src/app/dist
CMD ["node", "server.js"]
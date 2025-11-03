FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

ENV APP_HOME=/usr/src/app
ENV NODE_ENV=production
WORKDIR $APP_HOME

# Copy the artifact
COPY ./cl-backend-*.zip artifact.zip

# Unzip the artifact (this will create /usr/src/app/dist/)
COPY ./cl-backend-*.tar artifact.tar
RUN tar -xf artifact.tar && rm artifact.tar

# Install only production dependencies (if needed)
RUN if [ -f package.json ]; then npm install --omit=dev; fi

EXPOSE 3000

ENTRYPOINT ["node", "dist/server.js"]
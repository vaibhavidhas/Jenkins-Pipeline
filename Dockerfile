# ----------------------------------------------
# 🧩 1. Use Ubuntu as the base image
# ----------------------------------------------
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------
# 🧩 2. Install required tools and Node.js
# ----------------------------------------------
RUN apt-get update && \
    apt-get install -y curl unzip ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# ----------------------------------------------
# 🧩 3. Set environment variables
# ----------------------------------------------
ENV NODE_HOME=/usr/bin/node
ENV APP_HOME=/usr/src/app
ENV PATH=$NODE_HOME/bin:$PATH

# ----------------------------------------------
# 🧩 4. Set working directory
# ----------------------------------------------
WORKDIR $APP_HOME


# 5. Download artifact ZIP file
#    (You can pass the URL during build time)

ARG ARTIFACT_URL
RUN if [ -z "$ARTIFACT_URL" ]; then \
      echo "❌ ERROR: ARTIFACT_URL not provided!"; exit 1; \
    else \
      echo "📦 Downloading artifact from $ARTIFACT_URL ..."; \
      curl -L "$ARTIFACT_URL" -o artifact.zip; \
    fi


#  6. Unzip artifact and verify structure

RUN unzip artifact.zip -d $APP_HOME && rm artifact.zip && \
    echo "📂 Final file structure:" && ls -R $APP_HOME

# ----------------------------------------------
#  7. Expose port (if applicable)
# ----------------------------------------------
EXPOSE 3000

# ----------------------------------------------
#  8. Run the app
# ----------------------------------------------
CMD ["node", "dist/server.js"]

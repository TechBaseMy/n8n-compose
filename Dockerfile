# Build stage: Copy Node binaries from official images
FROM node:18-alpine AS node18
FROM node:21-alpine AS node21

# Main stage: Start with n8n image
FROM docker.n8n.io/n8nio/n8n
USER root

# Install bash for the switch script
RUN apk add --no-cache bash

# Copy Node.js binaries from official images
COPY --from=node18 /usr/local /opt/node-18.20.2
COPY --from=node21 /usr/local /opt/node-21.7.2

# Create version symlinks
RUN ln -s /opt/node-18.20.2 /opt/node-v18 && \
    ln -s /opt/node-21.7.2 /opt/node-v21

# Create initial symlink for current node (default to Node 22 - the base image version)
RUN ln -sf /usr/local /opt/node-current

# Create a directory that the node user can write to for switching
RUN mkdir -p /home/node/bin && \
    chown node:node /home/node/bin

# Add switch-node script
COPY switch-node.sh /usr/local/bin/switch-node
RUN chmod +x /usr/local/bin/switch-node

USER node
WORKDIR /home/node

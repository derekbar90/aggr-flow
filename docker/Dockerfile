FROM node:18-alpine

ARG WORKDIR=/usr/src/app
ENV WORKDIR=${WORKDIR}

WORKDIR ${WORKDIR}

# Copy package files from submodule
COPY src/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code from submodule
COPY src/ .

# Copy production configurations
COPY config/api/config.json ./config.json

# Create data directory
RUN mkdir -p data

EXPOSE 3000

CMD ["node", "index.js"]

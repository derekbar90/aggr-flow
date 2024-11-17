FROM node:18-alpine

ARG WORKDIR=/usr/src/app
ENV WORKDIR=${WORKDIR}

WORKDIR ${WORKDIR}

# Install build dependencies and required packages
RUN apk add --no-cache \
    bash \
    netcat-openbsd \
    python3 \
    make \
    g++ \
    gcc \
    libc-dev \
    linux-headers \
    python3 \
    influxdb-client \
    jq

# Copy wait-for-it script
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Copy package files from submodule
COPY src/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code from submodule
COPY src/ .

# Create data directory
RUN mkdir -p data

EXPOSE 3000

CMD ["node", "index.js"]

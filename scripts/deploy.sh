#!/bin/bash

# Initialize swarm if not already initialized
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
    docker swarm init
fi

# Build images
docker-compose build

# Deploy stack
docker stack deploy -c docker-compose.yml aggr-stack

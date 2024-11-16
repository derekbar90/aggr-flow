#!/bin/bash

# Update submodule to latest
git submodule update --remote src

# Rebuild and redeploy
docker-compose build
docker stack deploy -c docker-compose.yml aggr-stack

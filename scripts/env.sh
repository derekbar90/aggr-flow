#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

case "$1" in
    "dev")
        print_message "Starting development environment..."
        docker-compose -f docker-compose.dev.yml up -d
        ;;
    "prod")
        print_message "Starting production environment..."
        docker swarm init 2>/dev/null || true
        docker stack deploy -c docker-compose.prod.yml aggr-stack
        ;;
    "down")
        if [ "$2" = "prod" ]; then
            print_message "Stopping production environment..."
            docker stack rm aggr-stack
        else
            print_message "Stopping development environment..."
            docker-compose -f docker-compose.dev.yml down
        fi
        ;;
    *)
        print_error "Invalid command!"
        echo "Usage: $0 [dev|prod|down]"
        echo "  dev   - Start development environment"
        echo "  prod  - Start production environment"
        echo "  down  - Stop environment (add 'prod' for production)"
        exit 1
        ;;
esac
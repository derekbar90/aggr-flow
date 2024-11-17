#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

cleanup_docker() {
    local env=$1
    print_message "Cleaning up Docker resources..."
    
    # Remove unused containers, networks, images and volumes
    if [ "$env" = "prod" ]; then
        docker system prune -af --volumes
        print_success "Cleaned up unused Docker resources in production"
    else
        docker-compose -f docker-compose.dev.yml down --remove-orphans --volumes
        docker system prune -af --volumes
        print_success "Cleaned up unused Docker resources in development"
    fi
}

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed!"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running!"
        exit 1
    fi
}

check_env_file() {
    local env=$1
    local env_file=".env.${env}"
    
    if [ ! -f "$env_file" ]; then
        print_error "Environment file ${env_file} not found!"
        print_message "Creating from example file..."
        if [ -f ".env.example" ]; then
            cp .env.example "$env_file"
            print_success "Created ${env_file} from example"
        else
            print_error "No .env.example file found!"
            exit 1
        fi
    fi
}

case "$1" in
    "dev")
        check_docker
        check_env_file "dev"
        print_message "Starting development environment..."
        docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
        ;;
    "prod")
        check_docker
        check_env_file "prod"
        print_message "Starting production environment..."
        if ! docker swarm init 2>/dev/null; then
            print_warning "Swarm already initialized or insufficient privileges"
        fi
        docker stack deploy -c docker-compose.prod.yml --env-file .env.prod aggr-stack
        ;;
    "stop")
        check_docker
        if [ "$2" = "prod" ]; then
            print_message "Stopping production environment..."
            docker stack rm aggr-stack
        else
            print_message "Stopping development environment..."
            docker-compose -f docker-compose.dev.yml down
        fi
        ;;
    "logs")
        check_docker
        if [ "$2" = "prod" ]; then
            print_message "Showing production logs..."
            if [ -n "$3" ]; then
                # Show logs for specific service
                docker service logs "aggr-stack_$3" ${@:4}
            else
                # Show logs for all services
                for service in $(docker service ls --filter name=aggr-stack -q); do
                    docker service logs $service
                done
            fi
        else
            print_message "Showing development logs..."
            docker-compose -f docker-compose.dev.yml logs ${@:3} $2
        fi
        ;;
    "cleanup")
        check_docker
        cleanup_docker "$2"
        ;;
    "init")
        if [ ! -f ".env.example" ]; then
            print_error "No .env.example file found!"
            exit 1
        fi
        cp .env.example .env.dev
        cp .env.example .env.prod
        print_success "Created .env.dev and .env.prod from example"
        print_warning "Please review and adjust the environment files as needed"
        ;;
    *)
        print_error "Invalid command!"
        echo "Usage: $0 [dev|prod|stop|cleanup|logs|init]"
        echo "  dev     - Start development environment"
        echo "  prod    - Start production environment"
        echo "  stop    - Stop environment (add 'prod' for production)"
        echo "  cleanup - Clean up Docker resources (add 'prod' for production)"
        echo "  logs    - View logs (Usage: logs [prod] [service] [options])"
        echo "           Options: --follow, --tail=N, --since=TIME"
        echo "  init    - Initialize environment files from example"
        exit 1
        ;;
esac
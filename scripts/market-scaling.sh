#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Function to validate input
validate_input() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Missing required arguments!"
        echo "Usage:"
        echo "  Add new collector:    $0 add <name> <pairs>"
        echo "  Scale collector:      $0 scale <name> <replicas>"
        echo "  Remove collector:     $0 remove <name>"
        echo "  List collectors:      $0 list"
        echo
        echo "Examples:"
        echo "  $0 add \"defi-1\" \"COINBASE:UNI-USD,BINANCE:uniusdt\""
        echo "  $0 scale \"btc-major\" 2"
        echo "  $0 remove \"defi-1\""
        exit 1
    fi
}

# Function to add a new market collector
add_market_collector() {
    local name=$1
    local pairs=$2
    
    print_message "Adding new collector: $name"
    
    # Create config directory if it doesn't exist
    mkdir -p "./config/collectors"
    
    # Create collector config file
    cat > "./config/collectors/${name}.json" <<EOF
{
    "api": false,
    "collect": true,
    "storage": ["influx"],
    "influxCollectors": true,
    "id": "${name}"
}
EOF
    
    # Add new service to docker-compose.yml
    if ! grep -q "collector-${name}:" docker-compose.yml; then
        # Find the last collector service and add new one after it
        sed -i "/collector-.*:/!b;/^$/!b;i\  collector-${name}:\n\    <<: *common-collector\n\    container_name: aggr-collector-${name}\n\    volumes:\n\      - ./config/collectors/${name}.json:/usr/src/app/config.json\n\    environment:\n\      - COLLECTOR_ID=${name}\n\      - PAIRS=${pairs}\n" docker-compose.yml
        
        print_success "Added new collector to docker-compose.yml"
    else
        print_error "Collector ${name} already exists in docker-compose.yml"
        exit 1
    fi
    
    # Deploy the new service
    print_message "Deploying new collector..."
    docker stack deploy -c docker-compose.yml aggr-stack
    
    print_success "Collector ${name} has been added and deployed"
}

# Function to scale an existing collector
scale_collector() {
    local name=$1
    local replicas=$2
    
    print_message "Scaling collector-${name} to ${replicas} replicas"
    
    # Verify collector exists
    if ! grep -q "collector-${name}:" docker-compose.yml; then
        print_error "Collector ${name} not found in docker-compose.yml"
        exit 1
    fi
    
    # Scale the service
    docker service scale "aggr-stack_collector-${name}"="${replicas}"
    
    print_success "Collector ${name} scaled to ${replicas} replicas"
}

# Function to remove a collector
remove_collector() {
    local name=$1
    
    print_message "Removing collector: ${name}"
    
    # Verify collector exists
    if ! grep -q "collector-${name}:" docker-compose.yml; then
        print_error "Collector ${name} not found in docker-compose.yml"
        exit 1
    fi
    
    # Remove service from docker-compose.yml
    sed -i "/collector-${name}:/,/^[^ ]/d" docker-compose.yml
    
    # Remove config file
    rm -f "./config/collectors/${name}.json"
    
    # Update the deployment
    print_message "Updating deployment..."
    docker stack deploy -c docker-compose.yml aggr-stack
    
    print_success "Collector ${name} has been removed"
}

# Function to list all collectors
list_collectors() {
    print_message "Current collectors:"
    echo
    
    # Extract collector names and their pairs from docker-compose.yml
    grep -A 5 "collector-.*:" docker-compose.yml | grep -E "collector-.*:|PAIRS=" | sed 's/://g' | paste -d ' ' - - | \
        while read -r line; do
            name=$(echo "$line" | cut -d' ' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            pairs=$(echo "$line" | grep -o 'PAIRS=[^ ]*' | cut -d= -f2)
            echo "Name: ${name}"
            echo "Pairs: ${pairs}"
            
            # Get current replicas if service is running
            replicas=$(docker service ls --filter name="aggr-stack_${name}" --format "{{.Replicas}}" 2>/dev/null || echo "Not deployed")
            echo "Current replicas: ${replicas}"
            echo
        done
}

# Main script
case "$1" in
    "add")
        validate_input "$2" "$3"
        add_market_collector "$2" "$3"
        ;;
    "scale")
        validate_input "$2" "$3"
        scale_collector "$2" "$3"
        ;;
    "remove")
        validate_input "$2" "dummy"
        remove_collector "$2"
        ;;
    "list")
        list_collectors
        ;;
    *)
        print_error "Invalid command!"
        echo "Usage:"
        echo "  Add new collector:    $0 add <name> <pairs>"
        echo "  Scale collector:      $0 scale <name> <replicas>"
        echo "  Remove collector:     $0 remove <name>"
        echo "  List collectors:      $0 list"
        exit 1
        ;;
esac
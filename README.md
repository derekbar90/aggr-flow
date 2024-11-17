# Aggr Server Production Setup

Production and development deployment setup for [Aggr Server](https://github.com/Tucsky/aggr-server).

## Quick Start

1. Clone the repository with submodules:
```bash
git clone --recursive <your-repo-url>
cd <repo-name>
```

2. Initialize environment files:
```bash
./scripts/env.sh init
```

3. Deploy:

For development (local machine):
```bash
./scripts/env.sh dev
```

For production:
```bash
./scripts/env.sh prod
```

## Environment Management

The setup supports both development and production environments:

### Development Environment
```bash
# Start development environment
./scripts/env.sh dev

# Stop development environment
./scripts/env.sh stop

# View logs
./scripts/env.sh logs

# Clean up resources
./scripts/env.sh cleanup
```

Features:
- Hot reloading enabled
- Source code mounting
- Local machine friendly
- Easy debugging
- Chronograf UI for monitoring
- Telegraf metrics collection

### Production Environment
```bash
# Start production environment
./scripts/env.sh prod

# Stop production environment
./scripts/env.sh stop prod

# View logs
./scripts/env.sh logs prod [service]

# Clean up resources
./scripts/env.sh cleanup prod
```

Features:
- Docker Swarm deployment
- Optimized for performance
- Scaling support
- Production-grade monitoring

## Managing Collectors

Add, remove, or scale collectors using the market scaling script:

```bash
# Add new collector
./scripts/market-scaling.sh add "defi-1" "COINBASE:UNI-USD,BINANCE:uniusdt"

# Scale collector (production only)
./scripts/market-scaling.sh scale "btc-major" 2

# Remove collector
./scripts/market-scaling.sh remove "defi-1"

# List all collectors
./scripts/market-scaling.sh list
```

## Configuration

### API Node Configuration
```json
{
  "api": true,
  "collect": false,
  "storage": ["influx"],
  "influxCollectors": true,
  "influxHost": "influx",
  "influxPort": 8086
}
```

### Collector Configuration
```json
{
  "api": false,
  "collect": true,
  "storage": ["influx"],
  "influxCollectors": true,
  "id": "<collector-id>",
  "influxHost": "influx",
  "influxPort": 8086
}
```

## Services

### Core Services
- **API Node**: Main API service (port 3000)
- **Collectors**: Market data collectors (BTC, ETH, etc.)
- **InfluxDB**: Time series database (port 8086)

### Monitoring Services
- **Chronograf**: Data visualization (port 8885)
- **Telegraf**: Metrics collection

## Directory Structure

```
.
├── src/                    # aggr-server submodule
├── config/                 # Configuration files
│   ├── api/               # API node configs
│   ├── collectors/        # Collector configs
│   ├── chronograf/        # Chronograf configs
│   └── telegraf/          # Telegraf configs
├── docker/                # Docker related files
│   ├── Dockerfile        # Production Dockerfile
│   └── Dockerfile.dev    # Development Dockerfile
├── scripts/               # Management scripts
│   ├── env.sh           # Environment management
│   ├── market-scaling.sh # Collector management
│   ├── update.sh        # Update script
│   └── wait-for-it.sh   # Service startup script
├── data/                  # Persistent data
├── docker-compose.dev.yml # Development compose
└── docker-compose.prod.yml # Production compose
```

## Ports

Development:
- API: `localhost:3000`
- InfluxDB: `localhost:8086`
- Chronograf: `localhost:8885`

Production:
- API: Configured via `API_PORT`
- InfluxDB: Internal only
- Chronograf: Internal only

## Troubleshooting

1. **Services not starting**:
   ```bash
   # Check service logs
   ./scripts/env.sh logs [service]
   
   # Check InfluxDB connection
   docker exec -it aggr-influx influx -execute 'SHOW DATABASES'
   ```

2. **Data not being collected**:
   - Verify collector configurations in `config/collectors/`
   - Check InfluxDB connection in service logs
   - Verify market pairs format
   - Check Chronograf UI for data flow

3. **Performance issues**:
   - Monitor resource usage in Chronograf
   - Scale collectors in production
   - Check network connectivity
   - Review service logs for bottlenecks

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For issues related to:
- Original project: [GitHub Issues](https://github.com/Tucsky/aggr-server/issues)
- Production setup: Create issues in your fork

## License

Same as [Aggr Server](https://github.com/Tucsky/aggr-server)

## Supporting the Project

If you like what is being done here, consider supporting the original project:

ETH: 0xe3c893cdA4bB41fCF402726154FB4478Be2732CE
BTC: 3PK1bBK8sG3zAjPBPD7g3PL14Ndux3zWEz
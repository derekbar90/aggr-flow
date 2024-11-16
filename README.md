# Aggr Server Production Setup

Production and development deployment setup for [Aggr Server](https://github.com/Tucsky/aggr-server).

## Quick Start

1. Clone the repository with submodules:
```bash
git clone --recursive <your-repo-url>
cd <repo-name>
```

2. Configure environments:
```bash
# Development environment
cp .env.dev.example .env.dev

# Production environment
cp .env.prod.example .env.prod
```

3. Deploy:

For development (local machine/Mac):
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
- Hot reloading enabled
- Source code mounting
- Local machine friendly
- Easy debugging

```bash
# Start development environment
./scripts/env.sh dev

# Stop development environment
./scripts/env.sh down

# View logs
docker-compose -f docker-compose.dev.yml logs -f
```

### Production Environment
- Docker Swarm deployment
- Optimized for performance
- Scaling support
- Production-grade monitoring

```bash
# Start production environment
./scripts/env.sh prod

# Stop production environment
./scripts/env.sh down prod

# View logs
docker service logs aggr-stack_api
```

## Managing Collectors

Add, remove, or scale collectors using the market scaling script:

```bash
# Add new collector
./scripts/market-scaling.sh add "defi-1" "COINBASE:UNI-USD,BINANCE:uniusdt"

# Scale collector
./scripts/market-scaling.sh scale "btc-major" 2

# Remove collector
./scripts/market-scaling.sh remove "defi-1"

# List all collectors
./scripts/market-scaling.sh list
```

## Update Aggr Server

To update to the latest version:
```bash
./scripts/update.sh
```

## Directory Structure

```
.
├── src/                    # aggr-server submodule
├── config/                 # Configuration files
│   ├── api/               # API node configs
│   └── collectors/        # Collector configs
├── docker/                # Docker related files
│   ├── Dockerfile        # Production Dockerfile
│   └── Dockerfile.dev    # Development Dockerfile
├── scripts/               # Deployment and maintenance scripts
│   ├── env.sh           # Environment management
│   ├── update.sh        # Update script
│   └── market-scaling.sh # Collector management
├── data/                  # Persistent data directory
├── docker-compose.dev.yml # Development compose file
└── docker-compose.prod.yml # Production compose file
```

## Services

- **API Node**: Main API service (port 3000)
- **Collectors**: Market data collectors (BTC, ETH, etc.)
- **InfluxDB**: Time series database (port 8086)
- **Chronograf**: Data visualization (port 8885)

## Ports

Development:
- API: `localhost:3000`
- InfluxDB: `localhost:8086`
- Chronograf: `localhost:8885`

Production:
- API: Configured via `API_PORT`
- InfluxDB: Configured via `INFLUX_PORT`
- Chronograf: Port 8885

## Configuration

### API Node
```json
{
  "api": true,
  "collect": false,
  "storage": ["influx"],
  "influxCollectors": true
}
```

### Collectors
```json
{
  "api": false,
  "collect": true,
  "storage": ["influx"],
  "influxCollectors": true,
  "id": "<collector-id>"
}
```

## Troubleshooting

1. **Services not starting**:
   ```bash
   # Check logs
   docker-compose -f docker-compose.dev.yml logs -f  # Development
   docker service logs aggr-stack_api              # Production
   ```

2. **Data not being collected**:
   - Verify collector configurations
   - Check InfluxDB connection
   - Verify market pairs format

3. **Performance issues**:
   - Monitor resource usage
   - Scale collectors if needed
   - Check network connectivity

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

- ETH: 0xe3c893cdA4bB41fCF402726154FB4478Be2732CE
- BTC: 3PK1bBK8sG3zAjPBPD7g3PL14Ndux3zWEz
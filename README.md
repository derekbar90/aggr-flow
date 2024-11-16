# Aggr Server Production Setup

Production deployment setup for [Aggr Server](https://github.com/Tucsky/aggr-server).

## Quick Start

1. Clone the repository with submodules:
```bash
git clone --recursive <your-repo-url>
cd <repo-name>
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env with your settings
```

3. Deploy:
```bash
./scripts/deploy.sh
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
│   └── Dockerfile
├── scripts/               # Deployment and maintenance scripts
├── data/                  # Persistent data directory
└── docker-compose.yml     # Production compose file
```

## License

Same as [Aggr Server](https://github.com/Tucsky/aggr-server)

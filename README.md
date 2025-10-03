# Redis Enterprise Observability

Comprehensive monitoring and observability solutions for Redis Enterprise deployments.

## Overview

This repository provides pre-built dashboards, metrics configurations, and integration guides for monitoring Redis Enterprise across multiple observability platforms.

## Supported Platforms

- **Grafana** - Visualization and analytics
- **Prometheus** - Metrics collection and time-series storage
- **Dynatrace** - Full-stack monitoring
- **New Relic** - Application performance monitoring
- **Splunk** - Log analytics and SIEM
- **Kibana** - Elasticsearch visualization

## Documentation

📚 **[View the complete documentation](https://redis-field-engineering.github.io/redis-enterprise-observability/)**

The documentation includes:
- Quick start guides
- Platform-specific integration instructions
- Dashboard catalog
- Monitoring best practices
- Alerting configuration
- Metrics reference
- Troubleshooting guides

### Building Documentation Locally

```bash
# Install dependencies
npm install

# Generate documentation site
npm run docs

# View the site
open build/site/index.html

# Or serve locally
npm run docs:serve
# Visit http://localhost:8080
```

## Quick Start

1. Choose your observability platform
2. Follow the platform-specific guide in the [documentation](https://redis-field-engineering.github.io/redis-enterprise-observability/)
3. Import pre-built dashboards from the catalog
4. Configure alerting based on your requirements

## Repository Structure

```
.
├── docs/                      # Antora documentation source
│   ├── antora.yml            # Component descriptor
│   └── modules/ROOT/
│       ├── pages/            # Documentation pages (AsciiDoc)
│       └── nav.adoc          # Navigation menu
├── grafana/                   # Grafana dashboards
├── prometheus/                # Prometheus configurations
├── dynatrace/                 # Dynatrace integrations
├── newrelic/                  # New Relic dashboards
├── splunk/                    # Splunk configurations
└── kibana/                    # Kibana dashboards
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For documentation contributions, see [docs/README.md](docs/README.md).

## Resources

- [Redis Enterprise Documentation](https://docs.redis.com/latest/rs/)
- [Redis Cloud Documentation](https://docs.redis.com/latest/rc/)
- [Antora Documentation](https://docs.antora.org/)

## License

See [LICENSE](LICENSE) for details.

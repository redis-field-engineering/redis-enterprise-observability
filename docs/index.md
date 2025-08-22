# Redis Enterprise Observability

Production-ready monitoring dashboards, alerting rules, and observability configurations for Redis Enterprise and Redis Cloud.

## Quick Navigation

### 📊 **Grafana Dashboards**
Ready-to-use dashboards for Redis Enterprise monitoring with Prometheus metrics and REST API data  
[→ Get started](platforms/grafana/index.md)

### 🚨 **Prometheus Alerts**
Pre-configured alerting rules for capacity, performance, and availability monitoring  
[→ Configure alerts](platforms/prometheus/alerts.md)

### ☁️ **Redis Cloud**
Specialized dashboards and monitoring for Redis Cloud deployments  
[→ Monitor Cloud](guides/redis-cloud.md)

### 🔌 **Platform Integrations**
Support for Dynatrace, New Relic, Splunk, Kibana, and more  
[→ View platforms](platforms/grafana/index.md)

## What's Included

### 📊 Dashboards
- **Basic**: Essential monitoring for cluster, database, node, and shard metrics
- **Extended**: Advanced monitoring with configuration data via Infinity plugin
- **Workflow**: Drill-down dashboards for detailed analysis
- **Cloud**: Specialized dashboards for Redis Cloud subscriptions

### 🚨 Alerting
- Capacity planning alerts
- Performance degradation detection
- Availability monitoring
- Replication lag tracking

### 🔌 Platform Support
- **Grafana** (v7-11) with Prometheus and Infinity datasources
- **Prometheus** with comprehensive alerting rules
- **Dynatrace** extensions and dashboards
- **New Relic** dashboard configurations
- **Splunk** monitoring setup
- **Kibana** visualization dashboards

## Quick Start

=== "Docker Compose"

    ```bash
    # Clone the repository
    git clone https://github.com/redis-field-engineering/redis-enterprise-observability.git
    cd redis-enterprise-observability
    
    # Start demo environment (Grafana v9-11)
    cd grafana_v2/demo_v2
    ./setup.sh
    ```

=== "Manual Setup"

    1. Install Grafana and Prometheus
    2. Configure Prometheus to scrape Redis Enterprise metrics
    3. Import dashboards from `grafana_v2/dashboards/`
    4. Configure alerting rules from `prometheus_v2/alert_rules/`

=== "Infinity Plugin"

    For extended dashboards with REST API data:
    
    ```bash
    # Install Infinity plugin
    grafana-cli plugins install yesoreyeram-infinity-datasource
    
    # Restart Grafana
    systemctl restart grafana-server
    ```
    
    [Full setup guide →](platforms/grafana/index.md)

## Version Compatibility

| Component | Version | Directory | Status |
|-----------|---------|-----------|--------|
| Grafana | 9-11 | `grafana_v2/` | ✅ Current |
| Grafana | 7-9 | `grafana/` | ⚠️ Legacy |
| Prometheus | 2.x | `prometheus_v2/` | ✅ Current |
| Redis Enterprise | 6.x-7.x | All | ✅ Supported |
| Redis Cloud | Current | All cloud dirs | ✅ Supported |

!!! tip "Which version to use?"
    Use the `_v2` directories for new installations. Legacy directories are maintained for backward compatibility only.

## Need Help?

- 📖 [Browse the documentation](getting-started/overview.md)
- 🔍 Use the search bar above to find specific topics
- 💬 [Join us on Slack](https://redis.slack.com/archives/C03NJNWS6E5)
- 🐛 [Report issues on GitHub](https://github.com/redis-field-engineering/redis-enterprise-observability/issues)
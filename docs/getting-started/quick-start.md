# Quick Start

Get Redis Enterprise monitoring up and running in 5 minutes.

## Option 1: Docker Compose (Fastest)

**💡 Tip:** This option sets up Redis Enterprise, Prometheus, Grafana, and sample dashboards automatically.

```bash
# Clone the repository
git clone https://github.com/redis-field-engineering/redis-enterprise-observability.git
cd redis-enterprise-observability

# Start Grafana v9-11 demo
cd grafana_v2/demo_v2
./setup.sh

# Access the services
# Grafana: http://localhost:3000 (admin/admin)
# Redis Enterprise: https://localhost:8443
# Prometheus: http://localhost:9090
```

## Option 2: Import to Existing Grafana

### Step 1: Configure Prometheus

Add Redis Enterprise as a scrape target:

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'redis-enterprise'
    scrape_interval: 15s
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ['your-cluster:8070']
```

### Step 2: Import Dashboards

=== "Via UI"
    1. Open Grafana → Dashboards → Import
    2. Upload JSON files from `grafana_v2/dashboards/grafana_v9-11/software/basic/`
    3. Select your Prometheus datasource
    4. Click Import

=== "Via API"
    ```bash
    # Set your Grafana URL and API key
    GRAFANA_URL="http://localhost:3000"
    API_KEY="your-api-key"
    
    # Import cluster dashboard
    curl -X POST "$GRAFANA_URL/api/dashboards/db" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d @grafana_v2/dashboards/grafana_v9-11/software/basic/redis-software-cluster-dashboard_v9-11.json
    ```

### Step 3: Configure Alerts (Optional)

```bash
# Copy alert rules to Prometheus
cp prometheus_v2/alert_rules/*.yml /etc/prometheus/rules/

# Reload Prometheus configuration
curl -X POST http://prometheus:9090/-/reload
```

## Option 3: Infinity Plugin Setup

For extended dashboards with REST API data:

### Install Plugin
```bash
grafana-cli plugins install yesoreyeram-infinity-datasource
systemctl restart grafana-server
```

### Configure Datasource
1. Go to Configuration → Data Sources → Add
2. Search for "Infinity"
3. Configure:
   - Authentication: Basic Auth
   - Username: Your Redis Enterprise username
   - Password: Your Redis Enterprise password
   - Allowed Hosts: `your-cluster:9443`

### Import Extended Dashboards
```bash
# Import dashboards with API data
cd grafana_v2/dashboards/grafana_v9-11/software/extended/
# Import redis-software-database-extended-dashboard_v9-11.json
```

## Verify Installation

### Check Metrics Collection
```promql
# Run in Prometheus or Grafana Explore
up{job="redis-enterprise"}
```

### Check Dashboard Data
1. Open any imported dashboard
2. Verify graphs show data
3. Check time range (last 15 minutes)

## Common Issues

??? failure "No data in dashboards"
    1. Verify Prometheus can reach Redis Enterprise:
    ```bash
    curl -k https://your-cluster:8070/metrics
    ```
    2. Check Prometheus targets: http://prometheus:9090/targets
    3. Ensure time range includes recent data

??? failure "Import fails"
    1. Check Grafana version (requires 9.0+)
    2. Verify Prometheus datasource exists
    3. Check JSON file is valid

## Next Steps

- [Browse Dashboard Catalog](../dashboards/catalog.md)
- [Configure Alerting](../platforms/prometheus/alerts.md)
- [Add Infinity Plugin](../platforms/grafana/infinity-plugin.md)
- [Troubleshooting Guide](../guides/troubleshooting.md)
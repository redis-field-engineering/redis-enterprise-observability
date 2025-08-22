#!/bin/bash

# Generate comprehensive documentation site from existing content
# Preserves repo structure while creating navigable docs

echo "🚀 Generating comprehensive documentation site..."

# Create directory structure
mkdir -p docs/{getting-started,platforms/{grafana,prometheus,dynatrace,newrelic,splunk,kibana},dashboards,guides,reference}

# ====================
# Platform Documentation
# ====================

# Grafana
echo "📊 Processing Grafana documentation..."
if [ -f "grafana_v2/README.md" ]; then
  echo "# Grafana Platform" > docs/platforms/grafana/index.md
  echo "" >> docs/platforms/grafana/index.md
  echo "## Current Version (v9-11)" >> docs/platforms/grafana/index.md
  cat grafana_v2/README.md >> docs/platforms/grafana/index.md
  
  if [ -f "grafana/README.md" ]; then
    echo "" >> docs/platforms/grafana/index.md
    echo "## Legacy Version (v7-9)" >> docs/platforms/grafana/index.md
    cat grafana/README.md >> docs/platforms/grafana/index.md
  fi
fi

# Grafana Dashboards
echo "# Grafana Dashboards Documentation" > docs/platforms/grafana/dashboards.md
if [ -f "grafana_v2/dashboards/grafana_v9-11/README_v9-11.md" ]; then
  cat grafana_v2/dashboards/grafana_v9-11/README_v9-11.md >> docs/platforms/grafana/dashboards.md
fi

# Infinity Plugin (if exists)
if [ -f "grafana_v2/README-INFINITY.md" ]; then
  cp grafana_v2/README-INFINITY.md docs/platforms/grafana/infinity-plugin.md
fi

# Prometheus
echo "🚨 Processing Prometheus documentation..."
echo "# Prometheus Integration" > docs/platforms/prometheus/index.md
if [ -d "prometheus_v2" ]; then
  echo "## Alert Rules" >> docs/platforms/prometheus/index.md
  echo "" >> docs/platforms/prometheus/index.md
  echo "Available alert rule files:" >> docs/platforms/prometheus/index.md
  for file in prometheus_v2/alert_rules/*.yml; do
    if [ -f "$file" ]; then
      name=$(basename "$file" .yml)
      echo "- [$name](https://github.com/redis-field-engineering/redis-enterprise-observability/blob/main/prometheus_v2/alert_rules/$name.yml)" >> docs/platforms/prometheus/index.md
    fi
  done
fi

# Create Prometheus alerts page
echo "# Prometheus Alert Rules" > docs/platforms/prometheus/alerts.md
echo "" >> docs/platforms/prometheus/alerts.md
echo "## Available Alert Categories" >> docs/platforms/prometheus/alerts.md
echo "" >> docs/platforms/prometheus/alerts.md
for file in prometheus_v2/alert_rules/*.yml; do
  if [ -f "$file" ]; then
    name=$(basename "$file" .yml)
    echo "### $name" >> docs/platforms/prometheus/alerts.md
    echo '```yaml' >> docs/platforms/prometheus/alerts.md
    head -20 "$file" >> docs/platforms/prometheus/alerts.md
    echo '```' >> docs/platforms/prometheus/alerts.md
    echo "[View full file →](https://github.com/redis-field-engineering/redis-enterprise-observability/blob/main/prometheus_v2/alert_rules/$name.yml)" >> docs/platforms/prometheus/alerts.md
    echo "" >> docs/platforms/prometheus/alerts.md
  fi
done

# Dynatrace
echo "📈 Processing Dynatrace documentation..."
echo "# Dynatrace Integration" > docs/platforms/dynatrace/index.md
if [ -f "dynatrace_v2/README.md" ]; then
  cat dynatrace_v2/README.md >> docs/platforms/dynatrace/index.md
elif [ -f "dynatrace/README.md" ]; then
  cat dynatrace/README.md >> docs/platforms/dynatrace/index.md
else
  echo "Dynatrace monitoring extensions and dashboards for Redis Enterprise." >> docs/platforms/dynatrace/index.md
  echo "" >> docs/platforms/dynatrace/index.md
  echo "## Available Resources" >> docs/platforms/dynatrace/index.md
  echo "- Extensions in \`dynatrace_v2/\`" >> docs/platforms/dynatrace/index.md
  echo "- Legacy version in \`dynatrace/\`" >> docs/platforms/dynatrace/index.md
fi

# New Relic
echo "📊 Processing New Relic documentation..."
echo "# New Relic Integration" > docs/platforms/newrelic/index.md
if [ -f "newrelic_v2/README.md" ]; then
  cat newrelic_v2/README.md >> docs/platforms/newrelic/index.md
elif [ -f "newrelic/README.md" ]; then
  cat newrelic/README.md >> docs/platforms/newrelic/index.md
else
  echo "New Relic dashboard configurations for Redis Enterprise monitoring." >> docs/platforms/newrelic/index.md
  echo "" >> docs/platforms/newrelic/index.md
  echo "## Available Resources" >> docs/platforms/newrelic/index.md
  echo "- Dashboard configs in \`newrelic_v2/\`" >> docs/platforms/newrelic/index.md
  echo "- Docker setup in \`newrelic_v2/docker/\`" >> docs/platforms/newrelic/index.md
fi

# Splunk
echo "🔍 Processing Splunk documentation..."
echo "# Splunk Integration" > docs/platforms/splunk/index.md
if [ -f "splunk/README.md" ]; then
  cat splunk/README.md >> docs/platforms/splunk/index.md
else
  echo "Splunk dashboard configurations and search queries for Redis Enterprise." >> docs/platforms/splunk/index.md
  echo "" >> docs/platforms/splunk/index.md
  echo "## Available Resources" >> docs/platforms/splunk/index.md
  echo "- Dashboard XMLs in \`splunk/\`" >> docs/platforms/splunk/index.md
fi

# Kibana
echo "📊 Processing Kibana documentation..."
echo "# Kibana Integration" > docs/platforms/kibana/index.md
if [ -f "kibana/README.md" ]; then
  cat kibana/README.md >> docs/platforms/kibana/index.md
else
  echo "Kibana visualization dashboards for Redis Enterprise with Elasticsearch." >> docs/platforms/kibana/index.md
  echo "" >> docs/platforms/kibana/index.md
  echo "## Available Resources" >> docs/platforms/kibana/index.md
  echo "- Dashboard configs in \`kibana/\`" >> docs/platforms/kibana/index.md
fi

# ====================
# Dashboard Catalog
# ====================

echo "📚 Building dashboard catalog..."
cat > docs/dashboards/catalog.md << 'EOF'
# Dashboard Catalog

Complete listing of all available dashboards across platforms and versions.

## Grafana Dashboards

### Version 9-11 (Current)

#### Basic Dashboards
Essential monitoring dashboards for Redis Enterprise.

| Dashboard | Description | Type | Path |
|-----------|-------------|------|------|
EOF

for file in grafana_v2/dashboards/grafana_v9-11/software/basic/*.json; do
  if [ -f "$file" ]; then
    name=$(basename "$file" .json | sed 's/_v9-11//' | sed 's/-/ /g' | sed 's/redis software/Redis Software/' | sed 's/\b\(.\)/\u\1/g')
    filename=$(basename "$file")
    echo "| $name | Core monitoring dashboard | Basic | [Download](https://github.com/redis-field-engineering/redis-enterprise-observability/blob/main/grafana_v2/dashboards/grafana_v9-11/software/basic/$filename) |" >> docs/dashboards/catalog.md
  fi
done

cat >> docs/dashboards/catalog.md << 'EOF'

#### Extended Dashboards
Advanced dashboards with REST API data via Infinity plugin.

| Dashboard | Description | Type | Path |
|-----------|-------------|------|------|
EOF

for file in grafana_v2/dashboards/grafana_v9-11/software/extended/*.json; do
  if [ -f "$file" ]; then
    name=$(basename "$file" .json | sed 's/_v9-11//' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    filename=$(basename "$file")
    echo "| $name | Extended monitoring with API data | Extended | [Download](https://github.com/redis-field-engineering/redis-enterprise-observability/blob/main/grafana_v2/dashboards/grafana_v9-11/software/extended/$filename) |" >> docs/dashboards/catalog.md
  fi
done

cat >> docs/dashboards/catalog.md << 'EOF'

#### Cloud Dashboards
Specialized dashboards for Redis Cloud monitoring.

| Dashboard | Description | Type | Path |
|-----------|-------------|------|------|
EOF

for file in grafana_v2/dashboards/grafana_v9-11/cloud/basic/*.json; do
  if [ -f "$file" ]; then
    name=$(basename "$file" .json | sed 's/_v9-11//' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    filename=$(basename "$file")
    echo "| $name | Redis Cloud monitoring | Cloud | [Download](https://github.com/redis-field-engineering/redis-enterprise-observability/blob/main/grafana_v2/dashboards/grafana_v9-11/cloud/basic/$filename) |" >> docs/dashboards/catalog.md
  fi
done

# ====================
# Reference Documentation
# ====================

echo "📖 Creating reference documentation..."

# Metrics Reference
cat > docs/reference/metrics.md << 'EOF'
# Redis Enterprise Metrics Reference

Complete list of metrics available from Redis Enterprise Prometheus endpoint.

## Cluster Metrics

| Metric | Description | Type | Labels |
|--------|-------------|------|--------|
| `redis_up` | Redis cluster availability | Gauge | cluster |
| `cluster_node_count` | Number of nodes in cluster | Gauge | cluster |
| `cluster_shards_total` | Total number of shards | Gauge | cluster |

## Database Metrics

| Metric | Description | Type | Labels |
|--------|-------------|------|--------|
| `bdb_used_memory` | Memory used by database | Gauge | bdb, cluster |
| `bdb_total_req` | Total requests to database | Counter | bdb, cluster |
| `bdb_conns` | Active connections | Gauge | bdb, cluster |
| `bdb_avg_latency` | Average operation latency | Gauge | bdb, cluster |

## Node Metrics

| Metric | Description | Type | Labels |
|--------|-------------|------|--------|
| `node_cpu_user` | CPU user percentage | Gauge | node, cluster |
| `node_cpu_system` | CPU system percentage | Gauge | node, cluster |
| `node_free_memory` | Free memory on node | Gauge | node, cluster |
| `node_available_memory` | Available memory on node | Gauge | node, cluster |

## Shard Metrics

| Metric | Description | Type | Labels |
|--------|-------------|------|--------|
| `redis_used_memory` | Memory used by shard | Gauge | shard, bdb, node |
| `redis_ops_per_sec` | Operations per second | Gauge | shard, bdb, node |
| `redis_connected_clients` | Connected clients | Gauge | shard, bdb, node |

[Full metrics documentation →](https://docs.redis.com/latest/rs/clusters/monitoring/prometheus-metrics-definitions/)
EOF

# API Reference
cat > docs/reference/api.md << 'EOF'
# Redis Enterprise REST API Reference

Key endpoints for configuration and monitoring data.

## Authentication

All API calls require authentication:

```bash
curl -u username:password https://cluster:9443/v1/...
```

## Common Endpoints

### Cluster Information
```
GET /v1/cluster
```
Returns cluster configuration and status.

### Database List
```
GET /v1/bdbs
```
Returns all databases with configuration.

### Node Status
```
GET /v1/nodes
```
Returns node information and health.

### Shard Distribution
```
GET /v1/shards
```
Returns shard placement and status.

### Database Statistics
```
GET /v1/bdbs/{uid}/stats
```
Returns detailed database statistics.

## Example Responses

### Database Configuration
```json
{
  "uid": 1,
  "name": "database-1",
  "port": 12000,
  "memory_size": 1073741824,
  "type": "redis",
  "module_list": [
    {"module_name": "search"},
    {"module_name": "timeseries"}
  ]
}
```

[Full API documentation →](https://docs.redis.com/latest/rs/references/rest-api/)
EOF

# Compatibility Matrix
cat > docs/reference/compatibility.md << 'EOF'
# Compatibility Matrix

Version compatibility across different components.

## Platform Versions

| Component | Supported Versions | Recommended | Directory |
|-----------|-------------------|-------------|-----------|
| **Grafana** | 7.0 - 11.x | 9.0+ | `grafana_v2/` |
| **Prometheus** | 2.0+ | 2.40+ | `prometheus_v2/` |
| **Redis Enterprise** | 6.0+ | 7.2+ | All |
| **Redis Cloud** | All | Latest | All |

## Dashboard Compatibility

| Dashboard Set | Grafana Version | Prometheus | Features |
|---------------|-----------------|------------|----------|
| `grafana/` | 7.0 - 9.x | 2.0+ | Basic metrics |
| `grafana_v2/` | 9.0 - 11.x | 2.0+ | Basic + Extended |
| Extended dashboards | 9.0+ | 2.0+ | Requires Infinity plugin |

## Plugin Requirements

| Plugin | Minimum Grafana | Purpose |
|--------|----------------|---------|
| Prometheus datasource | 7.0 | Metrics |
| Infinity datasource | 9.0 | REST API data |

## Migration Guide

### From v1 to v2 Dashboards

1. **Check Grafana version**
   - v7-9: Can use either version
   - v9+: Recommend v2 dashboards

2. **Update import paths**
   ```bash
   # Old
   grafana/dashboards/grafana_v7-9/
   
   # New
   grafana_v2/dashboards/grafana_v9-11/
   ```

3. **Update datasource references**
   - Ensure Prometheus datasource UID matches
   - Add Infinity datasource for extended dashboards

## Deprecation Timeline

| Component | Deprecation Date | Removal Date | Migration Path |
|-----------|-----------------|--------------|----------------|
| Grafana v7-9 dashboards | Q2 2024 | Q4 2024 | Use v9-11 dashboards |
| Prometheus v1 rules | Q1 2024 | Q3 2024 | Use v2 alert rules |
EOF

echo ""
echo "✅ Documentation generation complete!"
echo ""
echo "📝 Created/Updated:"
echo "  - Platform pages for all integrations"
echo "  - Complete dashboard catalog"
echo "  - Reference documentation"
echo "  - Compatibility matrix"
echo ""
echo "To preview: mkdocs serve"
echo "To deploy: mkdocs gh-deploy"
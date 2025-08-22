# Monitoring Redis Cloud

Complete guide for monitoring Redis Cloud subscriptions and databases.

## Overview

Redis Cloud requires different metrics and dashboards than self-managed Redis Enterprise due to its fully-managed nature.

## Key Differences

| Aspect | Redis Enterprise | Redis Cloud |
|--------|-----------------|-------------|
| **Node Metrics** | Full access | Not exposed |
| **Shard Details** | Full visibility | Limited |
| **Configuration** | Full control | Managed |
| **API Access** | Cluster API | Cloud API |

## Setup Instructions

### Step 1: Enable Metrics Export

1. Log into Redis Cloud console
2. Navigate to **Subscriptions** → Your subscription
3. Click **Metrics** tab
4. Enable **Prometheus Integration**
5. Copy the metrics endpoint URL

### Step 2: Configure Prometheus

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'redis-cloud'
    scrape_interval: 30s
    scheme: https
    static_configs:
      - targets: ['your-metrics-endpoint.redis-cloud.com']
    bearer_token: 'your-api-key'
```

### Step 3: Import Cloud Dashboards

Use the specialized Redis Cloud dashboards:

```bash
# Subscription overview
grafana_v2/dashboards/grafana_v9-11/cloud/basic/redis-cloud-subscription-dashboard_v9-11.json

# Database monitoring
grafana_v2/dashboards/grafana_v9-11/cloud/basic/redis-cloud-database-dashboard_v9-11.json
```

## Available Metrics

### Subscription Metrics
- `subscription_memory_limit` - Total memory allocated
- `subscription_memory_used` - Memory in use
- `subscription_throughput` - Operations per second
- `subscription_connections` - Active connections

### Database Metrics
- `bdb_used_memory` - Database memory usage
- `bdb_total_req` - Total requests
- `bdb_avg_latency` - Average latency
- `bdb_evicted_objects` - Eviction rate

## Using the Cloud API

### Authentication
```bash
export API_KEY="your-api-key"
export SECRET_KEY="your-secret-key"

curl -X GET "https://api.redislabs.com/v1/subscriptions" \
  -H "x-api-key: $API_KEY" \
  -H "x-api-secret-key: $SECRET_KEY"
```

### Common API Queries

#### List Databases
```bash
curl -X GET "https://api.redislabs.com/v1/subscriptions/{id}/databases"
```

#### Get Database Stats
```bash
curl -X GET "https://api.redislabs.com/v1/subscriptions/{id}/databases/{db-id}/stats"
```

## Alerting for Redis Cloud

### Essential Alerts

```yaml
groups:
  - name: redis_cloud_alerts
    rules:
      - alert: HighMemoryUsage
        expr: subscription_memory_used / subscription_memory_limit > 0.8
        for: 5m
        annotations:
          summary: "Redis Cloud subscription memory usage above 80%"
      
      - alert: HighLatency
        expr: bdb_avg_latency > 1000
        for: 5m
        annotations:
          summary: "Database latency exceeding 1ms"
```

## Cost Optimization

### Monitor for Cost Efficiency

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Memory Usage | < 80% | Consider smaller plan |
| Throughput | < 80% of limit | Review plan sizing |
| Connection Count | < 90% of limit | Check connection pooling |

### Scaling Recommendations

1. **Auto-scaling triggers**
   - Memory > 85% for 10 minutes
   - Throughput > 90% sustained
   - Connection limit approached

2. **Manual review triggers**
   - Consistent < 50% utilization
   - Seasonal pattern changes
   - Cost per operation increase

## Troubleshooting

### Common Issues

**High Latency**
- Check region placement
- Review operation complexity
- Verify network path

**Memory Issues**
- Monitor eviction policy
- Check key expiration
- Review memory fragmentation

**Connection Limits**
- Implement connection pooling
- Review client lifecycle
- Check for connection leaks

## Best Practices

1. **Use dedicated metrics endpoint** - Don't scrape multiple times
2. **Set appropriate intervals** - 30s minimum for Cloud
3. **Monitor costs** - Set budget alerts
4. **Use Cloud API** - For configuration data
5. **Regional awareness** - Monitor cross-region latency
# Performance Tuning

Optimize your Redis Enterprise monitoring for scale and efficiency.

## Prometheus Optimization

### Storage Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 30s     # Increase for less granularity
  evaluation_interval: 30s  # Match scrape interval

# Storage settings (command line flags)
--storage.tsdb.retention.time=30d
--storage.tsdb.retention.size=50GB
--storage.tsdb.path=/prometheus
--storage.tsdb.wal-compression
```

### Recording Rules

Create pre-computed metrics for expensive queries:

```yaml
# recording_rules.yml
groups:
  - name: redis_5m
    interval: 5m
    rules:
      - record: instance:bdb_ops:rate5m
        expr: rate(bdb_total_req[5m])
      
      - record: instance:bdb_memory_usage:ratio
        expr: bdb_used_memory / bdb_memory_limit
      
      - record: cluster:total_memory:sum
        expr: sum(bdb_used_memory) by (cluster)
```

### Scrape Configuration

#### Optimal Intervals

| Metric Type | Recommended Interval | Use Case |
|------------|---------------------|----------|
| Cluster health | 30s | General monitoring |
| Database metrics | 15s | Active databases |
| Node metrics | 30s | Capacity planning |
| Shard metrics | 60s | Detailed analysis |

#### Metric Relabeling

Drop unnecessary metrics to reduce cardinality:

```yaml
scrape_configs:
  - job_name: 'redis-enterprise'
    metric_relabel_configs:
      # Drop histogram buckets if not needed
      - source_labels: [__name__]
        regex: '.*_bucket'
        action: drop
      
      # Keep only essential metrics
      - source_labels: [__name__]
        regex: 'bdb_.*|node_.*|redis_.*'
        action: keep
```

## Grafana Optimization

### Dashboard Best Practices

#### Query Optimization

```promql
# Bad: Fetches all data then filters
sum(rate(bdb_total_req[5m])) by (bdb) > 1000

# Good: Filters at query time
sum(rate(bdb_total_req{bdb=~"1|2|3"}[5m])) by (bdb)
```

#### Variable Optimization

```sql
-- Bad: Queries all time
label_values(bdb_up, bdb)

-- Good: Queries recent data only
label_values(bdb_up{job="redis-enterprise"}[5m], bdb)
```

### Panel Settings

1. **Set appropriate refresh rates**
   ```json
   {
     "refresh": "30s",  // Not "5s" for production
     "time": {
       "from": "now-6h",  // Not "now-30d"
       "to": "now"
     }
   }
   ```

2. **Use shared queries**
   - Create one query and reference it in multiple panels
   - Reduces load on Prometheus

3. **Limit query results**
   ```promql
   topk(10, sort_desc(rate(bdb_total_req[5m])))
   ```

### Caching Strategy

#### Enable Query Caching
```ini
# grafana.ini
[caching]
enabled = true

[dataproxy]
timeout = 300
keep_alive_seconds = 300
```

#### Infinity Plugin Caching
- Set cache duration in datasource settings
- Use 5-minute cache for API data
- Longer cache for configuration data

## Alert Optimization

### Reduce Alert Evaluation Load

```yaml
# Evaluate less frequently for non-critical alerts
groups:
  - name: capacity_alerts
    interval: 5m  # Instead of 1m
    rules:
      - alert: HighMemoryUsage
        expr: bdb_memory_usage_ratio > 0.8
        for: 10m  # Longer wait period
```

### Use Alert Routing

```yaml
# alertmanager.yml
route:
  group_wait: 30s      # Batch initial alerts
  group_interval: 5m   # Batch subsequent alerts
  repeat_interval: 4h  # Reduce repeat notifications
```

## Redis Enterprise Optimization

### Metrics Endpoint Tuning

1. **Enable metrics caching** (if available in your version)
2. **Use dedicated metrics node** for large clusters
3. **Adjust metrics resolution** in cluster settings

### API Performance

For Infinity plugin queries:

1. **Batch API requests**
   ```javascript
   // Good: Single request for multiple resources
   GET /v1/bdbs?fields=uid,name,port,memory_size
   ```

2. **Use field filtering**
   ```javascript
   // Only request needed fields
   GET /v1/bdbs/1?fields=uid,name,status
   ```

3. **Implement client-side caching**
   - Cache static configuration data
   - Refresh dynamic data only

## Scaling Strategies

### Horizontal Scaling

#### Prometheus Federation

```yaml
# Global Prometheus
scrape_configs:
  - job_name: 'federate'
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="redis-enterprise"}'
    static_configs:
      - targets:
        - 'prometheus-dc1:9090'
        - 'prometheus-dc2:9090'
```

#### Thanos Setup

For long-term storage and global view:
```yaml
# Prometheus with Thanos sidecar
prometheus:
  args:
    - '--storage.tsdb.min-block-duration=2h'
    - '--storage.tsdb.max-block-duration=2h'
  
thanos-sidecar:
  args:
    - 'sidecar'
    - '--objstore.config-file=/etc/thanos/bucket.yml'
```

### Vertical Scaling

#### Resource Requirements

| Cluster Size | Prometheus RAM | Prometheus CPU | Storage/Day |
|-------------|---------------|----------------|-------------|
| 1-10 nodes | 4GB | 2 cores | 1GB |
| 10-50 nodes | 16GB | 4 cores | 5GB |
| 50+ nodes | 32GB+ | 8 cores | 10GB+ |

#### Grafana Requirements

| Concurrent Users | RAM | CPU | Cache |
|-----------------|-----|-----|-------|
| < 10 | 2GB | 1 core | 1GB |
| 10-50 | 4GB | 2 cores | 2GB |
| 50+ | 8GB+ | 4 cores | 4GB+ |

## Monitoring the Monitors

### Key Metrics to Watch

```promql
# Prometheus performance
rate(prometheus_engine_query_duration_seconds_sum[5m])
prometheus_tsdb_compaction_duration_seconds
prometheus_tsdb_head_samples_appended_total

# Grafana performance
grafana_api_response_status_total
grafana_api_dataproxy_request_all_milliseconds
```

### Performance Dashboards

Import these dashboards to monitor your monitoring stack:
- Prometheus: Dashboard ID 3681
- Grafana: Dashboard ID 3590
- Node Exporter: Dashboard ID 1860

## Best Practices Summary

1. **Start with conservative settings** - Tune based on actual load
2. **Monitor your monitoring** - Track Prometheus/Grafana metrics
3. **Use recording rules** - Pre-compute expensive queries
4. **Implement caching** - At multiple levels
5. **Regular maintenance** - Clean old data, update configurations
6. **Document changes** - Track what optimizations work
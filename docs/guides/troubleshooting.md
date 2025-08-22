# Troubleshooting Guide

Common issues and solutions for Redis Enterprise observability setup.

## Grafana Issues

### No Data in Dashboards

=== "Prometheus Panels"

    **Symptom**: Graphs show "No data"
    
    **Solutions**:
    
    1. Verify Prometheus is scraping Redis metrics:
    ```bash
    curl http://prometheus:9090/api/v1/targets | jq '.data.activeTargets'
    ```
    
    2. Check Redis Enterprise metrics endpoint:
    ```bash
    curl -k https://your-cluster:8070/metrics
    ```
    
    3. Verify datasource configuration in Grafana:
    - Go to Configuration → Data Sources → Prometheus
    - Click "Test" to verify connectivity

=== "Infinity Panels"

    **Symptom**: Tables show "No data" or "requested URL not allowed"
    
    **Solutions**:
    
    1. Check Allowed Hosts configuration:
    - Go to Configuration → Data Sources → Redis Enterprise API
    - Add your cluster hostname to "Allowed Hosts"
    - Example: `redis-enterprise:9443`
    
    2. Verify authentication:
    ```bash
    # Test API access
    curl -k -u user:pass https://your-cluster:9443/v1/cluster
    ```
    
    3. Add authorization headers to panel:
    ```json
    "headers": [
      {
        "key": "Authorization",
        "value": "Basic <base64-encoded-credentials>"
      }
    ]
    ```

### Dashboard Import Errors

**Symptom**: "Dashboard not found" or "Invalid JSON"

**Solutions**:

1. Check Grafana version compatibility:
   - Use `grafana_v2/` dashboards for Grafana 9-11
   - Use `grafana/` dashboards for Grafana 7-9

2. Verify datasource UIDs match:
   ```bash
   # List datasources
   curl -s http://admin:admin@localhost:3000/api/datasources | jq '.[].uid'
   ```

3. Update dashboard JSON with correct UIDs

## Prometheus Issues

### High Memory Usage

**Symptom**: Prometheus consuming excessive memory

**Solutions**:

1. Adjust retention policy:
   ```yaml
   # prometheus.yml
   global:
     scrape_interval: 30s  # Increase from 15s
   storage:
     tsdb:
       retention.time: 7d   # Reduce from 15d
   ```

2. Reduce metric cardinality:
   ```yaml
   metric_relabel_configs:
     - source_labels: [__name__]
       regex: 'redis_.*_bucket'  # Drop histogram buckets
       action: drop
   ```

### Missing Alerts

**Symptom**: Alerts not firing despite conditions met

**Solutions**:

1. Verify alert rules are loaded:
   ```bash
   curl http://prometheus:9090/api/v1/rules | jq '.data.groups[].rules[].name'
   ```

2. Check alert manager configuration:
   ```yaml
   # alertmanager.yml
   route:
     receiver: 'default'
     group_wait: 10s
     group_interval: 10s
     repeat_interval: 1h
   ```

3. Test alert condition:
   ```promql
   # Run in Prometheus UI
   bdb_used_memory / bdb_memory_limit > 0.8
   ```

## Redis Enterprise Issues

### Metrics Endpoint Not Accessible

**Symptom**: Cannot reach `:8070/metrics`

**Solutions**:

1. Verify metrics exporter is enabled:
   ```bash
   curl -k -u admin:pass https://cluster:9443/v1/cluster/policy | jq '.metrics_exporter'
   ```

2. Check firewall rules:
   ```bash
   # Test connectivity
   nc -zv your-cluster 8070
   ```

3. Enable metrics if disabled:
   ```bash
   curl -k -X PUT -u admin:pass https://cluster:9443/v1/cluster/policy \
     -H "Content-Type: application/json" \
     -d '{"metrics_exporter": true}'
   ```

### Database Metrics Missing

**Symptom**: Cluster metrics present but database metrics absent

**Solutions**:

1. Verify database is active:
   ```bash
   curl -k -u admin:pass https://cluster:9443/v1/bdbs | jq '.[].status'
   ```

2. Check database shards are running:
   ```bash
   curl -k -u admin:pass https://cluster:9443/v1/shards | jq '.[] | {bdb_uid, status}'
   ```

## Quick Diagnostic Commands

```bash
# Check all components
./diagnose.sh

# Component-specific checks
docker ps                          # Container status
curl http://grafana:3000/api/health  # Grafana health
curl http://prometheus:9090/-/ready  # Prometheus ready
redis-cli -h cluster -p 12000 ping   # Redis connectivity
```

## Getting Help

!!! tip "Collect diagnostics before reporting issues"
    Run these commands and include output when reporting issues:
    ```bash
    # System info
    docker version
    docker-compose version
    
    # Component versions
    curl http://grafana:3000/api/frontend/settings | jq '.buildInfo'
    curl http://prometheus:9090/api/v1/status/buildinfo
    
    # Redis Enterprise version
    curl -k https://cluster:9443/v1/cluster | jq '.version'
    ```

- [GitHub Issues](https://github.com/redis-field-engineering/redis-enterprise-observability/issues)
- [Slack Channel](https://redis.slack.com/archives/C03NJNWS6E5)
- [Redis Support](https://redis.com/support/)
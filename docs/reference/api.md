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

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

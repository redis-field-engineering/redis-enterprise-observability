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

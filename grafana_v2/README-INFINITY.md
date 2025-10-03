# Infinity Plugin Setup for Redis Enterprise

The Infinity datasource plugin enables Grafana to fetch data from Redis Enterprise REST API endpoints, providing access to configuration data and cluster information not available through Prometheus metrics.

## Installation

Install the Infinity plugin in Grafana (requires Grafana 9.0+):
```bash
grafana-cli plugins install yesoreyeram-infinity-datasource
# Restart Grafana after installation
```

## Configuration

1. Add a new Infinity data source in Grafana:
   - Go to **Configuration** → **Data Sources** → **Add data source**
   - Search for and select **Infinity**

2. Configure authentication:
   - **Authentication Method**: Basic Authentication
   - **Username**: Your Redis Enterprise username
   - **Password**: Your Redis Enterprise password

3. Configure security settings (REQUIRED):
   - **Allowed Hosts**: Add your Redis Enterprise cluster hostname (e.g., `redis-enterprise:9443`)
     - Without this setting, all queries will fail with "requested URL not allowed"
   - **Skip TLS Verify**: Enable if using self-signed certificates

## Example Panel Configuration

Here's a working example of a panel that displays database modules using the Infinity plugin:

```json
{
  "datasource": {
    "type": "yesoreyeram-infinity-datasource",
    "uid": "${DS_REDIS_ENTERPRISE_API}"
  },
  "targets": [
    {
      "columns": [
        {
          "selector": "name",
          "text": "Database",
          "type": "string"
        },
        {
          "selector": "port",
          "text": "Port",
          "type": "number"
        },
        {
          "selector": "module_list[0].module_name",
          "text": "Module 1",
          "type": "string"
        },
        {
          "selector": "module_list[1].module_name",
          "text": "Module 2",
          "type": "string"
        }
      ],
      "format": "table",
      "source": "url",
      "type": "json",
      "parser": "backend",
      "url": "https://your-cluster:9443/v1/bdbs",  // Replace with your cluster URL
      "url_options": {
        "method": "GET",
        "headers": [
          {
            "key": "Authorization",
            "value": "Basic <base64-encoded-credentials>"  // Replace with your encoded credentials
          }
        ]
      }
    }
  ],
  "title": "Database Modules",
  "type": "table"
}
```

This example shows how to:
- Query the Redis Enterprise REST API
- Extract nested data (module names from arrays)
- Include authorization headers (encode with: `echo -n 'user:pass' | base64`)
- Display results in a table

**Security Note**: Never commit real credentials to version control. Use Grafana variables or secrets management for production dashboards.

## Using Extended Dashboards

The extended dashboards in `grafana_v2/dashboards/grafana_v9-11/software/extended/` and `cloud/extended/` use the Infinity plugin to display:
- Database configuration details
- Cluster topology information
- Database modules (Redis modules like JSON, Search, TimeSeries)
- Node status and roles

To use these dashboards:
1. Ensure the Infinity plugin is installed and configured
2. Import the extended dashboard JSON files
3. Select your Infinity data source when prompted

## Troubleshooting

If panels show "No data":
1. Verify "Allowed Hosts" includes your Redis Enterprise cluster hostname
2. Check that authentication credentials are correct
3. For self-signed certificates, ensure "Skip TLS Verify" is enabled
4. If still not working, edit the panel and add an Authorization header:
   - Key: `Authorization`
   - Value: `Basic <base64-encoded-credentials>`

For more details, see the [Infinity Plugin Documentation](https://grafana.com/grafana/plugins/yesoreyeram-infinity-datasource/).
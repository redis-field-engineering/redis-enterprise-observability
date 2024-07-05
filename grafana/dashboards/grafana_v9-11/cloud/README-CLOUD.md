# Redis Enterprise Cloud Dashboards

We provide two sets of Grafana dashboards for monitoring your Redis Enterprise Cloud deployments.

The [basic dashboards](basic/) require that you have the Grafana Prometheus data source installed and configured to monitor your Redis Cloud deployment.

The optional [extended dashboards](extended/) rely on two additional data sources beyond Prometheus: the [Redis Datasource for Grafana](https://grafana.com/grafana/plugins/redis-datasource/) and the [Infinity Datasource for Grafana](https://grafana.com/grafana/plugins/yesoreyeram-infinity-datasource/). These dashboards provide additional dashboard panes, including Redis Cloud subscription configuration settings and a table of Redis slow log entries.

## Basic dashboard configuration

Once you've configured Prometheus to scrape the [Redis Cloud Prometheus endpoint](https://docs.redis.com/latest/rc/cloud-integrations/prometheus-integration/), you can import the dashboard files in to Grafana. Here are the steps:

1. Open Grafana's dashboard tab, click on the blue 'New' button on the far right and select 'Import'.

2. Click on the 'Upload JSON file' button.

3. Upload the [basic dashboard JSON files](basic/) included in this project. 

## Extended dashboard configuration

If you want to to use the [extended dashboard JSON files](extended/), you'll need to make some additional configuration changes.

For the [extended database status dashboard](extended/redis-cloud-database-extended-dashboard.json), you'll need to configure the Infinity data source plugin. This supports the extended _Modules_ and _Configuration_ panes.

After uploading the JSON, you can follow these steps:

1. Open the Database Status dashboard settings and select 'Variables' from the left-hand menu.
2. Add a variable 'subscription'.
3. Set its data source to 'Infinity'.
4. Set Type=JSON, Parser=Backend, Source=URL, Method=GET, Format=Table, URL=https://api.redislabs.com/v1/subscriptions
5. Click on 'Headers, Request parameters' and add/set the following headers;
   - accept = application/json
   - x-secret-key = <REDIS-CLOUD-API-ACCOUNT-KEY>
   - x-api-secret-key = <REDIS-CLOUD-API-SECRET-KEY>
   
   Add the following request parameters:
   - offset = 0
   - limit = 100
   
6. Open 'Parsing options and Result fields' and set the Rows/Root = subscriptions
   - Then set the column selector to `id`, as subscriptionId, and format as Number.
   
7. Click _Run query_ at the very bottom and your subscription id should be returned.

For the extended dashboard, you'll need to configure both the Redis Datasource plugin and the Infinity data source plugin. After uploading the JSON, you can follow these steps:

The [extended subscription status dashboard](extended/redis-cloud-subscription-dashboard.json) has two panels that need to be configured: Modules and Configuration. They should use the Infinity datasource with the same settings as above, but with the following exceptions:

1. For Modules & Configuration: URL = https://api.redislabs.com/v1/subscriptions/$subscription/databases/$bdb
2. For Modules, Open 'Parsing options and Result fields' and set the Rows/Root=modules.
3. Also for Modules, 'Parsing options and Result fields' need the following fields
   - name, as Name, format as String
   - version, as Version, format as String
3. For Configuration, 'Parsing options and Result fields' need the following fields
   - replication, as 1. Replication, format as String
   - dataPersistence, as 2. Persistence, format as String
   - backup.enableRemoteBackup, as 3. Backup, format as String
   - dataEvictionPolicy, as 4. Eviction, format as String
   - protocol, as 5. Protocol, format as String

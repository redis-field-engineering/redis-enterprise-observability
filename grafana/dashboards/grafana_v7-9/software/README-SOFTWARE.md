# Redis Enterprise Software Dashboards

We provide two sets of Grafana dashboards for monitoring your Redis Enterprise Software deployments.

The [basic dashboards](basic/) require that you have the Grafana Prometheus data source installed and configured to monitor your Redis Cloud deployment.

The optional [extended dashboards](extended/) rely on two additional data sources beyond Prometheus: the [Redis Datasource for Grafana](https://grafana.com/grafana/plugins/redis-datasource/) and the [Infinity Datasource for Grafana](https://grafana.com/grafana/plugins/yesoreyeram-infinity-datasource/). These dashboards provide additional dashboard panes, including Redis Cloud subscription configuration settings and a table of Redis slow log entries.

## Basic dashboard configuration

Once you've configured Prometheus to scrape the [Redis Software Prometheus endpoint](https://docs.redis.com/latest/rs/clusters/monitoring/prometheus-integration/), you can import the dashboard files in to Grafana. Here are the steps:

1. Open Grafana's dashboard tab, click on the blue 'New' button on the far right and select 'Import'.

2. Click on the 'Upload JSON file' button.

3. Upload the [basic dashboard JSON files](basic/) included in this project. 

## Extended dashboard configuration

If you want to to use the [extended dashboard JSON files](extended/), you'll need to make some additional configuration changes.

For the [extended database status dashboard](extended/redis-cloud-database-dashboard.json), you'll need to configure both the Redis Datasource plugin and the Infinity data source plugin, which supports the _Modules_ and _Configuration_ panes.

The Reds Datasource requires only that you configure an account for accessing the Redis cluster. When you install the datasource plugin you will need to enter the redis cluster address, eg. redis://REDIS_SOFTWARE_HOSTNAME:<REDIS_SOFTWARE_PORT>, then enable the ACL switch and enter a username and password. We recommend creating a user with the 'Cluster View' role that is used only for this purpose.

The Database Status Dashboard has two panels that need to be configured; Modules, and Configuration. They should use the Infinity datasource with the following settings:

```
Type=JSON, Parser=Backend, Source=URL, Format=Table, Method=GET, URL=https://<REDIS_SOFTWARE_HOSTNAME>:9443/v1/bdbs
```
To configure the _Modules_ pane:

1. Open 'Parsing options and Result fields' and set the Rows/Root=module_list.

2. The 'Parsing options and Result fields' need the following fields
   - module_name, as Name, format as String
   - semantic_version, as Version, format as String

To configure the _Configuration_ pane:

1. Set the 'Parsing options and Result fields' fields as follows:
   - replication, as 1. Replication, format as String
   - data_persistence, as 2. Persistence, format as String
   - backup, as 3. Backup, format as String
   - eviction_policy, as 4. Eviction, format as String
   - rack_aware, as 5. Multi AZ, format as String

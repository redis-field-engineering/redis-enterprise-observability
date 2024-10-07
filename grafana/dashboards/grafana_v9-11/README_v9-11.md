
For Redis Enterprise, we provide the following dashboards:
* [Cluster status](software/basic/redis-software-cluster-dashboard_v9-11.json)
* [Database status](software/basic/redis-software-database-dashboard_v9-11.json)
* [Node metrics](software/basic/redis-software-node-dashboard_v9-11.json)
* [Shard metrics](software/basic/redis-software-shard-dashboard_v9-11.json)

For Redis Cloud, which is fully managed, we provide two dashboards:
* [Subscription status](cloud/basic/redis-cloud-subscription-dashboard_v9-11.json)
* [Database status](cloud/basic/redis-cloud-database-dashboard_v9-11.json)

Lastly, we also provide a set of dashboards designed to be used in a drill-down fashion, 
referred to as [workflow](workflow/README-WORKFLOW.md) dashboards.

### Alerts
This repository also contains [alert configuration files](../../../prometheus/rules/alerts.yml) for Prometheus that can 
generate notifications when any of a number of key metrics fall outside their expected ranges.

Finally, we include a set of [metrics descriptions](../../metrics) for your reference.

## Table of Contents

* [Background](#background)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
   - [Redis Software dashboards](#redis-software-dashboards)
   - [Redis Cloud dashboards](#redis-cloud-dashboards)
   - [Redis Workflow dashboards](#redis-workflow-dashboards)
* [Extended dashboards](#extended-dashboards)
* [Alerts](#alerts)
* [Support](#support)
* [License](#license)

## Background

Redis Enterprise is available in two deployment options:
* A self-managed product, called Redis Enterprise Software, for deployment on-premises and in private clouds, etc.
* The fully-managed Redis Enterprise Cloud, which is available on AWS, Azure, and GCP.

When you run Redis in production, it's important that you have visibility into its behavior.
For this reason, both of these Redis Enterprise products export metrics through a Prometheus endpoint.
You can collect these metrics using Prometheus and visualize them using Grafana.

Because it can take a lot of time to design a dashboard with the appropriate metrics, we provide
this collection of pre-built dashboards to help get you started quickly.

## Prerequisites

These dashboards are built for Grafana and rely on a Prometheus data source. Therefore, you will need:

* A Prometheus deployment capable of scraping the metrics endpoints provided by your Redis Enterprise deployment
* A Grafana deployment that can issue PromQL queries against your Prometheus instance

For information on the Redis Enterprise Prometheus endpoints, see the official docs:
* [Redis Enterprise Prometheus documentation](https://docs.redis.com/latest/rs/clusters/monitoring/prometheus-integration/)
* [Redis Cloud Prometheus documentation](https://docs.redis.com/latest/rc/cloud-integrations/prometheus-integration/)

## Installation

To use these dashboards, you first need to run and configure Prometheus and Grafana.
You can then upload the dashboard JSON files through the Grafana UI. The JSON files
you choose will depend on when you're deploying Redis Software or Redis Cloud.
See the sections below for details.

### Prometheus and Grafana

1. Configure your [Prometheus deployment's scraping config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) 
so that it reads from your Redis Enterprise Prometheus endpoint.

2. [Create a Prometheus data source](https://grafana.com/docs/grafana/v8.5/datasources/add-a-data-source/) in the 
Grafana administration console.

See the official Redis Enterprise docs for a complete example of configuring both Prometheus and Grafana:

* [Prometheus and Grafana with Redis Enterprise](https://docs.redis.com/latest/rs/clusters/monitoring/prometheus-integration/)

### Redis Software dashboards

For Redis Enterprise, we provide the following dashboards:
* [Cluster status](software/basic/redis-software-cluster-dashboard_v9-11.json)
* [Database status](software/basic/redis-software-database-dashboard_v9-11.json)
* [Node metrics](software/basic/redis-software-node-dashboard_v9-11.json)
* [Shard metrics](software/basic/redis-software-shard-dashboard_v9-11.json)

You can upload these dashboards directly though the Grafana UI. For additional installation instructions, see the [Redis Enterprise dashboards 
README](software/README-SOFTWARE.md).

### Redis Cloud dashboards

For Redis Cloud, which is fully managed, we provide two dashboards:
* [Subscription status](cloud/basic/redis-cloud-subscription-dashboard_v9-11.json)
* [Database status](cloud/basic/redis-cloud-database-dashboard_v9-11.json)

### Redis Workflow Dashboards

Redis Workflow dashboards offer a different approach to monitoring system performance by using links to effect drill-down 
operations, making it simpler to reach specific statistics for any category of metrics.

The workflow dashboards now have their own readme file, found here: [Workflow Dashboards](workflow/README-WORKFLOW.md).

You can upload these dashboards directly though the Grafana UI. For additional installation instructions, see the [Redis Cloud dashboards 
README](cloud/README-CLOUD.md#basic-dashboard-configuration).

## Extended dashboards

We also provided a set of extended dashboards for both Redis Enterprise and Redis Cloud that provide additional metrics, including more information 
about you cluster's configuration and the Redis slow log.

These optional dashboards rely on one additional data source beyond Prometheus: the [Infinity Datasource for 
Grafana](https://grafana.com/grafana/plugins/yesoreyeram-infinity-datasource/).

## Alerts

### Running the alerting tests

To run the alerting tests, you will need to copy the [prometheus/rules/](../../../prometheus/rules) and 
[prometheus/tests/](../../../prometheus/tests) folders to your Prometheus installation. Once they have been 
copied,
you can execute the tests as follows:

```
promtool test rules tests/*
```

### Modifying the alerts

You can customize the included alerts to the need of your Redis deployment environment and configuration. You can also create additional alerts 
following Prometheus' alerting guidelines. We strongly recommend that you create unit tests for each of your alerts to ensure that they perform as 
expected.

To learn more about testing alerts, see the [Prometheus documentation for unit testing 
rules](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/).

## Support

The Redis Enterprise Grafana dashboards are supported by Redis, Inc. on a good faith effort basis. To report bugs, request features, or receive 
assistance, please file an [issue](https://github.com/redis-field-engineering/redis-enterprise-grafana-issues).

## License

These dashboards and configurations are licensed under the MIT License. Copyright (C) 2023-4 Redis, Inc.

import argparse
import logging
import re
import sys
import time

from exporter.database_metrics import (DatabaseMetrics,
                                       DatabaseMetricsTransformer)
from exporter.fetcher import MetricsFetcher
from exporter.helpers import get_cluster_fqdn
from exporter.metrics_exporter import MetricsExporter
from prometheus_client import start_http_server

logging.basicConfig(stream=sys.stdout, level=logging.INFO)

PORT = 8000
DEFAULT_FETCH_INTERVAL = 300

def get_fetch_interval(interval):
    if interval is None or interval < 300:
        logging.warn(f"Fetch interval is too low ({interval}). Setting interval to {DEFAULT_FETCH_INTERVAL}")
        return DEFAULT_FETCH_INTERVAL
    else:
        return interval

def monitor_redis_cloud_api_based_metrics(args):
    cluster_fqdn = get_cluster_fqdn(args.database_endpoint)
    fetcher = MetricsFetcher(cluster_fqdn, args.api_account_key, args.api_user_secret_key)
    transformer = DatabaseMetricsTransformer()
    exporter = MetricsExporter(cluster_fqdn)
    fetch_interval_seconds = get_fetch_interval(args.api_fetch_interval)
    logging.info(f"Starting Prometheus server on port {PORT}...")
    start_http_server(PORT)
    while(True):
        logging.info("Fetching database stats...")
        stats = fetcher.fetch_database_metrics()
        logging.info(f"Found stats for {len(stats)} databases.")
        for stat in stats:
            metrics = transformer.get_database_metrics(stat)
            exporter.update(metrics)
        logging.info(f"Sleeping for {fetch_interval_seconds} seconds until next API fetch...")
        time.sleep(fetch_interval_seconds)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
                    prog = 'Redis Cloud API Prometheus Exporter',
                    description = 'Expose Redis Cloud API stats through Prometheus')
    parser.add_argument('-a', '--api-account-key', required=False)
    parser.add_argument('-u', '--api-user-secret-key', required=False)
    parser.add_argument('-i', '--api-fetch-interval', default=1200, type=int, required=False)
    parser.add_argument('-e', '--database-endpoint', required=False)

    args = parser.parse_args()

    if args.api_account_key == None or args.api_user_secret_key == None:
        logging.warning("No cloud API keys provided. Will not report estimated max throughput.")
        start_http_server(PORT)
        while(True):
            time.sleep(1)
    else:
        monitor_redis_cloud_api_based_metrics(args)
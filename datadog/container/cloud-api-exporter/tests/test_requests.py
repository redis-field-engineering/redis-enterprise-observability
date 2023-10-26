from unittest.mock import MagicMock

import context
import urllib3
from context import (sample_database_stats, sample_subscriptions,
                     samples_databases_from_subscription)
from exporter.fetcher import MetricsFetcher

urllib3.disable_warnings()

def test_basic_request():
  endpoint = "redis-cloud-test.gcp.cloud.rlrcp.com" 
  key = "account-key"
  secret = "secret"
  fetcher = MetricsFetcher(endpoint, key, secret)
  fetcher._get_subscriptions = MagicMock(return_value=sample_subscriptions())
  fetcher._get_databases = MagicMock(return_value=samples_databases_from_subscription())
  fetcher._get_database_stats = MagicMock(return_value=sample_database_stats())
  metrics = fetcher.fetch_database_metrics()
  assert len(fetcher.databases) == 2
  assert metrics["databaseId"] == 11481281
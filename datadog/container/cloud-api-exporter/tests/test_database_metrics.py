import context
import pytest
from context import (DatabaseMetrics, DatabaseMetricsTransformer,
                     sample_database_stats,
                     sample_database_stats_with_shard_throughput)


def test_database_metrics():
    stats = sample_database_stats()
    metrics = DatabaseMetrics(
        database_id = stats["databaseId"],
        database_name = stats["name"],
        estimated_ops_per_second=stats["throughputMeasurement"]["value"]
    )

    assert metrics.database_id == stats["databaseId"]
    assert metrics.database_name == stats["name"]
    assert metrics.estimated_ops_per_second == stats["throughputMeasurement"]["value"]

def test_transformed_metrics():
    stats = sample_database_stats()
    transformer = DatabaseMetricsTransformer()
    metrics = transformer.get_database_metrics(stats)
    assert metrics.database_id == 11481281
    assert metrics.database_name == "cache"
    assert metrics.estimated_ops_per_second == 10000

def test_transformed_metrics_with_shard_throughput():
    stats = sample_database_stats_with_shard_throughput()
    transformer = DatabaseMetricsTransformer()
    metrics = transformer.get_database_metrics(stats)
    assert metrics.database_id == 11481281
    assert metrics.database_name == "cache"
    assert metrics.estimated_ops_per_second == None

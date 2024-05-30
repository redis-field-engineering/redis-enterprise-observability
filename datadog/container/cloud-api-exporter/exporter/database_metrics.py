import logging
from typing import Optional

from pydantic import BaseModel

class DatabaseMetrics(BaseModel):
    """ Simple model for the fields to report as metrics """
    database_id: int
    database_name: str
    data_persistence: Optional[str]
    estimated_ops_per_second: Optional[int]

class DatabaseMetricsTransformer():
    """ Class to transform API responses to DatabaseMetrics models """
    def __init__(self):
        self.running = True

    def get_database_metrics(self, stats):
        metrics = DatabaseMetrics(
            database_id = stats["databaseId"],
            database_name = stats["name"]
        )
        if "throughputMeasurement" in stats:
            throughput = stats["throughputMeasurement"]
            if throughput["by"] == "operations-per-second":
                metrics.estimated_ops_per_second = throughput["value"]
        
        if "dataPersistence" in stats:
            metrics.data_persistence = stats["dataPersistence"]

        logging.info(f"Updated published Prometheus metrics for database {metrics}")

        return metrics

import prometheus_client
from prometheus_client import Gauge, Info

# Disable collection of Python platform metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

class MetricsExporter:
    def __init__(self, cluster_fqdn):
        self.cluster_fqdn=cluster_fqdn
        self.throughput_gauge = Gauge("bdb_estimated_max_throughput", "Estimated max throughput", ["bdb", "bdb_name", "cluster"])
        self.persistence_info = Info("bdb_data_persistence", "Indicate the type of data persistence enabled", ["bdb", "bdb_name", "cluster"])

    def update(self, metrics):
        if metrics.estimated_ops_per_second != None:
            self.throughput_gauge.labels(bdb=metrics.database_id,   
                                         bdb_name=metrics.database_name,
                                         cluster=self.cluster_fqdn).set(metrics.estimated_ops_per_second)

        if metrics.data_persistence != None:
            self.persistence_info.labels(bdb=metrics.database_id,
                                         bdb_name=metrics.database_name,
                                         cluster=self.cluster_fqdn).info({"persistence": metrics.data_persistence})
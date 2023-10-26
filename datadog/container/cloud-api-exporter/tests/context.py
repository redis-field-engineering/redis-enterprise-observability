# -*- coding: utf-8 -*-

import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from exporter import database_metrics, fetcher
from exporter.database_metrics import (DatabaseMetrics,
                                       DatabaseMetricsTransformer)


def sample_subscriptions():
    return {'accountId': 761976, 'subscriptions': [{'id': 1967772, 'name': 'Banker-Test-Active-Active', 'status': 'active', 'deploymentType': 'active-active', 'paymentMethodId': 9605, 'memoryStorage': 'ram', 'storageEncryption': True, 'numberOfDatabases': 1, 'paymentMethodType': 'credit-card', 'cloudDetails': [{'provider': 'GCP', 'cloudAccountId': 1, 'totalSizeInGb': 0.0586, 'links': []}], 'links': []}, {'id': 1965204, 'name': 'ray-demo', 'status': 'active', 'deploymentType': 'single-region', 'paymentMethodId': 9605, 'memoryStorage': 'ram', 'numberOfDatabases': 1, 'paymentMethodType': 'credit-card', 'storageEncryption': True, 'subscriptionPricing': [{'type': 'Shards', 'typeDetails': 'high-throughput', 'quantity': 2, 'quantityMeasurement': 'shards', 'pricePerUnit': 0.125, 'priceCurrency': 'USD', 'pricePeriod': 'hour'}, {'type': 'EBS Volume', 'quantity': 71, 'quantityMeasurement': 'GB'}, {'type': 'c5.xlarge', 'quantity': 2, 'quantityMeasurement': 'instances'}, {'type': 'm5.large', 'quantity': 1, 'quantityMeasurement': 'instances'}], 'cloudDetails': [{'provider': 'AWS', 'cloudAccountId': 6415, 'totalSizeInGb': 0.0602, 'regions': [{'region': 'us-east-1', 'networking': [{'deploymentCIDR': '10.0.0.0/26', 'subnetId': 'subnet-0f83e56d55130f7c1'}, {'deploymentCIDR': '10.0.0.64/26', 'subnetId': 'subnet-0188c390cf01f9b3f'}, {'deploymentCIDR': '10.0.0.128/26', 'subnetId': 'subnet-0cb597962ac0b938f'}], 'preferredAvailabilityZones': ['us-east-1a', 'us-east-1b', 'us-east-1c'], 'multipleAvailabilityZones': True}], 'links': []}], 'links': []}, {'id': 1966180, 'name': 'banker-observability-test-gcp', 'status': 'active', 'deploymentType': 'single-region', 'paymentMethodId': 9605, 'memoryStorage': 'ram', 'numberOfDatabases': 3, 'paymentMethodType': 'credit-card', 'storageEncryption': False, 'subscriptionPricing': [{'type': 'MinimumPrice', 'quantity': 1, 'quantityMeasurement': 'subscription', 'pricePerUnit': 0.907, 'priceCurrency': 'USD', 'pricePeriod': 'hour'}, {'type': 'Shards', 'typeDetails': 'high-throughput', 'quantity': 4, 'quantityMeasurement': 'shards', 'pricePerUnit': 0.204, 'priceCurrency': 'USD', 'pricePeriod': 'hour'}, {'type': 'Disk', 'quantity': 121, 'quantityMeasurement': 'GB', 'pricePerUnit': 0.028, 'priceCurrency': 'USD', 'pricePeriod': 'hour'}], 'cloudDetails': [{'provider': 'GCP', 'cloudAccountId': 1, 'totalSizeInGb': 0.0138, 'regions': [{'region': 'us-central1', 'networking': [{'deploymentCIDR': '10.10.0.0/24', 'vpcId': 'c23492-us-central1-1-rlrcp'}], 'preferredAvailabilityZones': ['us-central1-a'], 'multipleAvailabilityZones': False}], 'links': []}], 'links': []}], 'links': [{'rel': 'self', 'href': 'https://api.redislabs.com/v1/subscriptions', 'type': 'GET'}]}

def samples_databases_from_subscription():
    return {'accountId': 761976, 'subscription': [{'subscriptionId': 1967772, 'databases': [{'databaseId': 294, 'name': 'distributed-cache', 'protocol': 'redis', 'status': 'active', 'memoryStorage': 'ram', 'activeActiveRedis': True, 'activatedOn': '2023-02-10T18:15:01Z', 'lastModified': '2023-02-10T18:26:35Z', 'supportOSSClusterApi': False, 'useExternalEndpointForOSSClusterApi': False, 'replication': True, 'dataEvictionPolicy': 'noeviction', 'crdbDatabases': [{'provider': 'GCP', 'region': 'europe-west1', 'redisVersionCompliance': '6.2.6', 'publicEndpoint': 'public-redis.gcp.cloud.rlrcp.com:19229', 'privateEndpoint': 'redis-cloud-test.gcp.cloud.rlrcp.com:19229', 'memoryLimitInGb': 1.0, 'memoryUsedInMb': 29.9064, 'readOperationsPerSecond': 1000, 'writeOperationsPerSecond': 1000, 'dataPersistence': 'aof-every-1-second', 'alerts': [], 'security': {'enableDefaultUser': True, 'sslClientAuthentication': False, 'enableTls': False, 'sourceIps': ['0.0.0.0/0']}, 'backup': {'enableRemoteBackup': False, 'interval': '', 'timeUTC': ''}, 'links': []}, {'provider': 'GCP', 'region': 'us-central1', 'redisVersionCompliance': '6.2.6', 'publicEndpoint': 'public-redis.gcp.cloud.rlrcp.com:19229', 'privateEndpoint': 'redis-cloud-test.gcp.cloud.rlrcp.com:19229', 'memoryLimitInGb': 1.0, 'memoryUsedInMb': 30.1044, 'readOperationsPerSecond': 1000, 'writeOperationsPerSecond': 1000, 'dataPersistence': 'aof-every-1-second', 'alerts': [], 'security': {'enableDefaultUser': True, 'sslClientAuthentication': False, 'enableTls': False, 'sourceIps': ['0.0.0.0/0']}, 'backup': {'enableRemoteBackup': False, 'interval': '', 'timeUTC': ''}, 'links': []}], 'links': []}], 'links': []}], 'links': [{'rel': 'self', 'href': 'https://api.redislabs.com/v1/subscriptions/1967772/databases', 'type': 'GET'}]}

def sample_active_active_database():
    return {'databaseId': 294, 'name': 'distributed-cache', 'protocol': 'redis', 'status': 'active', 'memoryStorage': 'ram', 'activeActiveRedis': True, 'activatedOn': '2023-02-10T18:15:01Z', 'lastModified': '2023-02-10T18:26:35Z', 'supportOSSClusterApi': False, 'useExternalEndpointForOSSClusterApi': False, 'replication': True, 'dataEvictionPolicy': 'noeviction', 'crdbDatabases': [{'provider': 'GCP', 'region': 'europe-west1', 'redisVersionCompliance': '6.2.6', 'publicEndpoint': 'public-redis.gcp.cloud.rlrcp.com:19229', 'privateEndpoint': 'redis-cloud-test.gcp.cloud.rlrcp.com:19229', 'memoryLimitInGb': 1.0, 'memoryUsedInMb': 30.0882, 'readOperationsPerSecond': 1000, 'writeOperationsPerSecond': 1000, 'dataPersistence': 'aof-every-1-second', 'alerts': [], 'security': {'enableDefaultUser': True, 'sslClientAuthentication': False, 'enableTls': False, 'sourceIps': ['0.0.0.0/0']}, 'backup': {'enableRemoteBackup': False, 'interval': '', 'timeUTC': ''}, 'links': []}, {'provider': 'GCP', 'region': 'us-central1', 'redisVersionCompliance': '6.2.6', 'publicEndpoint': 'public-redis.us-central1-mz.gcp.cloud.rlrcp.com:19229', 'privateEndpoint': 'redis-cloud-test.gcp.cloud.rlrcp.com:19229', 'memoryLimitInGb': 1.0, 'memoryUsedInMb': 30.1084, 'readOperationsPerSecond': 1000, 'writeOperationsPerSecond': 1000, 'dataPersistence': 'aof-every-1-second', 'alerts': [], 'security': {'enableDefaultUser': True, 'sslClientAuthentication': False, 'enableTls': False, 'sourceIps': ['0.0.0.0/0']}, 'backup': {'enableRemoteBackup': False, 'interval': '', 'timeUTC': ''}, 'links': []}], 'links': []}

def sample_database_stats_with_shard_throughput():
    stats = sample_database_stats()
    stats["throughputMeasurement"] = {
        "by": "number-of-shards",
        "value": 1
    }
    return stats

def sample_database_stats():
    return {
    "databaseId": 11481281,
    "name": "cache",
    "protocol": "redis",
    "provider": "GCP",
    "region": "us-central1",
    "redisVersionCompliance": "6.2.6",
    "status": "active",
    "memoryLimitInGb": 0.5,
    "memoryUsedInMb": 11,
    "memoryStorage": "ram",
    "supportOSSClusterApi": False,
    "useExternalEndpointForOSSClusterApi": False,
    "dataPersistence": "aof-every-1-second",
    "replication": True,
    "dataEvictionPolicy": "volatile-lru",
    "throughputMeasurement": {
        "by": "operations-per-second",
        "value": 10000
    },
    "activatedOn": "2023-02-09T04:36:41Z",
    "lastModified": "2023-02-09T04:36:41Z",
    "publicEndpoint": "public-redis.gcp.cloud.rlrcp.com:19694",
    "privateEndpoint": "redis-cloud-test.gcp.cloud.rlrcp.com:19694",
    "replicaOf": None,
    "clustering": {
        "numberOfShards": 1,
        "regexRules": [],
        "hashingPolicy": "standard"
    },
    "modules": [],
    "alerts": [],
    "backup": {
        "enableRemoteBackup": False,
        "interval": "",
        "timeUTC": "",
        "destination": ""
    },
    "links": [
        {
        "rel": "self",
        "href": "https://api.redislabs.com/v1/subscriptions/1966180/databases/11481281",
        "type": "GET"
        }
    ]
    }
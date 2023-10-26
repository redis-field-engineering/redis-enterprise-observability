import re

def get_cluster_fqdn(databse_endpoint):
    # Remove the port section if present
    str = re.sub(":\d+", "", databse_endpoint)
    # Remove the "redis-12345" section if present
    str = re.sub("redis-\d+\.", "", str)
    # Remove the "internal." section if present
    str = re.sub("internal\.", "", str)
    return str
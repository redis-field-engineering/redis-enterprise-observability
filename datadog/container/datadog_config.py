import os
import re
import argparse
from jinja2 import Template
from jinja2 import Environment

parser = argparse.ArgumentParser('datadog configuration')
parser.add_argument('-o', '--overrides', type=str, default='./type_overrides.conf',
                    help='the file from which to load types')
parser.add_argument('-c', '--config', type=str, default='/etc/datadog-agent/conf.d/prometheus.d/conf.yaml',
                    help='the location to which we write the config file')


def get_cloud_cluster_fqdn(database_endpoint):
    # Remove the port section if present
    str = re.sub(":\d+", "", database_endpoint)
    # Remove the "redis-12345" section if present
    str = re.sub("redis-\d+\.", "", str)
    return str

if __name__ == "__main__":

  args = parser.parse_args()

  private_endpoint = os.getenv("REDIS_CLOUD_PRIVATE_ENDPOINT")
  if private_endpoint != None:
     cluster_fqdn = get_cloud_cluster_fqdn(private_endpoint)
  else:
     cluster_fqdn = os.getenv("REDIS_SOFTWARE_FQDN")

  redis_ca_cert = os.getenv("REDIS_CLOUD_CA_CERT")
  ca_cert_present = redis_ca_cert != None
  if ca_cert_present:
    f = open("/etc/datadog-agent/conf.d/prometheus.d/ca.pem", "w")
    f.write(redis_ca_cert)
    f.close()

  template = """init_config:
instances:
{% if redis_cloud_mode %}
  - prometheus_url: http://localhost:8000/
    ssl_ca_cert: false
    namespace: redise
    max_returned_metrics: 2000
    metrics:
      - bdb_estimated_max_throughput
      - bdb_data_persistence
{% endif %}
      
  - prometheus_url: https://{{ cluster_fqdn }}:8070/
{% if ca_cert_present %}
    ssl_ca_cert: /etc/datadog-agent/conf.d/prometheus.d/ca.pem
{% else %}
    ssl_ca_cert: false
{% endif %}
    namespace: redise
    max_returned_metrics: 2000
    metrics:
      - "*"
  """

  data = {
      "cluster_fqdn": cluster_fqdn,
      "ca_cert_present": ca_cert_present
  }

  if private_endpoint != None:
     data["redis_cloud_mode"] = True

  env = Environment(trim_blocks=True, lstrip_blocks=True)

  template = env.from_string(template)

  # now read the type overrides and append them to the end of the config - type_overrides.conf
  lines = []
  if os.path.isfile(args.overrides):
      lines.append('  type_overrides:\n')  # indent two spaces and add a newline
      with open(args.overrides, 'r') as overrides:
        for override in overrides.readlines():
          lines.append(f'      {override}')  # alignment requires four spaces
  else:
      print(f'override file not found: {args.overrides}')
      exit(1)

  overrides = ''.join(lines)
  with open(args.config, "w") as output:
    output.write(template.render(data))
    output.write(overrides)

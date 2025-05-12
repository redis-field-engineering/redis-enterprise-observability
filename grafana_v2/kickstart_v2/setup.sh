#!/bin/bash


PROJECT="demo"

# this script needs one thing, the endpoint it should scrape
# v1 = /metrics & v2 = /v2
# this means it has to sed prometheus.yml before it creates it

# sed 's/metrics_path: \/metrics/metrics_path: \/v2/' >> prometheus.yml
# get the cli variable and use it as the network endpoint for prometheus
# sed 's/- targets: \[\"172.27.1.4\:8070\"\]/- targets: \[\"$1\:8070\"\]/' >> prometheus.yml

sed "s/- targets: \[\"172.27.1.4:8070\"\]/- targets: \[\"$1:8070\"\]/" prometheus.yml > prometheus.yml.tmp
mv prometheus.yml.tmp prometheus.yml

docker compose -p ${PROJECT} up -d

until curl --output /dev/null --silent --head --fail curl http://localhost:3000; do
    printf '.'
    sleep 1
done

# create prometheus datasource
echo ""
echo "create grafana datasource"
curl -s 'http://admin:admin@localhost:3000/api/datasources' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data '{   "name": "prometheus-demo",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "title": "Demonstration",
    "access": "proxy",
    "basicAuth": false}'

echo "perform datasource health check"
data=`curl -s 'http://admin:admin@localhost:3000/api/datasources/name/prometheus-demo'`

str=${data#*\"uid\"\:\"*}
uid=${str%%\"*}

# use the datasource's uid to check its health
data=`curl -s 'http://admin:admin@localhost:3000/api/datasources/uid/'$uid'/health'`

str=${data#*\"status\"\:\"*}
status=${str%%\"*}

echo ""
if [[ "$status" == "OK" ]]; then
  echo "> grafana connected to prometheus-demo"
else
  echo "! grafana failed to connect to prometheus-demo"
fi

echo ""
echo "create grafana dashboards"
# loop over files in folder
for file in ../dashboards/kickstart/*; do
    if [ -f "$file" ]; then
        echo "$file"
        curl -s 'http://admin:admin@localhost:3000/api/dashboards/db' \
           --header 'Accept: application/json' \
           --header 'Content-Type: application/json' \
           --data-binary @$file
    fi
done

echo ""
echo "You can open a browser and access Grafana, and Prometheus at:"
echo "  Grafana: http://localhost:${DEMO_NUM}3000 (username=admin and password=admin)"
echo "  Prometheus: http://localhost:${DEMO_NUM}9090"
echo ""
echo ""
echo "DISCLAIMER: This is best for local development or functional testing. Please see, https://docs.redis.com/latest/rs/installing-upgrading/quickstarts/docker-quickstart/"


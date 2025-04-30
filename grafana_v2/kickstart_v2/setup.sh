#!/bin/bash


PROJECT="demo"

# this script needs one thing, the endpoint it should scrape
# this means it has to sed prometheus.yml before it creates the container

# sed 's/- targets: \[\"localhost\:\"\]/- targets: \[\"$1\:\"\]/' >> prometheus.yml

# this script can take a second argument; the folder from which it should load dashboards
# by default it will use ../dashboards/grafana_v9-11/software/basic

if [ $# -eq 0 ]; then
  echo "using default endpoint and folder"
  folder="../dashboards/grafana_v9-11/software/basic/*"
fi

if [ $# -eq 1 ]; then
  echo "using endpoint $1 and default folder"
  folder="../dashboards/grafana_v9-11/software/basic/*"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
      sed -i "s/host.docker.internal/$1/g" prometheus.yml
    elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
      sed -i '' "s/host.docker.internal/$1/g" prometheus.yml
    fi
fi

if [ $# -eq 2 ]; then
  if [ -d "$2" ]; then
    echo "using endpoint $1 and folder $2"
    folder="$2/*"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
      sed -i "s/host.docker.internal/$1/g" prometheus.yml
    elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
      sed -i '' "s/host.docker.internal/$1/g" prometheus.yml
    fi
  else
    echo "second argument must be a directory!"
    exit 1
  fi
fi

docker compose -p dashboard up -d

container_name="dashboard-redis-1"

# wait until grafana is up before trying to create a datasource
until curl --output /dev/null --silent --head --fail curl "localhost:3000"; do
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
    "url": "http://host.docker.internal:9090",
    "title": "Demonstration",
    "access": "proxy",
    "basicAuth": false}'

# get the datasource by name to find its uid
echo ""
echo ""
echo "perform datasource health check"
data=`curl -s 'http://admin:admin@localhost:3000/api/datasources/name/prometheus-demo'`

str=${data#*\"uid\"\:\"*}
uid=${str%%\"*}

# use the datasource's uid to check its health
data=`curl -s 'http://admin:admin@localhost:3000/api/datasources/uid/'$uid'/health'`

str=${data#*\"status\"\:\"*}
status=${str%%\"*}

if [[ "$status" == "OK" ]]; then
  echo "> grafana connected to prometheus-demo"
else
  echo "! grafana failed to connect to prometheus-demo"
fi

echo ""
echo "create grafana dashboards"
echo "folder: $folder"

# loop over files in folder
for file in $folder; do
    if [ -f "$file" ]; then
        echo "$file"
        d=`cat "$file"`
        echo "{  \"dashboard\": $d,\"folderId\": 0,  \"message\": \"Created by Redis demo setup script\",  \"overwrite\": false}" \
        | sed s/\"uid\"\:\ \"\$\{DS_PROMETHEUS\}\"/\"name\"\:\ \"prometheus-demo\"/g | curl -s 'http://admin:admin@localhost:3000/api/dashboards/db' \
               --header 'Accept: application/json' \
               --header 'Content-Type: application/json' \
               --data-binary @-
    fi
done

echo ""
echo "You can open a browser and access Grafana, and Prometheus at:"
echo "  Grafana: http://localhost:3000 (username=admin and password=admin)"
echo "  Prometheus: http://localhost:9090"
echo ""
echo ""
echo "DISCLAIMER: This is best for local development or functional testing. Please see, https://docs.redis.com/latest/rs/installing-upgrading/quickstarts/docker-quickstart/"


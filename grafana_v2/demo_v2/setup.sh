#!/bin/bash

if ! command -v jq 2>*1 >/dev/null
then
  echo "install jq first. ex:"
  echo "brew install jq"
  exit 1
fi

function re_api () {
    ACTION=$1
    PATHNAME=$2
    DATA=$3
    RETRIES=12
    if [ -n "$DATA" ]
    then
      EXTRA_ARGS="-HContent-Type:application/json -d '$DATA'"
    else
      EXTRA_ARGS=""
    fi
    if [[ $ACTION != "create cluster" ]]
    then
      EXTRA_ARGS="-u demo@redis.com:redislabs $EXTRA_ARGS"
    fi

    N=0
    echo $ACTION ...
    echo > ./lastapioutput
    echo > ./lastcode
    while [[ $N -lt $RETRIES && "$(eval curl -o ./lastapioutput -w '%{http_code}' $EXTRA_ARGS -k https://localhost:9443${PATHNAME} 2>/dev/null | tee ./lastcode)" != "200" ]];
    do
       N=$((N+1))
       echo "still trying to ${ACTION} $(cat ./lastcode) $(cat ./lastapioutput)"
       sleep 5;
    done

    if [ $N -ge $RETRIES ]
    then
        echo "failed to $ACTION with max retries"
        exit 1
    fi
    echo ""
}

docker compose -p dashboard up -d

container_name="dashboard-redis-1"

echo ""
re_api "create cluster" "/v1/bootstrap/create_cluster" '{"action":"create_cluster","cluster":{"name":"dashboard.local"},"node":{"paths":{"persistent_path":"/var/opt/redislabs/persist","ephemeral_path":"/var/opt/redislabs/tmp"}},"credentials":{"username":"demo@redis.com","password":"redislabs"}}'
re_api "bootstrap cluster" /v1/bootstrap
re_api "get nodes" /v1/nodes
re_api "get modules" /v1/modules
while [[ "$(cat ./lastapioutput)" == "[]" ]]
do
  echo "modules not yet loaded, will try again soon"
  sleep 10
  re_api "get modules" /v1/modules
done

# Get the module info to be used for database creation
cp ./lastapioutput ./modules.txt
# modules endpoint returns multiple versions supported, use latest (first), filter it with jq
json_module_name=$(cat ./modules.txt | jq '[.[] | select(.module_name == "ReJSON")] | first | .module_name' -r)
json_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "ReJSON")] | first | .semantic_version' -r)
search_module_name=$(cat ./modules.txt | jq '[.[] | select(.module_name == "search")] | first | .module_name' -r)
search_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "search")] | first | .semantic_version' -r)
timeseries_module_name=$(cat ./modules.txt |jq '[.[] | select(.module_name == "timeseries")] | first | .module_name' -r)
timeseries_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "timeseries")] | first | .semantic_version' -r)

re_api "create role" "/v1/roles" '{"name": "db_member", "management": "db_member"}'
re_api "create user" /v1/users "{\"email\": \"dashboard@redis.com\",\"password\": \"dashboard\",\"name\": \"dashboard\",\"email_alerts\": false,\"role\": \"db_member\"}"

echo creating dashboard-demo database with "${search_module_name}" version "${search_semantic_version}" and "${json_module_name}" version "${json_semantic_version}"
re_api "create databases" /v1/bdbs "{\"name\": \"dashboard-demo\", \"port\": 12000, \"memory_size\": 500000000, \"type\" : \"redis\", \"replication\": false, \"default_user\": false, \"roles_permissions\": [{\"role_uid\": 2, \"redis_acl_uid\": 1}], \"module_list\": [ {\"module_args\": \"PARTITIONS AUTO\", \"module_name\": \"$search_module_name\", \"semantic_version\": \"$search_semantic_version\"}, {\"module_args\": \"\", \"module_name\": \"$json_module_name\", \"semantic_version\": \"$json_semantic_version\"} ] }"

# Enable bdb name
docker exec -it "${container_name}" bash -c "/opt/redislabs/bin/ccs-cli hset cluster_settings metrics_exporter_expose_bdb_name enabled"
docker exec -it "${container_name}" bash -c "/opt/redislabs/bin/supervisorctl restart metrics_exporter"

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

if [ $# -eq 0 ]; then
  folder="../dashboards/kickstart/*"
elif [ -d "$1" ]; then
  folder="$1/*"
else
  echo "argument must be a directory!"
  exit 1
fi

echo "folder: $folder"

# loop over files in folder
for file in $folder; do
    if [ -f "$file" ]; then
        db=`curl -s 'http://admin:admin@localhost:3000/api/dashboards/db' \
           --header 'Accept: application/json' \
           --header 'Content-Type: application/json' \
           --data-binary @$file`
        echo "result: $db"

    fi
done
echo ""
echo "------- RLADMIN status -------"
docker exec "${container_name}" bash -c "rladmin status"
echo ""
echo "You can open a browser and access Redis Enterprise Admin UI, Grafana, and Prometheus at:"
echo "  Redis URL:  redis://dashboard:dashboard@localhost:12000"
echo "  Redis Enterprise: https://127.0.0.1:8443 (username=demo@redis.com and password=redislabs)"
echo "  Grafana: http://localhost:3000 (username=admin and password=admin)"
echo "  Prometheus: http://localhost:9090"
echo ""
echo ""
echo "DISCLAIMER: This is best for local development or functional testing. Please see, https://docs.redis.com/latest/rs/installing-upgrading/quickstarts/docker-quickstart/"

# Cleanup
rm ./lastapioutput ./lastcode ./"*1" 2>/dev/null

if [[ -f "modules.txt" ]]; then
  rm "modules.txt"
fi

echo "done"

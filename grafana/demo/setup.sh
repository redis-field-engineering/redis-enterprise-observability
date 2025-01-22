#!/bin/bash

if ! command -v jq 2>*1 >/dev/null
then
  echo "install jq first. ex:"
  echo "brew install jq"
  exit 1
fi

function re_api () {
    BASE_URL="https://localhost:9443"
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

docker compose up -d

container_name="demo-redis-1"


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

echo "------- RLADMIN status -------"
docker exec "${container_name}" bash -c "rladmin status"
echo ""
echo "You can open a browser and access Redis Enterprise Admin UI at https://127.0.0.1:8443 (replace localhost with your ip/host) with username=demo@redis.com and password=redislabs."
echo "DISCLAIMER: This is best for local development or functional testing. Please see, https://docs.redis.com/latest/rs/installing-upgrading/quickstarts/docker-quickstart/"

# Cleanup
rm ./lastapioutput ./lastcode 2>/dev/null

echo "done"

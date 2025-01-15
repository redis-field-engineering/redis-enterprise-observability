#!/bin/bash

if ! command -v jq 2>*1 >/dev/null
then
  echo "install jq first. ex:"
  echo "brew install jq"
  exit 1
fi

docker compose up -d

container_name="demo-redis-1"

echo "waiting for the servers..."
sleep 60
echo "creating cluster..."

while [[ "$(curl -o /dev/null  -w ''%{http_code}'' -X POST -H 'Content-Type:application/json' -d '{"action":"create_cluster","cluster":{"name":"dashboard.local"},"node":{"paths":{"persistent_path":"/var/opt/redislabs/persist","ephemeral_path":"/var/opt/redislabs/tmp"}},"credentials":{"username":"demo@redis.com","password":"redislabs"}}' -k https://localhost:9443/v1/bootstrap/create_cluster)" != "200" ]]; do sleep 5; done

# Test the cluster. cluster info and nodes
while [[ "$(curl -o ./bootstrap -w ''%{http_code}'' -u demo@redis.com:redislabs -k https://localhost:9443/v1/bootstrap)" != "200" ]]; do sleep 5; done
while [[ "$(curl -o ./nodes -w ''%{http_code}'' -u demo@redis.com:redislabs -k https://localhost:9443/v1/nodes)" != "200" ]]; do sleep 5; done
echo ""
echo "bootstrap..." && cat ./bootstrap
echo ""
echo "nodes..." && cat ./nodes
echo ""

# Get the module info to be used for database creation
while [[ "$(curl -o ./modules.txt -w ''%{http_code}'' -u demo@redis.com:redislabs -k https://localhost:9443/v1/modules)" != "200" ]]; do sleep 5; done
echo ""
echo "modules..." && cat ./modules.txt

# modules endpoint returns multiple versions supported, use latest (first), filter it with jq
json_module_name=$(cat ./modules.txt | jq '[.[] | select(.module_name == "ReJSON")] | first | .module_name' -r)
json_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "ReJSON")] | first | .semantic_version' -r)
search_module_name=$(cat ./modules.txt | jq '[.[] | select(.module_name == "search")] | first | .module_name' -r)
search_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "search")] | first | .semantic_version' -r)
timeseries_module_name=$(cat ./modules.txt |jq '[.[] | select(.module_name == "timeseries")] | first | .module_name' -r)
timeseries_semantic_version=$(cat ./modules.txt | jq '[.[] | select(.module_name == "timeseries")] | first | .semantic_version' -r)

while [[ "$(curl -o ./dashboard -w ''%{http_code}'' -u demo@redis.com:redislabs -X POST -H "Content-Type: application/json" -d "{\"email\": \"dashboard@redis.com\",\"password\": \"dashboard\",\"name\": \"dashboard\",\"email_alerts\": false,\"role\": \"db_member\"}" -k https://localhost:9443/v1/users 2>/dev/null | tee dashboard.out)" != "200" ]]; do echo "still trying to create dashboard user $(cat dashboard.out)"; cat dashboard; sleep 5; done
echo "user dashboard..." && cat ./dashboard
echo ""

echo ""
echo "creating databases..."
echo creating dashboard-demo database with "${search_module_name}" version "${search_semantic_version}" and "${json_module_name}" version "${json_semantic_version}"

while [[ "$(curl -o ./dashboard-demo -w ''%{http_code}'' -u demo@redis.com:redislabs --location-trusted -H "Content-type:application/json" -d '{ "name": "dashboard-demo", "port": 12000, "memory_size": 500000000, "type" : "redis", "replication": false, "default_user": false, "roles_permissions": [{"role_uid": 2, "redis_acl_uid": 1}], "module_list": [ {"module_args": "PARTITIONS AUTO", "module_name": "'"$search_module_name"'", "semantic_version": "'"$search_semantic_version"'"}, {"module_args": "", "module_name": "'"$json_module_name"'", "semantic_version": "'"$json_semantic_version"'"} ] }' -k https://localhost:9443/v1/bdbs 2>/dev/null | tee database.out)" != "200" ]]; do echo "still trying to create database $(cat database.out)"; cat ./dashboard-demo ; sleep 5; done

echo ""
echo "database dashboard-demo..." && cat ./dashboard-demo
echo ""

# Enable bdb name
docker exec -it "${container_name}" bash -c "/opt/redislabs/bin/ccs-cli hset cluster_settings metrics_exporter_expose_bdb_name enabled"
docker exec -it "${container_name}" bash -c "/opt/redislabs/bin/supervisorctl restart metrics_exporter"

echo "------- RLADMIN status -------"
docker exec "${container_name}" bash -c "rladmin status"
echo ""
echo "You can open a browser and access Redis Enterprise Admin UI at https://127.0.0.1:8443 (replace localhost with your ip/host) with username=demo@redis.com and password=redislabs."
echo "DISCLAIMER: This is best for local development or functional testing. Please see, https://docs.redis.com/latest/rs/installing-upgrading/quickstarts/docker-quickstart/"

# Cleanup
rm bootstrap nodes modules.txt dashboard-demo
#rm list_modules.sh create_cluster.* module_list.txt
docker exec --user root "${container_name}" bash -c "rm /opt/list_modules.sh"
docker exec --user root "${container_name}" bash -c "rm /opt/module_list.txt"
docker exec --user root "${container_name}" bash -c "rm /opt/create_cluster.*"

echo "done"

#!/bin/bash


PROJECT="demo"

# this script needs one thing, the endpoint it should scrape
# v1 = /metrics & v2 = /v2
# this means it has to sed prometheus.yml before it creates it

# sed 's/metrics_path: \/metrics/metrics_path: \/v2/' >> prometheus.yml
# get the cli variable and use it as the network endpoint for prometheus
# sed 's/- targets: \[\"172.27.1.4\:8070\"\]/- targets: \[\"$1\:8070\"\]/' >> prometheus.yml

#    metrics_path: /v2
#    scheme: https
#    tls_config:
#      insecure_skip_verify: true
#    static_configs:
#      # the default port is 8070, the url is that of the cluster leader
#      - targets: ["172.27.1.4:8070"]

docker compose -p ${PROJECT} up -d

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
for file in dashboards/*; do
    if [ -f "$file" ]; then
        # echo "$file"
        cat <<EOF > dashboard.json
        {
              "dashboard":
EOF

         cat $file >> dashboard.json

         cat <<EOF >> dashboard.json
             ,
             "folderId": 0,
             "message": "Setup created demonstration dashboards",
             "overwrite": false
         }
EOF

        # sed replace "${DS_PROMETHEUS}" with ${prometheus-demo}
        cat dashboard.json | sed -e 's/"uid": "eeasgufdm8q2oa"/"uid": "'$uid'"/g' > dashboard2.json

         curl -s 'http://admin:admin@localhost:3000/api/dashboards/db' \
           --header 'Accept: application/json' \
           --header 'Content-Type: application/json' \
           --data-binary @./dashboard2.json
         rm dashboard.json
         rm dashboard2.json
    fi
done

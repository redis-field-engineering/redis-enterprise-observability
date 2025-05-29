#!/bin/bash

# Start remote monitoring configuration in dynatrace


PRIMARY_ENDPOINT="$1"
VERSION="$2"
API_TOKEN="$3"
TENANT="$4"
EXTENSION_NAME="custom:com.redis.enterprise.extension"
URL="https://$TENANT.live.dynatrace.com/api/v2/extensions/$EXTENSION_NAME/monitoringConfigurations"
INPUT_JSON="monitor.json"
OUTPUT_JSON="modified.json"

jq --arg primary "$PRIMARY_ENDPOINT" \
   --arg version "$VERSION" \
   '.[0].value.prometheusRemote.endpoints[0].url = $primary |
    .[0].value.version = $version' \
   "$INPUT_JSON" > "$OUTPUT_JSON"

curl -X PUT "https://$TENANT.live.dynatrace.com/api/v2/extensions/$EXTENSION_NAME/environmentConfiguration" \
-H "accept: application/json; charset=utf-8" \
-H "Authorization: Api-Token $API_TOKEN" \
-H "Content-Type: application/json; charset=utf-8" \
-d "{\"version\":\"$VERSION\"}"

response=$(curl -X POST "$URL" \
    -H "accept: application/json; charset=utf-8" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Api-Token $API_TOKEN" \
    -d @"$OUTPUT_JSON")

echo "$response" 
echo "$response" | jq -r '.[0].objectId' > dt_object_id.txt

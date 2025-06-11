#!/bin/bash

API_TOKEN="$1"
TENANT="$2"
OBJECT_ID=$(cat dt_object_id.txt)


URL="https://$TENANT.live.dynatrace.com/api/v2/extensions/custom:com.redis.enterprise.extension/monitoringConfigurations/$OBJECT_ID"

curl -X DELETE "$URL" \
    -H "accept: application/json; charset=utf-8" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Api-Token $API_TOKEN"
# Runbook: Redis Enterprise Dashboards in OpenShift Observe

This runbook deploys Redis Enterprise observability into OpenShift's native **Observe** UI for an existing Redis Enterprise active-active installation.

It assumes Redis Enterprise is already installed, healthy, and exposing operator-created Prometheus metrics services in two namespaces:

- `ns-a` with metrics service `rec-a-prom`
- `ns-b` with metrics service `rec-b-prom`

The runbook does not deploy Redis Enterprise, Grafana, or a standalone Prometheus stack.

## What This Deploys

- OpenShift user workload monitoring, if it is not already enabled
- One `ServiceMonitor` in each Redis Enterprise namespace
- One `PrometheusRule` in each Redis Enterprise namespace
- Thirteen Redis Enterprise dashboard `ConfigMap` resources in `openshift-config-managed`

The dashboards appear in the OpenShift console under **Observe -> Dashboards**.

## Prerequisites

- `oc` is installed and authenticated to the target cluster.
- The current user can administer cluster monitoring.
- The current user can create `ServiceMonitor` and `PrometheusRule` resources in `ns-a` and `ns-b`.
- The current user can create `ConfigMap` resources in `openshift-config-managed`.
- The Redis Enterprise metrics services expose HTTPS metrics on port `8070`, path `/v2`.

Run all commands from the repository root:

```bash
cd /path/to/redis-enterprise-observability
```

## 1. Set Deployment Variables

```bash
export REDIS_A_NS=ns-a
export REDIS_B_NS=ns-b
export REDIS_A_METRICS_SERVICE=rec-a-prom
export REDIS_B_METRICS_SERVICE=rec-b-prom
```

## 2. Confirm Redis Enterprise Metrics Services

```bash
oc -n "${REDIS_A_NS}" get svc "${REDIS_A_METRICS_SERVICE}" -o wide
oc -n "${REDIS_B_NS}" get svc "${REDIS_B_METRICS_SERVICE}" -o wide

oc -n "${REDIS_A_NS}" get endpoints "${REDIS_A_METRICS_SERVICE}" -o wide
oc -n "${REDIS_B_NS}" get endpoints "${REDIS_B_METRICS_SERVICE}" -o wide
```

Confirm that each service has:

- Label `redis.io/service=prom-metrics`
- A port named `prometheus`
- Port `8070`
- At least one endpoint

```bash
oc -n "${REDIS_A_NS}" get svc "${REDIS_A_METRICS_SERVICE}" \
  -o jsonpath='{.metadata.labels.redis\.io/service}{"\n"}{.spec.ports[?(@.port==8070)].name}{"\n"}'

oc -n "${REDIS_B_NS}" get svc "${REDIS_B_METRICS_SERVICE}" \
  -o jsonpath='{.metadata.labels.redis\.io/service}{"\n"}{.spec.ports[?(@.port==8070)].name}{"\n"}'
```

Expected output for each service:

```text
prom-metrics
prometheus
```

## 3. Confirm the Redis `/v2` Metrics Endpoint

Use an existing Redis Enterprise pod to test the metrics service:

```bash
oc -n "${REDIS_A_NS}" exec rec-a-0 -c redis-enterprise-node -- \
  sh -lc "curl -sk https://${REDIS_A_METRICS_SERVICE}.${REDIS_A_NS}.svc:8070/v2 | grep -m 5 '^redis_server_up\|^node_metrics_up\|^endpoint_client_connections'"

oc -n "${REDIS_B_NS}" exec rec-b-0 -c redis-enterprise-node -- \
  sh -lc "curl -sk https://${REDIS_B_METRICS_SERVICE}.${REDIS_B_NS}.svc:8070/v2 | grep -m 5 '^redis_server_up\|^node_metrics_up\|^endpoint_client_connections'"
```

Each command should print Redis Enterprise metrics.

## 4. Enable User Workload Monitoring

Skip this step only if user workload monitoring is already enabled.

```bash
cat <<'EOF' | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
EOF
```

Wait for the monitoring stack:

```bash
oc -n openshift-user-workload-monitoring rollout status statefulset/prometheus-user-workload --timeout=300s
oc -n openshift-user-workload-monitoring rollout status statefulset/thanos-ruler-user-workload --timeout=300s
oc -n openshift-user-workload-monitoring get pods
```

Expected result:

- `prometheus-user-workload-0` and `prometheus-user-workload-1` are running.
- `thanos-ruler-user-workload-0` and `thanos-ruler-user-workload-1` are running.

## 5. Server-Side Dry Run

```bash
NS="${REDIS_A_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-servicemonitor.yaml | oc apply --dry-run=server -f -

NS="${REDIS_B_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-servicemonitor.yaml | oc apply --dry-run=server -f -

NS="${REDIS_A_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-prometheusrule.yaml | oc apply --dry-run=server -f -

NS="${REDIS_B_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-prometheusrule.yaml | oc apply --dry-run=server -f -

oc apply --dry-run=server -f openshift/native-observe/dashboards/
```

All commands should report `created (server dry run)` or `configured (server dry run)`.

## 6. Apply Redis Enterprise Monitoring Resources

```bash
NS="${REDIS_A_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-servicemonitor.yaml | oc apply -f -

NS="${REDIS_B_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-servicemonitor.yaml | oc apply -f -

NS="${REDIS_A_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-prometheusrule.yaml | oc apply -f -

NS="${REDIS_B_NS}" yq eval '.metadata.namespace = env(NS)' \
  openshift/native-observe/redis-enterprise-prometheusrule.yaml | oc apply -f -
```

Confirm the resources:

```bash
oc -n "${REDIS_A_NS}" get servicemonitor redis-enterprise-observe
oc -n "${REDIS_B_NS}" get servicemonitor redis-enterprise-observe
oc -n "${REDIS_A_NS}" get prometheusrule redis-enterprise-observe-alerts
oc -n "${REDIS_B_NS}" get prometheusrule redis-enterprise-observe-alerts
```

## 7. Apply Native Observe Dashboards

```bash
oc apply -f openshift/native-observe/dashboards/
```

Confirm that thirteen dashboard `ConfigMap` resources were created:

```bash
oc -n openshift-config-managed get cm \
  -l app.kubernetes.io/name=redis-enterprise-observe \
  --sort-by=.metadata.name
```

## 8. Verify Metrics in OpenShift's Aggregate Query Path

Wait at least one scrape interval:

```bash
sleep 40
```

Query through the OpenShift Thanos querier. This is the same aggregate metrics path used by the OpenShift console.

```bash
TOKEN="$(oc whoami -t)"

oc -n openshift-user-workload-monitoring exec prometheus-user-workload-0 -c prometheus -- \
  sh -c "wget --no-check-certificate --header=\"Authorization: Bearer ${TOKEN}\" -qO- \
  'https://thanos-querier.openshift-monitoring.svc:9091/api/v1/query?query=up%7Bnamespace%3D%22ns-a%22%7D'"

oc -n openshift-user-workload-monitoring exec prometheus-user-workload-0 -c prometheus -- \
  sh -c "wget --no-check-certificate --header=\"Authorization: Bearer ${TOKEN}\" -qO- \
  'https://thanos-querier.openshift-monitoring.svc:9091/api/v1/query?query=up%7Bnamespace%3D%22ns-b%22%7D'"
```

Both queries should return a result with value `1`.

Run representative dashboard metric checks:

```bash
TOKEN="$(oc whoami -t)"

oc -n openshift-user-workload-monitoring exec prometheus-user-workload-0 -c prometheus -- sh -c '
base=https://thanos-querier.openshift-monitoring.svc:9091/api/v1/query
for q in \
  "count(redis_server_up{namespace=\"ns-a\"})" \
  "count(redis_server_up{namespace=\"ns-b\"})" \
  "sum(redis_server_used_memory{namespace=\"ns-a\",cluster=\"rec-a.ns-a.svc.cluster.local\"})" \
  "sum(redis_server_used_memory{namespace=\"ns-b\",cluster=\"rec-b.ns-b.svc.cluster.local\"})" \
  "sum(endpoint_client_connections{namespace=\"ns-a\"})" \
  "sum(endpoint_client_connections{namespace=\"ns-b\"})" \
  "count(node_metrics_up{namespace=\"ns-a\"})" \
  "count(node_metrics_up{namespace=\"ns-b\"})"; do
  enc=$(printf "%s" "$q" | sed "s/{/%7B/g;s/}/%7D/g;s/\"/%22/g;s/ /%20/g;s/=/%3D/g;s/,/%2C/g;s/+/%2B/g")
  printf "\nQUERY %s\n" "$q"
  wget --no-check-certificate --header="Authorization: Bearer '"${TOKEN}"'" -qO- "$base?query=$enc"
  printf "\n"
done
'
```

Expected results:

- `count(redis_server_up{namespace="ns-a"})` returns a nonzero value.
- `count(redis_server_up{namespace="ns-b"})` returns a nonzero value.
- Memory, connection, and node checks return values for both namespaces.

## 9. Verify Alert Rules

Check that Thanos Ruler loaded the rule files:

```bash
oc -n openshift-user-workload-monitoring logs thanos-ruler-user-workload-0 -c thanos-ruler --tail=200 | grep 'reload rule files'
oc -n openshift-user-workload-monitoring logs thanos-ruler-user-workload-1 -c thanos-ruler --tail=200 | grep 'reload rule files'
```

Expected result:

```text
reload rule files numFiles=2
```

PromQL informational warnings about metric names not ending in `_total`, `_sum`, `_count`, or `_bucket` can appear for existing Redis Enterprise alert expressions. Those warnings do not indicate a parse failure.

## 10. Verify Dashboards in the Console

Open the OpenShift console and go to:

```text
Observe -> Dashboards
```

Confirm that these dashboards are listed:

- Redis Enterprise / Basic / Cluster Status Dashboard
- Redis Enterprise / Basic / Database Status Dashboard
- Redis Enterprise / Basic / Node Dashboard
- Redis Enterprise / Basic / Shard Dashboard
- Redis Enterprise / Basic / Active-Active
- Redis Enterprise / Basic / Synchronization (Classic)
- Redis Enterprise / Ops / Cluster Dashboard
- Redis Enterprise / Ops / Database Dashboard
- Redis Enterprise / Ops / Node Dashboard
- Redis Enterprise / Ops / Shard dashboard
- Redis Enterprise / Ops / Latency Dashboard
- Redis Enterprise / Ops / Active-Active Lag
- Redis Enterprise / Ops / RediSearch QPS dashboard

For each dashboard:

1. Select `ns-a` or `ns-b` in the `namespace` variable.
2. Select the corresponding Redis Enterprise cluster.
3. Select database, node, shard, or CRDT variables where present.
4. Confirm panels render data.

## Rollback

Remove the Redis Enterprise Observe resources:

```bash
oc -n "${REDIS_A_NS}" delete servicemonitor redis-enterprise-observe --ignore-not-found
oc -n "${REDIS_B_NS}" delete servicemonitor redis-enterprise-observe --ignore-not-found
oc -n "${REDIS_A_NS}" delete prometheusrule redis-enterprise-observe-alerts --ignore-not-found
oc -n "${REDIS_B_NS}" delete prometheusrule redis-enterprise-observe-alerts --ignore-not-found
oc delete -f openshift/native-observe/dashboards/ --ignore-not-found
```

Do not disable user workload monitoring unless no other workloads depend on it.

If this runbook was the only reason user workload monitoring was enabled, remove it with care:

```bash
oc -n openshift-monitoring delete cm cluster-monitoring-config
```

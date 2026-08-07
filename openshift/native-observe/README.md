# Redis Enterprise Native OpenShift Observe

This directory contains example manifests for showing Redis Enterprise metrics in OpenShift's native Observe UI.

Contents:

- `redis-enterprise-servicemonitor.yaml`: Scrapes an in-cluster Redis Enterprise metrics service on `https://<service>:8070/v2`.
- `redis-enterprise-prometheusrule.yaml`: Wraps the Redis Enterprise Prometheus alert rules for OpenShift user workload monitoring.
- `dashboards/*.yaml`: Legacy OpenShift dashboard `ConfigMap` resources for Observe -> Dashboards.
- `kustomization.yaml`: Builds the complete manifest set with `oc kustomize`.
- `RUNBOOK.md`: Customer-facing deployment runbook for an existing Redis Enterprise active-active installation.

Defaults:

- Redis Enterprise namespace: `redis-enterprise`
- Metrics service selector: `redis.io/service=prom-metrics`
- Metrics service port name: `prometheus`
- Dashboard namespace: `openshift-config-managed`

See `docs/modules/ROOT/pages/guides/openshift-native-observe-dashboards.adoc` for the full installation guide.

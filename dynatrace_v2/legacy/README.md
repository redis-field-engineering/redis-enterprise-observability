# Dynatrace V2 Legacy Assets

This directory preserves the older self-managed Dynatrace workflow that relied on local extension source, dashboard JSON, and Terraform helpers.

Use this content only if you specifically need the historical Field Engineering implementation. The current recommended workflow is documented in `../README.adoc` and uses Dynatrace's published `redis-enterprise-prometheus` extension from Dynatrace Hub.

Contents:

- `src/` - historical extension source and dashboard JSON
- `gen-3-dashboards/` - generated dashboard exports
- `kickstarter/` - legacy Terraform and helper scripts

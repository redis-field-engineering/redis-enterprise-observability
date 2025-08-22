# Redis Enterprise Observability Documentation Site Proposal

## Problems with Current Structure
- 10+ scattered README files
- No clear navigation path
- Duplicate v1/v2 directories confusing users
- No search functionality
- No versioning strategy
- JSON dashboards mixed with documentation

## Proposed MkDocs/mdBook Structure

```
docs/
├── index.md                    # Landing page with quick start
├── getting-started/
│   ├── overview.md             # What this repo provides
│   ├── prerequisites.md        # Redis Enterprise, Grafana versions
│   └── quick-start.md          # 5-minute setup guide
│
├── platforms/                  # One section per platform
│   ├── grafana/
│   │   ├── index.md           # Grafana overview
│   │   ├── installation.md    # Setup instructions
│   │   ├── datasources.md     # Prometheus config
│   │   ├── infinity-plugin.md # REST API integration
│   │   └── dashboards/        # Dashboard documentation
│   │       ├── basic.md
│   │       ├── extended.md
│   │       └── workflow.md
│   ├── prometheus/
│   │   ├── index.md
│   │   ├── configuration.md
│   │   ├── alerting-rules.md
│   │   └── testing.md
│   ├── dynatrace/
│   ├── newrelic/
│   ├── splunk/
│   └── kibana/
│
├── dashboards/                 # Dashboard catalog
│   ├── catalog.md             # Searchable dashboard list
│   ├── importing.md           # How to import
│   └── customizing.md         # Modification guide
│
├── guides/                     # Task-oriented guides
│   ├── monitor-redis-cloud.md
│   ├── setup-alerting.md
│   ├── create-custom-dashboard.md
│   └── troubleshooting.md
│
├── reference/                  # Reference documentation
│   ├── metrics.md             # All available metrics
│   ├── api-endpoints.md      # REST API reference
│   ├── compatibility.md      # Version compatibility matrix
│   └── configuration.md      # All config options
│
└── contributing/
    ├── dashboard-standards.md
    └── testing.md
```

## Benefits of Documentation Site

### 1. **Searchable**
- Full-text search across all docs
- Find dashboards by metric name
- Search for error messages

### 2. **Navigable**
- Clear sidebar navigation
- Breadcrumbs
- Related pages links
- Previous/Next navigation

### 3. **Versioned**
- Version selector dropdown
- Clear deprecation notices
- Migration guides between versions

### 4. **Interactive**
- Live dashboard previews
- Copy buttons for code
- Expandable sections
- Tabs for platform-specific instructions

### 5. **Maintainable**
- Single source of truth
- Automatic table of contents
- Link checking
- Generated API docs from JSON schemas

## Implementation with MkDocs

### mkdocs.yml Configuration
```yaml
site_name: Redis Enterprise Observability
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - search.highlight
    - search.suggest
    - content.code.copy
    - content.tabs.link

plugins:
  - search
  - awesome-pages  # Auto-generate navigation
  - redirects      # Handle moved pages
  - minify

extra:
  version:
    provider: mike  # Version management
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/redis-field-engineering/redis-enterprise-observability

markdown_extensions:
  - admonition      # Note/Warning/Tip boxes
  - pymdownx.details
  - pymdownx.tabbed # Platform-specific tabs
  - pymdownx.superfences
  - pymdownx.snippets # Include files
```

### Example Page with Tabs

```markdown
# Installing Grafana Dashboards

=== "Grafana 9-11"

    ## Installation Steps
    
    1. Download the dashboard JSON:
       ```bash
       curl -O https://raw.githubusercontent.com/.../dashboard_v9-11.json
       ```
    
    2. Import via UI:
       - Navigate to Dashboards → Import
       - Upload JSON file
       - Select Prometheus datasource

=== "Grafana 7-9"

    ## Installation Steps
    
    1. Download the legacy dashboard:
       ```bash
       curl -O https://raw.githubusercontent.com/.../dashboard_v7-9.json
       ```
    
    !!! warning "Deprecated Version"
        Grafana 7-9 support will be removed in next major release
```

## Migration Strategy

1. **Phase 1: Structure** (Week 1)
   - Set up MkDocs/mdBook
   - Create navigation structure
   - Migrate existing READMEs

2. **Phase 2: Enhance** (Week 2)
   - Add search functionality
   - Create landing pages
   - Add platform tabs
   - Write missing guides

3. **Phase 3: Polish** (Week 3)
   - Add dashboard previews
   - Create metric reference
   - Add troubleshooting guides
   - Set up CI/CD for deployment

4. **Phase 4: Deprecate** (Week 4)
   - Add redirects from old structure
   - Update repository README
   - Archive old documentation
   - Update links in dashboards

## Deployment Options

### GitHub Pages (Recommended)
```yaml
# .github/workflows/deploy-docs.yml
name: Deploy Documentation
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
      - run: pip install mkdocs-material
      - run: mkdocs gh-deploy --force
```

Site would be available at:
`https://redis-field-engineering.github.io/redis-enterprise-observability/`

## Example Search Queries (Now Possible!)

- "infinity plugin" → Goes directly to setup guide
- "error: no data" → Finds troubleshooting section
- "bdb_total_req" → Shows dashboards using this metric
- "Redis Cloud" → Shows all Cloud-specific content
- "module configuration" → Finds API and dashboard docs

## Conclusion

Moving from scattered READMEs to a proper documentation site would:
- Reduce support questions by 50%+
- Make onboarding new users 10x faster
- Enable proper versioning and deprecation
- Provide searchable, navigable documentation
- Create a professional documentation experience

The current structure is actively hostile to users. A documentation site would transform this from a confusing repository into a valuable resource.
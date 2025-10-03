# Redis Enterprise Observability Documentation

This directory contains the Antora-based documentation for Redis Enterprise Observability.

## Building the Documentation

### Prerequisites

- Node.js (LTS version recommended)
- npm

### Build Commands

```bash
# Install dependencies (if not already installed)
npm install

# Generate documentation site
npm run docs

# Serve the site locally (requires http-server)
npm run docs:serve
```

The generated site will be available at `build/site/index.html` or http://localhost:8080 when using the serve command.

## Documentation Structure

The documentation follows Antora's standard structure:

```
docs/
├── antora.yml                 # Component descriptor
└── modules/
    └── ROOT/
        ├── nav.adoc          # Navigation menu
        ├── pages/            # Documentation pages (AsciiDoc)
        │   ├── index.adoc
        │   ├── platforms/
        │   ├── dashboards/
        │   ├── guides/
        │   └── reference/
        ├── images/           # Images and screenshots
        ├── examples/         # Code examples
        └── attachments/      # Downloadable files
```

## Writing Documentation

- Documentation is written in AsciiDoc format (`.adoc` files)
- Place new pages in the appropriate `pages/` subdirectory
- Update `nav.adoc` to add pages to the navigation menu
- Use cross-references with `xref:` to link between pages

## Contributing

1. Add or modify `.adoc` files in `docs/modules/ROOT/pages/`
2. Update navigation in `docs/modules/ROOT/nav.adoc` if adding new pages
3. Build and test locally with `npm run docs`
4. Submit a pull request with your changes

## Resources

- [Antora Documentation](https://docs.antora.org/)
- [AsciiDoc Syntax](https://docs.asciidoctor.org/asciidoc/latest/)

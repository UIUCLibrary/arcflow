# Scripts

This directory contains helper scripts for arcflow development and testing.

## Available Scripts

### setup-local-solr.sh

Automated setup script for running ArcLight Solr locally in Docker for testing.

**Usage:**
```bash
./scripts/setup-local-solr.sh
```

**What it does:**
- Checks for Docker prerequisites
- Helps you download/copy ArcLight Solr configuration
- Starts a local Solr instance in Docker
- Updates .gitignore to exclude solr-config

**See also:** [docs/LOCAL_SOLR_SETUP.md](../docs/LOCAL_SOLR_SETUP.md) for detailed documentation on local Solr setup.

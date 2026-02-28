# ArcFlow

Code for exporting data from ArchivesSpace to ArcLight, along with additional utility scripts for data handling and transformation.

## Local Development

### Testing with Local Solr

For local testing of indexing without affecting shared development environments, you can run ArcLight Solr in a Docker container. See [docs/LOCAL_SOLR_SETUP.md](docs/LOCAL_SOLR_SETUP.md) for detailed instructions.

Quick start:
```bash
./scripts/setup-local-solr.sh
```
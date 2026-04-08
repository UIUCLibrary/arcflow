# ArchivesSpace Solr Configset

This directory should contain the Solr configset for ArchivesSpace.

## What's Needed

Place the Solr configset files here that define the schema and configuration for the ArchivesSpace Solr core.

Required files typically include:
- `solrconfig.xml` - Solr configuration
- `schema.xml` or `managed-schema` - Field definitions
- Other configuration files as needed

## Where to Get These Files

You can obtain these configsets from:
1. Your existing ArchivesSpace installation's Solr directory
2. The ArchivesSpace v2.6.0 distribution (included in the release)
3. Your development server's ArchivesSpace Solr installation

## How Solr Uses This

When Solr starts, the `solr-entrypoint.sh` script will:
1. Check if this directory contains a configset
2. If found, create a blank `archivesspace-solr` core using this configset
3. The core will be empty (no data) and ready for ArchivesSpace to use

## Without This Configset

If this directory is empty, Solr will start but the `archivesspace-solr` core will not be created.
You'll see a warning in the logs:
```
⚠️  No configset found for archivesspace
```

ArchivesSpace may not function properly without this core, as it depends on Solr for search functionality.

The Solr admin UI will still be accessible at http://localhost:8983/solr/

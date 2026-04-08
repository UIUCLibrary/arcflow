# Blacklight Core Configset

This directory should contain the Solr configset for the ArcLight blacklight-core.

## What's Needed

Place the Solr configset files here that define the schema and configuration for the blacklight-core index used by ArcLight.

Required files typically include:
- `solrconfig.xml` - Solr configuration
- `schema.xml` or `managed-schema` - Field definitions
- Other configuration files as needed

## Where to Get These Files

You can obtain these configsets from:
1. Your existing ArcLight/Blacklight installation
2. The ArcLight project: https://github.com/projectblacklight/arclight
3. Your development server's Solr installation

## How Solr Uses This

When Solr starts, the `solr-entrypoint.sh` script will:
1. Check if this directory contains a configset
2. If found, create a blank `blacklight-core` using this configset
3. The core will be empty (no data) and ready for indexing

## Without This Configset

If this directory is empty, Solr will start but the `blacklight-core` will not be created.
You'll see a warning in the logs:
```
⚠️  No configset found for blacklight-core
```

The Solr admin UI will still be accessible at http://localhost:8983/solr/

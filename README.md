# ArcFlow

Code for exporting data from ArchivesSpace to ArcLight, along with additional utility scripts for data handling and transformation.

## Quick Start

This directory contains a complete, working installation of arcflow with creator records support. To run it:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure credentials
cp .archivessnake.yml.example .archivessnake.yml
nano .archivessnake.yml  # Add your ArchivesSpace credentials

# 3. Set environment variables
export ARCLIGHT_DIR=/path/to/your/arclight-app
export ASPACE_DIR=/path/to/your/archivesspace
export SOLR_URL=http://localhost:8983/solr/blacklight-core

# 4. Run arcflow
python -m arcflow.main 

```

---

## Features

- **Collection Indexing**: Exports EAD XML from ArchivesSpace and indexes to ArcLight Solr
- **Creator Records**: Extracts creator agent information and indexes as standalone documents
- **Biographical Notes**: Injects creator biographical/historical notes into collection EAD XML
- **PDF Generation**: Generates finding aid PDFs via ArchivesSpace jobs
- **Incremental Updates**: Supports modified-since filtering for efficient updates

## Creator Records

ArcFlow now generates standalone creator documents in addition to collection records. Creator documents:

- Include biographical/historical notes from ArchivesSpace agent records
- Link to all collections where the creator is listed
- Can be searched and displayed independently in ArcLight
- Are marked with `is_creator: true` to distinguish from collections
- Must be fed into a Solr instance with fields to match their specific facets (See: Configure Solr Schema below)

### How Creator Records Work

1. **Extraction**: `get_all_agents()` fetches all agents from ArchivesSpace
2. **Processing**: `task_agent()` generates an EAC-CPF XML document for each agent with bioghist notes
3. **Linking**: Handled via Solr using the persistent_id field (agents and collections linked through bioghist references)
4. **Indexing**: Creator XML files are indexed to Solr using `traject_config_eac_cpf.rb`

### Creator Document Format

Creator documents are stored as XML files in `agents/` directory using the ArchivesSpace EAC-CPF export:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xml:lang="eng" xmlns="urn:isbn:1-931666-33-4" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:isbn:1-931666-33-4 https://eac.staatsbibliothek-berlin.de/schema/cpf.xsd">
  <control/>
  <cpfDescription>
    <identity>
      <entityType>corporateBody</entityType>
      <nameEntry>
        <part localType="primary_name">Core: Leadership, Infrastructure, Futures</part>
        <authorizedForm>local</authorizedForm>
      </nameEntry>
    </identity>
    <description>
      <existDates>
        <date localType="existence" standardDate="2020">2020-</date>
      </existDates>
      <biogHist>
        <p>Founded on September 1, 2020, the Core: Leadership, Infrastructure, Futures division of the American Library Association has a mission to cultivate and amplify the collective expertise of library workers in core functions through community building, advocacy, and learning.
          In June 2020, the ALA Council voted to approve Core: Leadership, Infrastructure, Futures as a new ALA division beginning September 1, 2020, and to dissolve the Association for Library Collections and Technical Services (ALCTS), the Library Information Technology Association (LITA) and the Library Leadership and Management Association (LLAMA) effective August 31, 2020. The vote to form Core was 163 to 1.(1)</p>
        <citation>1. "ALA Council approves Core; dissolves ALCTS, LITA and LLAMA," July 1, 2020, http://www.ala.org/news/member-news/2020/07/ala-council-approves-core-dissolves-alcts-lita-and-llama.</citation>
      </biogHist>
    </description>
    <relations/>
  </cpfDescription>
</eac-cpf>
```

### Indexing Creator Documents

#### Configure Solr Schema (Required Before Indexing)

⚠️ **CRITICAL PREREQUISITE** - Before you can index creator records to Solr, you must configure the Solr schema.

**See [SOLR_SCHEMA.md](SOLR_SCHEMA.md) for complete instructions on:**
- Which fields to add (is_creator, creator_persistent_id, etc.)
- Three methods to add them (Schema API recommended, managed-schema, or schema.xml)
- How to verify they're added
- Troubleshooting "unknown field" errors

**Quick Schema Setup (Schema API method):**
```bash
# Add is_creator field
curl -X POST -H 'Content-type:application/json' \
  http://localhost:8983/solr/blacklight-core/schema \
  -d '{"add-field": {"name": "is_creator", "type": "boolean", "indexed": true, "stored": true}}'

# Add other required fields (see SOLR_SCHEMA.md for complete list)
```

**Verify schema is configured:**
```bash
curl "http://localhost:8983/solr/blacklight-core/schema/fields/is_creator"
# Should return field definition, not 404
```

⚠️ **If you skip this step, you'll get:**
```
ERROR: [doc=creator_corporate_entities_584] unknown field 'is_creator'
```

This is a **one-time setup** per Solr instance.

---

To index creator documents to Solr:

```bash
bundle exec traject \
  -u http://localhost:8983/solr/blacklight-core \
  -i xml \
  -c traject_config_eac_cpf.rb \
  /path/to/agents/*.xml
```

Or integrate into your ArcFlow deployment workflow.

## Installation

See the original installation instructions in your deployment documentation.

## Configuration

- `.archivessnake.yml` - ArchivesSpace API credentials
- `.arcflow.yml` - Last update timestamp tracking

## Usage

```bash
python -m arcflow.main --arclight-dir /path --aspace-dir /path --solr-url http://... [options]
```

### Command Line Options

Required arguments:
- `--arclight-dir` - Path to ArcLight installation directory
- `--aspace-dir` - Path to ArchivesSpace installation directory
- `--solr-url` - URL of the Solr core (e.g., http://localhost:8983/solr/blacklight-core)

Optional arguments:
- `--force-update` - Force update of all data (recreates everything from scratch)
- `--traject-extra-config` - Path to extra Traject configuration file
- `--agents-only` - Process only agent records, skip collections (useful for testing agents)
- `--collections-only` - Skips creators, processes EAD, PDF finding aid and indexes collections
- `--skip-creator-indexing` - Collects EAC-CPF files only, does not index into Solr
### Examples

**Normal run (process all collections and agents):**
```bash
python -m arcflow.main \
  --arclight-dir /path/to/arclight \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core
```

**Process only agents (skip collections):**
```bash
python -m arcflow.main \
  --arclight-dir /path/to/arclight \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core \
  --agents-only
```

**Force full update:**
```bash
python -m arcflow.main \
  --arclight-dir /path/to/arclight \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core \
  --force-update
```

See `--help` for all available options.
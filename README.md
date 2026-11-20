# ArcFlow

Code for exporting data from ArchivesSpace to ArcLight, along with additional utility scripts for data handling and transformation.

## Quick Start

This directory contains a complete, working installation of arcflow with creator records support. To run it:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure arcflow
cp .arcflow.config.yml.example .arcflow.config.yml
nano .arcflow.config.yml  # Add your settings

# 3. Run arcflow
python -m arcflow.main
```

---

## Features

- **Collection Indexing**: Exports EAD XML from ArchivesSpace and indexes to ArcLight Solr
- **Creator Records**: Extracts creator agent information and indexes as standalone documents
- **Biographical Notes**: Injects creator biographical/historical notes into collection EAD XML
- **PDF Generation**: Generates finding aid PDFs via ArchivesSpace jobs
- **Digital Object Metadata**: Exports published digital objects as MODS sidecars that Arcuit indexes as child documents
- **Incremental Updates**: Supports modified-since filtering for efficient updates

## Creator Records

ArcFlow now generates standalone creator documents in addition to collection records.

**Requires the [aspace-eac-cpf-2](https://github.com/UIUCLibrary/aspace-eac-cpf-2) ArchivesSpace plugin.** Creator records are fetched as EAC-CPF 2.0 from `/agents/{people,corporate_entities,families}/{id}/eac_cpf_2.xml`, which contains published data only. ArchivesSpace's own `/archival_contexts` EAC-CPF 2010 export is not used: it reverses hierarchical and temporal relationships between agents and exports unpublished notes and records (UIUCLibrary/arclight#88). If the plugin is not installed, ArcFlow logs a critical error and skips creators rather than treating every agent as missing.

An agent the plugin answers with 404 (unpublished or deleted) has its creator record removed from Solr and from `agents/`.

Creator documents:

- Include biographical/historical notes from ArchivesSpace agent records
- Link to all collections where the creator is listed
- Can be searched and displayed independently in ArcLight
- Are marked with `is_creator: true` to distinguish from collections
- Must be fed into a Solr instance with fields to match their specific facets (See: Configure Solr Schema below)

### Agent Filtering

**ArcFlow automatically filters agents to include only legitimate creators** of archival materials. The following agent types are **excluded** from indexing:

- ✗ **System users** - ArchivesSpace software users (identified by `is_user` field)
- ✗ **System-generated agents** - Auto-created for users (identified by `system_generated` field)
- ✗ **Software agents** - Excluded by not querying the `/agents/software` endpoint
- ✗ **Repository agents** - Corporate entities representing the repository itself (identified by `is_repo_agent` field)
- ✗ **Donor-only agents** - Agents with only the 'donor' role and no creator role

**Agents are included if they meet any of these criteria:**

- ✓ Have the **'creator' role** in linked_agent_roles
- ✓ Are **linked to published records** (and not excluded by filters above)

This filtering ensures that only legitimate archival creators are discoverable in ArcLight, while protecting privacy and security by excluding system users and donors.

### How Creator Records Work

1. **Extraction**: `get_all_agents()` fetches all agents from ArchivesSpace
2. **Filtering**: `is_target_agent()` filters out system users, donors, and non-creator agents  
3. **Processing**: `task_agent()` fetches the EAC-CPF 2.0 record for each target agent from the aspace-eac-cpf-2 plugin
4. **Linking**: Handled via Solr using the persistent_id field (agents and collections linked through bioghist references)
5. **Indexing**: Creator XML files are indexed to Solr using `traject_config_eac_cpf.rb`

### Creator Document Format

Creator documents are stored as `agents/creator_{entity_type}_{id}.xml`, exactly as the plugin returns them. Relationships read from the described creator to the related one, and linked collections carry their EAD ID in `aspace:eadId`, so no post-processing is needed:

```xml
<eac xmlns="https://archivists.org/ns/eac/v2" xmlns:aspace="https://github.com/UIUCLibrary/aspace-eac-cpf-2#">
  <control maintenanceStatus="revised">...</control>
  <cpfDescription>
    <identity>
      <entityType value="corporateBody"/>
      <nameEntry status="authorized" preferredForm="true" aspace:sortName="Administrative Services Office">
        <part localType="primary_name">Administrative Services Office</part>
      </nameEntry>
    </identity>
    <description>
      <biogHist><head>Historical Note</head><p>System Human Resource Services is dedicated to ...</p></biogHist>
    </description>
    <relations>
      <relation>
        <targetEntity targetType="corporateBody" valueURI="https://archivesspace.example.edu/agents/corporate_entities/1539">
          <part>University of Illinois at Urbana-Champaign. Office of the Chancellor</part>
        </targetEntity>
        <relationType localType="is_subordinate_to" vocabularySource="RiC-O"
                      valueURI="https://www.ica.org/standards/RiC/ontology#isOrWasSubordinateTo">is or was subordinate to</relationType>
      </relation>
      <relation>
        <targetEntity targetType="resource" aspace:recordType="resource" aspace:eadId="UA.24.12.812"
                      valueURI="https://archivesspace.example.edu/repositories/7/resources/5246">
          <part>Mailing Services Publications</part>
        </targetEntity>
        <relationType localType="creator" vocabularySource="RiC-O"
                      valueURI="https://www.ica.org/standards/RiC/ontology#isCreatorOf">is creator of</relationType>
      </relation>
    </relations>
  </cpfDescription>
</eac>
```

The biographical notes ArcFlow copies into collection EADs follow the same publication rules: an unpublished agent, note or subnote is left out.

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

### Traject Configuration for Creator Indexing

The `traject_config_eac_cpf.rb` file defines how EAC-CPF creator records are mapped to Solr fields.

**Search Order**: arcflow searches for the traject config following the collection records pattern:
1. **arcuit_dir parameter** (if provided via `--arcuit-dir`) - Highest priority, most up-to-date user control
2. **arcuit gem** (via `bundle show arcuit`) - For backward compatibility when arcuit_dir not provided
3. **example_traject_config_eac_cpf.rb** in arcflow - Fallback for module usage without arcuit

**Example File**: arcflow includes `example_traject_config_eac_cpf.rb` as a reference implementation. For production:
- Copy this file to your arcuit gem as `traject_config_eac_cpf.rb`, or
- Specify the location with `--arcuit-dir /path/to/arcuit`

**Logging**: arcflow clearly logs which traject config file is being used when creator indexing runs.

To index creator documents to Solr manually:

```bash
bundle exec traject \
  -u http://localhost:8983/solr/blacklight-core \
  -i xml \
  -c traject_config_eac_cpf.rb \
  /path/to/agents/*.xml
```

Or integrate into your ArcFlow deployment workflow.

## Digital Object Metadata (MODS Sidecars)

Whenever ArcFlow writes a collection's EAD, it also writes a MODS sidecar describing the collection's published digital objects:

```
<arclight>/public/xml/resources/<ead_id>.xml
<arclight>/public/xml/resources/digital_objects/<ead_id>.mods.xml
```

The sidecar is a `<modsCollection>` with one `<mods version="3.8">` per published digital object linked to the resource or to one of its published archival objects. Its format is the contract described in the header of Arcuit's `example_docs/xml/digital_objects/UA.99.1.1.mods.xml`. Each record carries the digital object URI in `recordInfo/recordIdentifier[@source="ArchivesSpace"]` and one `relatedItem[@type="host"]` per linked archival object or resource, which Arcuit uses to attach the digital object to the right component.

**What is exported:**
- Digital objects are included only when published and not suppressed. Unpublished notes, file versions and agents are left out.
- Hosts come from the archival objects' current `instances` in ArchivesSpace, not from the EAD's `<dao>` elements, so a deleted or unpublished digital object never lingers in the sidecar.
- When a collection has no published digital objects, no sidecar is written and any old one is removed.
- If the sidecar can't be built, ArcFlow logs a critical error, removes the stale sidecar and indexes the collection without digital object metadata.

**Keeping sidecars current:** Editing a digital object doesn't reliably update the timestamp of the resource it belongs to, so incremental collection runs also:
1. Poll `GET /repositories/:repo_id/digital_objects?all_ids=true&modified_since=<last run>` and re-export every collection linked to the changed digital objects.
2. Look up those digital objects, plus the ones in the delete feed, in ArcLight Solr (`digital_object_uri_ssi`) and re-export the collections they were indexed with. This covers digital objects that were deleted, unpublished, suppressed or moved to another collection.

`--skip-deleted-record-processing` also skips the delete feed lookup in step 2. `--digital-objects-only` runs don't refresh sidecars; the next collections run catches up.

**Indexing:** ArcFlow passes `-s arcuit.digital_objects_dir=<arclight>/public/xml/resources/digital_objects` to traject. Arcuit versions without digital object support ignore this setting.

## Installation

See the original installation instructions in your deployment documentation.

## Configuration

- `.arcflow.config.yml` - Single configuration file with connection settings for ArchivesSpace, ArcLight, Omeka, and Archon, plus other deployment-specific options
- `.arcflow.state.yml` - Machine-managed run state (auto-generated/updated by ArcFlow; tracks timestamps used for incremental processing). Not meant to be edited manually.

## Usage

```bash
python -m arcflow.main [options]
```

### Command Line Options

Optional arguments:
- `--force-update` - Force update of all data (recreates everything from scratch)
- `--ead-extra-config` - Path to extra Traject configuration file
- `--agents-only` - Process only agent records, skip collections (useful for testing agents)
- `--collections-only` - Skips creators, processes EAD, PDF finding aid and indexes collections
- `--skip-creator-indexing` - Collects EAC-CPF files only, does not index into Solr
### Examples

**Normal run (process all collections and agents):**
```bash
python -m arcflow.main

```

**Process only agents (skip collections):**
```bash
python -m arcflow.main \
  --agents-only
```

**Force full update:**
```bash
python -m arcflow.main \
  --force-update
```

See `--help` for all available options.
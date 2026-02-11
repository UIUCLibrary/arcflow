# Testing Guide: Creator Records Migration

This guide provides step-by-step instructions for testing the creator records migration using native EAC-CPF format from ArchivesSpace.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Migrating a Single Creator Record](#migrating-a-single-creator-record)
3. [Viewing Creator Records](#viewing-creator-records)
4. [Querying Solr](#querying-solr)
5. [Troubleshooting](#troubleshooting)

---

## Step 0: Configure Solr Schema (PREREQUISITE)

⚠️ **CRITICAL FIRST STEP** - Before indexing creator records, configure the Solr schema.

**See the parent directory's `solr/README.md` for:**
- Which fields to add to Solr
- How to manually add them to schema.xml
- How to verify they're added

**Quick check if schema is configured:**
```bash
curl "http://localhost:8983/solr/blacklight-core/schema/fields/is_creator"
# Should return field definition
```

---

## Prerequisites

### Required Software
- Python 3.4.3+ with ArchivesSnake installed
- Ruby 3.4.3+ with Bundler
- Access to ArchivesSpace instance
- Access to Solr instance (typically running on port 8983)
- ArcLight application installed
- Solr schema configured (see Step 0 above)

### Required Configuration

1. **ArchivesSpace credentials** (`.archivessnake.yml`):
   ```yaml
   baseurl: http://your-archivesspace-server:8089
   username: your-username
   password: your-password
   ```

2. **Solr URL**: Note your Solr endpoint, typically:
   ```
   http://localhost:8983/solr/blacklight-core
   ```

3. **ArcLight directory**: Path to your ArcLight application (e.g., `/path/to/arclight-app`)

---

## Migrating a Single Creator Record

### Quick Method: Using the Test Function

Test a single creator using the built-in test function:

```bash
cd /path/to/arcuit/arcflow-phase1-revised

# Set environment variables
export ARCLIGHT_DIR=/path/to/arclight-app
export ASPACE_DIR=/path/to/archivesspace
export SOLR_URL=http://localhost:8983/solr/blacklight-core

# Test a single creator
python -m arcflow.main test-single-creator \
  --agent-uri /agents/corporate_entities/584
```

This will:
1. Process the specified agent
2. Generate the creator EAC-CPF XML file  
3. Link it to collections
4. Show you the output file path and indexing command

### Step 1: Identify a Test Creator

Find a creator agent in ArchivesSpace that has a biographical/historical note:

```bash
# List agents with creator role
curl -u username:password \
  "http://your-archivesspace-server:8089/repositories/2/resources/1" | \
  jq '.linked_agents[] | select(.role == "creator") | .ref'
```

Example output:
```
"/agents/corporate_entities/584"
```

### Step 2: Verify Agent Has Bioghist

Check that the agent has biographical/historical notes:

```bash
curl -u username:password \
  "http://your-archivesspace-server:8089/agents/corporate_entities/584" | \
  jq '.notes[] | select(.jsonmodel_type == "note_bioghist")'
```

If this returns data, the agent is suitable for testing.

### Step 3: Run ArcFlow for Single Creator

```bash
cd /path/to/arcuit/arcflow-phase1-revised

export ARCLIGHT_DIR=/path/to/arclight-app
export ASPACE_DIR=/path/to/archivesspace
export SOLR_URL=http://localhost:8983/solr/blacklight-core

# Process the specific creator
python -m arcflow.main test-single-creator \
  --agent-uri /agents/corporate_entities/584
```

This processes the creator and shows you the output.

To process all creators:

```bash
cd /path/to/arcuit/arcflow-phase1-revised
python -m arcflow.main --force-update
```

### Step 4: Locate the Generated Creator EAC-CPF XML

After ArcFlow completes, check the agents directory:

```bash
cd /path/to/arclight-app/public/xml/agents

# List all creator XML files
ls -lh creator_*.xml

# View a specific creator file
cat creator_corporate_entities_584.xml
```

**EAC-CPF format structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4">
  <control/>
  <cpfDescription>
    <identity>
      <entityType>corporateBody</entityType>
      <nameEntry>
        <part localType="primary_name">"I" Men's Association</part>
        <authorizedForm>local</authorizedForm>
      </nameEntry>
    </identity>
    <description>
      <biogHist>
        <p>The "I" Men's Association is composed of alumni...</p>
      </biogHist>
    </description>
    <relations>
      <cpfRelation cpfRelationType="hierarchical-parent"
                   xlink:href=".../agents/corporate_entities/57">
        <relationEntry>University of Illinois...</relationEntry>
      </cpfRelation>
      <resourceRelation resourceRelationType="creatorOf"
                        xlink:href=".../resources/586">
        <relationEntry>1927 Reunion Publications</relationEntry>
      </resourceRelation>
    </relations>
  </cpfDescription>
</eac-cpf>
```

**Key Elements:**
- `<control/>` - Typically empty from ArchivesSpace
- `<identity>` - Entity type and name
- `<biogHist>` - Biographical/historical note
- `<resourceRelation>` - Links to collections

### Step 5: Index the Creator to Solr

Index the creator record to Solr:

```bash
cd /path/to/arclight-app

# Index a single creator file
bundle exec traject \
  -u http://localhost:8983/solr/blacklight-core \
  -i xml \
  -c /path/to/arcuit/arcflow-phase1-revised/traject_config_eac_cpf.rb \
  public/xml/agents/creator_corporate_entities_584.xml
```

Expected output:
```
Traject indexer starting id=...
INFO: Using filename-based ID: creator_corporate_entities_584
Indexed creator: creator_corporate_entities_584
Committed 1 documents to Solr
```

To index all creators:
```bash
bundle exec traject \
  -u http://localhost:8983/solr/blacklight-core \
  -i xml \
  -c /path/to/arcuit/arcflow-phase1-revised/traject_config_eac_cpf.rb \
  public/xml/agents/creator_*.xml
```

---

## Viewing Creator Records

View creator records in three ways:

### Method 1: Direct File Inspection

View creator data directly:

```bash
# View a creator EAC-CPF XML file
cat public/xml/agents/creator_corporate_entities_584.xml

# Or use xmllint for pretty printing
xmllint --format public/xml/agents/creator_corporate_entities_584.xml

# View specific elements
xmllint --xpath '//identity/nameEntry/part/text()' public/xml/agents/creator_corporate_entities_584.xml
```

Example EAC-CPF structure:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4">
  <control/>
  <cpfDescription>
    <identity>
      <entityType>corporateBody</entityType>
      <nameEntry>
        <part>"I" Men's Association</part>
      </nameEntry>
    </identity>
    <description>
      <biogHist>
        <p>The "I" Men's Association is composed of alumni...</p>
      </biogHist>
    </description>
  </cpfDescription>
</eac-cpf>
```

### Method 2: Command-Line Solr Queries (curl)

Query Solr directly using curl:

#### Basic Query: All Creator Records
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&rows=10&wt=json" | jq '.'
```

#### Query Specific Creator by ID
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&wt=json" | jq '.response.docs[0]'
```

#### Search Creators by Name
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=title:*Association*&fq=is_creator:true&wt=json" | jq '.response.docs'
```

#### Get Creator with All Fields
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&wt=json" | jq '.response.docs[0]'
```

Example response:
```json
{
  "id": "creator_corporate_entities_584",
  "title": ["\"I\" Men's Association"],
  "is_creator": true,
  "entity_type": "corporateBody",
  "agent_type": "corporate_entities",
  "agent_id": 584
}
```

#### Count Total Creator Records
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&rows=0&wt=json" | jq '.response.numFound'
```

#### Search Bioghist Content
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=text:established&fq=is_creator:true&fl=id,title&wt=json" | jq '.response.docs'
```

### Method 3: Browser-Based Solr Queries

Open these URLs in your web browser for formatted output:

#### View All Creator Records
```
http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&rows=10&wt=json&indent=true
```

#### View Specific Creator
```
http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&wt=json&indent=true
```

#### Search by Creator Name
```
http://localhost:8983/solr/blacklight-core/select?q=title:*Association*&fq=is_creator:true&wt=json&indent=true
```

#### Browse Creators with Facets
```
http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&facet=true&facet.field=entity_type&rows=10&wt=json&indent=true
```

#### Get Only Specific Fields
```
http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&fl=id,title,entity_type&rows=10&wt=json&indent=true
```

---

## Querying Solr

### Understanding Solr Query Parameters

- **`q=*:*`** - Match all documents (use `q=field:value` to search specific fields)
- **`fq=is_creator:true`** - Filter to only creator records
- **`rows=10`** - Return 10 results (default is 10, max is usually 1000+)
- **`fl=id,title`** - Return only specified fields (default is all fields)
- **`wt=json`** - Return JSON format (alternatives: xml, csv)
- **`indent=true`** - Pretty-print JSON output
- **`start=0`** - Pagination offset (start=10 for second page with rows=10)

### Useful Query Patterns

#### 1. Find Collections Linked to a Creator

To find collections created by a specific creator, look for resourceRelation links in the creator's EAC-CPF:

```bash
# First get the creator's linked collections
curl "http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&fl=related_resources&wt=json" | jq '.response.docs[0]'

# Then query for those specific collection IDs
curl "http://localhost:8983/solr/blacklight-core/select?q=id:(resource_586 OR resource_123)&wt=json"
```

**Note:** Collection links are stored in the creator's `<resourceRelation>` elements in the EAC-CPF XML.

#### 2. Find All Corporate Entity Creators
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=entity_type:corporateBody&fq=is_creator:true&rows=20&wt=json" | jq '.response.docs[] | {id, title}'
```

#### 3. Full-Text Search in Bioghist
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=text:university&fq=is_creator:true&fl=id,title&wt=json" | jq '.response.docs[0]'
```

#### 4. Get Creator with All Fields
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&wt=json&indent=true" | jq '.response.docs[0]'
```

#### 5. Verify Creator Records Don't Appear in Standard Searches
This is important for Phase 2 - ensure creators are properly filtered:

```bash
# This should return 0 if Phase 2 is implemented (currently will return creators)
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=-is_creator:true&rows=0&wt=json" | jq '.response.numFound'
```

### Advanced Queries

#### Wildcard Search
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=title:*Association*&fq=is_creator:true&wt=json" | jq '.response.docs[] | .title'
```

#### Boolean Operators
```bash
# OR
curl "http://localhost:8983/solr/blacklight-core/select?q=title:(Association%20OR%20University)&fq=is_creator:true&wt=json"

# AND
curl "http://localhost:8983/solr/blacklight-core/select?q=title:Association%20AND%20text:alumni&fq=is_creator:true&wt=json"

# NOT
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*%20NOT%20entity_type:person&fq=is_creator:true&wt=json"
```

---

## Troubleshooting

### Issue: No XML Files Generated

**Symptom**: The `public/xml/agents/` directory is empty after running ArcFlow.

**Solutions**:
```bash
# Check ArcFlow logs
tail -f logs/arcflow.log

# Verify agents have bioghist notes in ArchivesSpace
curl -u username:password \
  "http://your-archivesspace-server:8089/agents/corporate_entities/584" | \
  jq '.notes[] | select(.jsonmodel_type == "note_bioghist")'

# Check if agents directory exists
ls -la /path/to/arclight-app/public/xml/agents/
```

### Issue: Missing ID Field Error

**Symptom**: `Document is missing mandatory uniqueKey field: id`

**Solutions**:
```bash
# Verify using the correct traject config
bundle exec traject \
  -c /path/to/arcuit/arcflow-phase1-revised/traject_config_eac_cpf.rb \
  public/xml/agents/creator_*.xml

# Check filename format (should start with creator_)
ls public/xml/agents/creator_*.xml
```

### Issue: Traject Indexing Fails

**Symptom**: Error when running `bundle exec traject`

**Solutions**:
```bash
# Verify Solr is running
curl "http://localhost:8983/solr/admin/cores?action=STATUS&wt=json"

# Validate XML file
xmllint --noout public/xml/agents/creator_*.xml

# Verify Solr schema has required fields
curl "http://localhost:8983/solr/blacklight-core/schema/fields/is_creator"
```

### Issue: No Results in Solr

**Symptom**: Queries return 0 results even after indexing

**Possible causes**:
1. Documents not committed to Solr
2. Wrong Solr core/collection
3. Indexing to different Solr than querying

**Solutions**:
```bash
# Force commit in Solr
curl "http://localhost:8983/solr/blacklight-core/update?commit=true"

# Check which cores exist
curl "http://localhost:8983/solr/admin/cores?action=STATUS&wt=json" | jq '.status | keys'

# Verify documents were indexed
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&rows=0&wt=json" | jq '.response.numFound'

# Check specifically for creator records
curl "http://localhost:8983/solr/blacklight-core/select?q=is_creator:true&rows=0&wt=json" | jq '.response.numFound'
```

### Issue: Missing Fields in Solr

**Symptom**: Some fields are missing when querying Solr

**Possible causes**:
1. Fields not defined in Solr schema
2. Traject config not mapping fields correctly
3. Source data missing from ArchivesSpace

**Solutions**:
```bash
# Check which fields exist for a document
curl "http://localhost:8983/solr/blacklight-core/select?q=id:creator_corporate_entities_584&wt=json" | jq '.response.docs[0] | keys'

# View Solr schema for creator-related fields
curl "http://localhost:8983/solr/blacklight-core/schema/fields?wt=json" | jq '.fields[] | select(.name | contains("creator") or . == "is_creator")'

# Check source XML has the data
xmllint --xpath '//identity/nameEntry/part/text()' public/xml/agents/creator_corporate_entities_584.xml
```

### Issue: Creator Records Appear in Standard Searches

**Note**: This is expected behavior for Phase 1. Phase 2 will add search exclusion in Arcuit.

To manually filter creators from searches:
```bash
curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=-is_creator:true&wt=json"
```

---

## Verification Checklist

Use this checklist to verify your creator records migration:

- [ ] ArcFlow runs without errors
- [ ] EAC-CPF XML files created in `public/xml/agents/` directory
- [ ] XML files have correct structure (control, cpfDescription, identity, biogHist, relations)
- [ ] Filename format is correct (e.g., `creator_corporate_entities_584.xml`)
- [ ] Traject indexing completes successfully with `traject_config_eac_cpf.rb`
- [ ] Solr query returns creator records: `curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&rows=1&wt=json"`
- [ ] Creator has `is_creator: true` field
- [ ] Creator has `entity_type` field (corporateBody, person, or family)
- [ ] Creator name is indexed in `title` field
- [ ] Bioghist content is searchable: `curl "http://localhost:8983/solr/blacklight-core/select?q=text:*&fq=is_creator:true&rows=1&wt=json"`
- [ ] Related resources are captured (if present in `<resourceRelation>` elements)
- [ ] All expected fields are present in Solr document

---

## Next Steps

After verifying creator records are indexed:

1. **Phase 2**: Implement search exclusion in Arcuit to filter `is_creator:true` from standard searches
2. **Phase 3**: Create creator show page in Arcuit to display creator records
3. **Phase 4-7**: Add UI enhancements (search dropdown, links from collections, etc.)

---

## Additional Resources

- **Solr Configuration**: See `../solr/README.md` for schema setup
- **Solr Documentation**: https://solr.apache.org/guide/
- **ArcLight Documentation**: https://github.com/projectblacklight/arclight
- **EAC-CPF Standard**: https://eac.staatsbibliothek-berlin.de/
- **ArchivesSnake Documentation**: https://github.com/archivesspace-labs/ArchivesSnake

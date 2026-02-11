# Arcflow Phase 1: Creator Records Implementation

This directory contains the complete implementation of Phase 1 (Creator Records Data Pipeline) for the arcflow repository.

## What This Is

This directory is a **complete, working copy of arcflow** with all Phase 1 creator records changes already applied. You can run it directly from here!

## Purpose

This allows you to:
1. **Run arcflow directly** to test the creator records feature immediately
2. **Review all arcflow changes** without needing separate repository access
3. **Create the arcflow PR** using the provided documentation when ready

---

## How to Use

### Option 1: Run Directly from This Directory (Recommended for Testing)

The simplest way to test the creator records feature is to run arcflow directly from this directory:

#### Step 1: Install Dependencies

```bash
cd arcflow-phase1

# Install Python dependencies
pip install -r requirements.txt
```

#### Step 2: Configure Credentials

```bash
# Copy the example configuration
cp .archivessnake.yml.example .archivessnake.yml

# Edit with your ArchivesSpace credentials
nano .archivessnake.yml  # or use your preferred editor
```

Edit `.archivessnake.yml` with your settings:
```yaml
baseurl: http://your-archivesspace-server:8089
username: your-username
password: your-password
```

#### Step 3: Create ArcFlow Configuration

```bash
# Create .arcflow.yml to track last update time
cat > .arcflow.yml << EOF
last_updated: '1970-01-01T00:00:00+00:00'
EOF
```

Or run with `--force-update` flag to process all resources.

#### Step 4: Run ArcFlow

```bash
# Run arcflow with required arguments
python -m arcflow.main \
  --arclight-dir /path/to/your/arclight-app \
  --aspace-dir /path/to/your/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core

# Or with force update to process everything
python -m arcflow.main \
  --arclight-dir /path/to/your/arclight-app \
  --aspace-dir /path/to/your/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core \
  --force-update

# Or to process only agents (skip collections - useful for testing)
python -m arcflow.main \
  --arclight-dir /path/to/your/arclight-app \
  --aspace-dir /path/to/your/archivesspace \
  --solr-url http://localhost:8983/solr/blacklight-core \
  --agents-only
```

#### Step 5: View Results

```bash
# Check for creator XML files
ls -lh $ARCLIGHT_DIR/public/xml/agents/

# View a creator file
cat $ARCLIGHT_DIR/public/xml/agents/creator_*.xml | jq '.'

# Index to Solr
cd $ARCLIGHT_DIR
bundle exec traject -u $SOLR_URL -i xml \
  -c /path/to/arcuit/arcflow-phase1-revised/traject_config_eac_cpf.rb \
  public/xml/agents/*.xml
```

**See `TESTING.md` for comprehensive testing instructions!**

#### Testing a Single Creator

For faster testing, use the test-single-creator command to process just one agent:

```bash
cd arcflow-phase1

# Set environment variables
export ARCLIGHT_DIR=/path/to/your/arclight-app
export ASPACE_DIR=/path/to/your/archivesspace

# Test a single creator agent
python -m arcflow.main test-single-creator \
  --agent-uri /agents/agent_corporate_entities/123

# The command will show you:
# - The created XML file path
# - The traject command to index it
```

This is much faster than processing all creators and is ideal for development and testing.

---

### Configure Solr Schema (Required Before Indexing)

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

### Option 2: Copy to Separate Arcflow Repository (For Creating PR)

### Option 2: Copy to Separate Arcflow Repository (For Creating PR)

If you want to create a PR in the official arcflow repository:

```bash
# In your local environment with access to arcflow repo:
cd /path/to/arcflow
git checkout -b copilot/add-creator-records

# Copy the modified files
cp /path/to/arcuit/arcflow-phase1/arcflow/main.py arcflow/main.py
cp /path/to/arcuit/arcflow-phase1/traject_config_creators.rb .
cp /path/to/arcuit/arcflow-phase1/CREATOR_RECORDS_DESIGN.md .
cp /path/to/arcuit/arcflow-phase1/PR_SUMMARY.md .
cp /path/to/arcuit/arcflow-phase1/README.md .
cp /path/to/arcuit/arcflow-phase1/.github/copilot-instructions.md .github/

git add -A
git commit -m "Add standalone creator records extraction and indexing pipeline"
git push -u origin copilot/add-creator-records

# Then create PR via GitHub UI using PR_SUMMARY.md as description
```

**Alternative: Create a patch file**

```bash
cd /path/to/arcuit/arcflow-phase1

# Create a patch file comparing against main branch
git diff c2486e4..HEAD > ../arcflow-phase1-changes.patch

# Then in arcflow repo:
cd /path/to/arcflow
git checkout -b copilot/add-creator-records
git apply /path/to/arcflow-phase1-changes.patch
```

---

## Key Files

### Implementation
- **`arcflow/main.py`** - Core code with creator agent processing methods
- **`traject_config_eac_cpf.rb`** - Solr indexing configuration for creator EAC-CPF XML

### Documentation
- **`CREATOR_RECORDS_DESIGN.md`** - Comprehensive design document
- **`PR_SUMMARY.md`** - Complete PR description (use for GitHub PR)
- **`README.md`** - Updated with creator records usage instructions
- **`.github/copilot-instructions.md`** - Architecture documentation

## Changes Summary

### New Methods in `arcflow/main.py`

1. **`get_all_agents(agent_types, modified_since, indent_size)`**
   - Fetches all agents from ArchivesSpace
   - Returns set of unique agent URIs
   - Lines: ~651-705

2. **`task_agent(agent_uri, agents_dir, repo_id, indent_size)`**
   - Processes individual agent into EAC-CPF XML document
   - Extracts bioghist, dates, relationships
   - Only processes agents with biographical notes
   - Lines: ~708-774

3. **`process_creators(agents_dir, modified_since, agent_uri, indent_size)`**
   - Main orchestration method for agent processing
   - Processes agents in parallel
   - Lines: ~893-946

### Workflow Integration

Added to `update_eads()` method after PDF processing (around line 492):
- Calls `process_creators()` to process all agents
- Generates EAC-CPF XML files in `public/xml/agents/` directory
- Collection linking handled via Solr using persistent_id field

## Testing

⭐ **See `TESTING.md` for comprehensive testing instructions!**

The testing guide includes:
- Step-by-step instructions for migrating a single creator record
- Command-line Solr queries with curl
- Browser-based Solr query examples
- Expected output and troubleshooting

### Quick Test

After applying changes to arcflow:

1. **Run ArcFlow**:
   ```bash
   python -m arcflow.main [options]
   ```

2. **Check Output**:
   ```bash
   ls -lh public/xml/agents/creator_*.xml
   ```

3. **Index to Solr**:
   ```bash
   bundle exec traject -u $SOLR_URL -i xml \
     -c traject_config_eac_cpf.rb public/xml/agents/*.xml
   ```

4. **Query Solr** (command line):
   ```bash
   curl "http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&rows=5&wt=xml" | jq '.'
   ```

5. **Query Solr** (browser):
   ```
   http://localhost:8983/solr/blacklight-core/select?q=*:*&fq=is_creator:true&wt=xml&indent=true
   ```

For detailed testing procedures including how to test a single creator record and all query options, see **`TESTING.md`**.

## Next Steps

1. Copy these changes to the arcflow repository
2. Create PR in arcflow using `PR_SUMMARY.md` as description
3. Test with real ArchivesSpace data
4. Once merged, begin Phase 2 in arcuit repository (search exclusion)

## Questions?

See `CREATOR_RECORDS_DESIGN.md` for detailed design rationale and `PR_SUMMARY.md` for PR description.

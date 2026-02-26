# Exact Interactive Rebase Script for index_creators

This document provides the **exact commands** you need to paste into your git rebase editor to consolidate the 42 commits into 5 logical commits.

## Step 1: Start the Interactive Rebase

```bash
git rebase -i 5adbf40
```

## Step 2: Replace the Editor Content

When the editor opens, you'll see 42 "pick" commands. **Replace the entire content** with the script below:

```bash
# ============================================================
# COMMIT 1: Add biographical information to EAD exports
# ============================================================
pick 8b8864d # Add creator biographical information to EAD XML exports
squash 23ef7f6 # Add Copilot agent onboarding documentation
squash a6aeb80 # Fix bioghist element nesting structure
squash f0fd704 # fix: remove form of id that is no longer used

# ============================================================
# COMMIT 2: Add complete creator/agent indexing system
# ============================================================
pick a24d4ad # feat(arclight#29): Add creator records and automatic indexing
squash 8a96e8d # fix: remove method to test a single creator record
squash 604f68c # refactor: move variable declarations into method body
squash 38c3612 # remove unwanted documentation
squash 4912ddc # refactor: revert to PIPE for sterr for consistency
squash 6014dd1 # fix: spacing
squash 5dbe81e # fix: duplicate line
squash 1c63cae # fix: remove unused method
squash 849098e # fix: add time in case it isn't loaded when traject runs
squash fef9307 # Update arcflow/main.py
squash ec3c961 # Update arcflow/main.py
squash a043c9d # fix: remove hardcoded directory from local implemantaiton
squash a407d72 # fix: use updated example
squash 8ec0445 # Update README.md
squash 202a532 # Update traject_config_eac_cpf.rb
fixup deb325e # Initial plan # empty (DROP - no message)
squash 32d923e # fix: use dynamic mappings for ArcLight Solr fields
squash 628975e # Ensure that extra traject config is proccessed
squash ae77c98 # add extra traject config with extend
fixup 107e43d # Initial plan # empty (DROP - no message)
squash b542367 # Add check=True to subprocess.run and handle exception properly
squash 092d1be # Move success log to else block for clarity
squash 924ea47 # Revert to original error handling without check=True

# ============================================================
# COMMIT 3: Optimize with Solr-based filtering
# ============================================================
pick 0fac5e0 # feat: use ASpace solr to filter creator agents
squash 05239d1 # Use consistent eac: namespace prefix in all XPath queries
squash 5d2588e # Refactor dates XPath for improved readability
fixup 4923eb2 # Initial plan # empty (DROP - no message)
squash 093d936 # Add agent filtering to exclude system users and donors
squash f264373 # Remove redundant software agent filter - already excluded by endpoint selection

# ============================================================
# COMMIT 4: Add creator deletion logic and config improvements
# ============================================================
pick 989d0f4 # Add delete logic for creators and refactor
squash b99cf79 # Refactor deletion into more abstract methods and add delete logic for creators
squash 3b3d1c7 # fix: ignore last update param with --force-update
squash 5569acc # fix: convert to string and use shell for wildcard expansion
squash 5dd4f4b # fix: check ead_id exists before accessing (#15)
squash e326983 # Reorder traject config discovery to follow collection records pattern (#14)
squash cd1f94d # Preserve html markup
squash e092b10 # Update README.md

# ============================================================
# COMMIT 5: Replace non-deterministic IDs with skip logic
# ============================================================
pick e1645c2 # Replace non-deterministic fallback IDs with explicit skip logic in EAC-CPF indexing (#13)

# Rebase 5adbf40..e1645c2 onto 5adbf40 (42 commands)
```

## Step 3: Save and Close the Editor

After saving, git will start applying commits. You'll be prompted to edit commit messages for each "pick" commit.

## Step 4: Commit Messages to Use

### COMMIT 1: Bioghist Feature
```
feat: Add creator biographical information to EAD XML exports

Extract bioghist from ArchivesSpace agent records and inject into EAD:
- Retrieve bioghist notes from linked agent records
- Inject structured XML into EAD <archdesc> section
- Preserve HTML markup for proper rendering in ArcLight
- Fix bioghist element nesting per EAD schema requirements
- Add Copilot agent onboarding documentation

This enables archival collections to display biographical and historical
context about creators directly in the finding aid.
```

### COMMIT 2: Creator Indexing System
```
feat: Add creator/agent indexing system for ArcLight

Implement complete ETL pipeline for ArchivesSpace agents:
- Extract all agent records via ArchivesSpace API
- Generate EAC-CPF XML documents for each agent
- Auto-discover and configure traject indexing
- Batch index to Solr (100 files per call for performance)
- Support multiple processing modes (agents-only, collections-only, both)
- Add 11 new Solr fields for agent metadata
- Include 271-line traject config for EAC-CPF → Solr mapping

Key features:
- Parallel to existing collection record indexing
- Dynamic Solr field mapping for ArcLight compatibility
- Robust error handling and logging
- Configurable traject config discovery paths

This allows ArcLight to provide dedicated agent/creator pages with
full biographical information, related collections, and authority control.
```

### COMMIT 3: Solr-based Agent Filtering
```
feat: Optimize agent filtering with ArchivesSpace Solr

Replace per-agent API calls with single Solr query for better performance:
- Query ArchivesSpace Solr to filter agents in bulk
- Exclude system users (publish=false)
- Exclude donors (linked_agent_role includes "dnr")
- Exclude software agents (agent_type="agent_software")
- Use consistent EAC namespace prefixes in XPath queries
- Refactor dates extraction for improved readability

Performance improvement: O(n) API calls → O(1) Solr query
Reduces processing time from minutes to seconds for large repositories.
```

### COMMIT 4: Creator Deletion and Config Discovery
```
feat: Add creator deletion logic with directory structure refactor

Implement complete CRUD operations for creator records:
- Add delete operations for creator records (mirrors resource deletion)
- Refactor deletion into abstract methods for code reusability
- Reorganize XML directory structure: resources/ and agents/ subdirectories
- Fix --force-update to properly delete all creator records before regenerating
- Handle edge cases: missing ead_id, path wildcards, shell expansion

Improve traject config discovery following ArcLight pattern:
- Reorder search paths to prioritize user-controlled configs
- Preserve HTML markup in traject processing
- Add clear logging for config source discovery

This enables incremental updates and proper cleanup of deleted agents.
```

### COMMIT 5: Non-deterministic ID Fix (Keep as-is)
```
Replace non-deterministic fallback IDs with explicit skip logic in EAC-CPF indexing (#13)

Skip indexing records without valid IDs instead of generating non-deterministic fallbacks
```

## Step 5: Complete the Rebase

After entering all commit messages, the rebase will complete. Then:

```bash
# Verify the result
git log --oneline -6

# Should show 5 new commits plus the base commit 5adbf40

# Force push (with lease for safety)
git push --force-with-lease
```

## Notes

- **fixup vs squash**: Use `fixup` for "Initial plan" commits (drops their messages), use `squash` for all others (combines messages)
- **Order matters**: Commits are listed in the exact order they'll be applied
- **Commit 3 reordered**: The agent filtering commits are reordered to put `0fac5e0` first (the main Solr feature), with supporting commits squashed into it
- **All 42 commits accounted for**: Every commit from the original list is included exactly once

## Verification

After the rebase, verify:
1. **Commit count**: `git log 5adbf40..HEAD --oneline | wc -l` should return `5`
2. **No batch processing commits**: `git log --oneline` should NOT show 0be8c89, ae41cef, or 5adbf40
3. **All changes preserved**: `git diff 5adbf40..HEAD` should match `git diff 5adbf40..e1645c2` (before rebase)

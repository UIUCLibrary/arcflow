# Solution: Correct Rebase Command for Creator Indexing Feature

## Problem

When running `git rebase -i 8b8864d^`, you get 45 commits including 3 unrelated batch processing commits at the beginning:

```
pick 0be8c89 fix: solve issue with file paths
pick ae41cef fix: added batch processing
pick 5adbf40 fix: reordered tasks for processing PDFs
pick 8b8864d Add creator biographical information to EAD XML exports
... (42 more commits)
```

These first 3 commits are NOT part of the creator indexing feature and should not be rebased.

## Root Cause

The bioghist feature (`8b8864d`) was developed on a separate branch from commit `30a4fef`. The 3 batch processing commits were added directly to the index_creators branch. Since `8b8864d^` points to `30a4fef`, rebasing from there includes everything after `30a4fef`, which includes those 3 unrelated commits.

## Solution

Use the correct rebase command:

```bash
git rebase -i 5adbf40
```

This will show exactly 42 commits in the rebase editor (merge commits are excluded):

```
pick 8b8864d # Add creator biographical information to EAD XML exports
pick 23ef7f6 # Add Copilot agent onboarding documentation
... (40 more commits)
pick e1645c2 # Replace non-deterministic fallback IDs with explicit skip logic in EAC-CPF indexing (#13)

# Rebase 5adbf40..e1645c2 onto 5adbf40 (42 commands)
```

## Why This Works

- `5adbf40` is the last batch processing commit before the creator feature
- Rebasing from `5adbf40` starts AFTER that commit
- Only creator feature commits (from `8b8864d` onwards) are included
- The 3 batch processing commits remain unchanged

## Complete Workflow

1. **Create a backup** (highly recommended):
   ```bash
   git branch index_creators_backup
   ```

2. **Start the interactive rebase**:
   ```bash
   git rebase -i 5adbf40
   ```

3. **In the editor**, consolidate the 42 commits into 4-6 logical commits:
   - COMMIT 1: Bioghist feature (squash 8b8864d, 23ef7f6, a6aeb80, f0fd704)
   - COMMIT 2: Creator indexing (squash main feature commits)
   - COMMIT 3: Agent filtering (squash filtering and optimization)
   - COMMIT 4: Creator deletion (squash deletion logic)
   - COMMIT 5: ID skip logic (keep e1645c2 as-is)

4. **Test thoroughly** after rebasing

5. **Force push** (with lease for safety):
   ```bash
   git push --force-with-lease
   ```

## What Gets Excluded

**41 commits** are excluded from the rebase:
- 38 commits from May-Dec 2025 (bulk import, classification data, etc.)
- 3 batch processing commits from Jan 2026 (`0be8c89`, `ae41cef`, `5adbf40`)

**42 commits** are included in the rebase:
- All non-merge commits from `8b8864d` onwards
- Merge commits are automatically excluded by git during interactive rebase

## Reference

See `REBASE_ANALYSIS.md` for the complete analysis and detailed consolidation plan.

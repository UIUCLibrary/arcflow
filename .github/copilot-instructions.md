# Copilot Agent Instructions for arcflow

This file provides guidance for GitHub Copilot agents working on the arcflow repository.

## Commit Style

When making changes to this repository, use **granular, single-purpose commits**:

### Guidelines

- **One commit per logical change** - Each commit should do one thing and do it well
- **Separate refactoring from features** - Don't mix code restructuring with new functionality
- **Clear, descriptive messages** - Explain what the commit does and why
- **Include imports with usage** - Add necessary imports in the same commit where they're used, not as separate commits

### Examples

Good commit sequence:
```
1. Refactor XML injection logic for extensibility
2. Add linked_agents to resolve parameter
3. Add get_creator_bioghist method
   (includes import of xml.sax.saxutils.escape used in the method)
4. Integrate bioghist into XML injection
5. Update comment to reflect new behavior
```

Bad commit sequences:

Too dense:
```
1. Add creator biographical information to EAD XML exports
   (combines refactoring, new imports, new methods, and integration)
```

Too granular:
```
1. Import xml.sax.saxutils.escape
2. Add get_creator_bioghist method that uses xml.sax.saxutils.escape
   (import should have been included in this commit)
```

### Commit Message Format

- **First line**: Clear, concise summary (50-72 characters)
- **Body** (optional): Bullet points explaining the changes
- **Keep it focused**: If you need many bullets, consider splitting into multiple commits

### Why This Matters

- Makes code review easier
- Helps understand the progression of changes
- Easier to revert specific changes if needed
- Clear history for future maintainers

---

## XML Content Handling in EAD Pipeline

When injecting content into EAD XML files, distinguish between plain text and structured XML:

### Escaping Strategy

- **Plain text labels** (recordgroup, subgroup): Use `xml_escape()` to escape special characters (`&`, `<`, `>`)
  - These are simple strings that may contain characters that break XML syntax
  - Example: `xml_escape(rg_label)` → converts `"Group & Co"` to `"Group &amp; Co"`

- **Structured EAD XML content** (bioghist, scopecontent): Do NOT escape
  - Content from ArchivesSpace already contains valid EAD XML markup (`<emph>`, `<title>`, etc.)
  - These are legitimate XML nodes that must be preserved
  - Escaping would convert them to literal text: `<emph>` → `&lt;emph&gt;`
  - Example: Pass through as-is: `f'<p>{subnote["content"]}</p>'`

### Why This Matters

The Traject indexing pipeline and ArcLight display rely on proper XML structure:
1. Traject's `.to_html` converts XML nodes to HTML
2. ArcLight's `render_html_tags` processes the HTML for display
3. If XML nodes are escaped (treated as text), they can't be processed and appear as raw markup

### Pattern for Future Fields

When adding new EAD fields to the pipeline:
1. Determine if content is plain text or structured XML
2. Apply escaping only to plain text
3. Pass structured XML through unchanged
4. Document the decision in code comments

---

## Adding More Instructions

To add additional instructions to this file:

1. Add a new section with a clear heading (e.g., `## Testing Strategy`, `## Code Style`)
2. Keep instructions concise and actionable
3. Use examples where helpful
4. Maintain the simple, scannable format

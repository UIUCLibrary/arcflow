# Copilot Agent Instructions for arcflow

This file provides guidance for GitHub Copilot agents working on the arcflow repository.

## Commit Style

When making changes to this repository, use **granular, single-purpose commits**:

### Guidelines

- **One commit per logical change** - Each commit should do one thing and do it well
- **Separate refactoring from features** - Don't mix code restructuring with new functionality
- **Clear, descriptive messages** - Explain what the commit does and why

### Examples

Good commit sequence:
```
1. Refactor XML injection logic for extensibility
2. Add linked_agents to resolve parameter
3. Import xml.sax.saxutils.escape for proper XML escaping
4. Add get_creator_bioghist method
5. Integrate bioghist into XML injection
6. Update comment to reflect new behavior
```

Bad commit (too dense):
```
1. Add creator biographical information to EAD XML exports
   (combines refactoring, new imports, new methods, and integration)
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

## Adding More Instructions

To add additional instructions to this file:

1. Add a new section with a clear heading (e.g., `## Testing Strategy`, `## Code Style`)
2. Keep instructions concise and actionable
3. Use examples where helpful
4. Maintain the simple, scannable format

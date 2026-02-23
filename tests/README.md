# ArcFlow Test Suite

This directory contains tests for the ArcFlow project.

## Test Structure

- `unit/` - Fast unit tests for individual components
- `conftest.py` - Shared test fixtures and configuration

## Running Tests

```bash
# Run all tests
pytest

# Run only unit tests
pytest tests/unit

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/unit/test_traject_smoke.py
```

## Traject Smoke Tests

Tests in `tests/unit/test_traject_smoke.py` verify traject configuration without requiring Solr.

### What They Test
- Ruby syntax validity of traject configs
- Traject can load and parse configs
- XML transformation logic (without indexing)

### Setup Requirements
- Ruby 3.1+
- Bundler
- Run `bundle install` to install traject gem

### Performance
- First run: ~60 seconds (includes gem install)
- Cached runs: ~40 seconds (gems cached)
- Still fast enough for CI/agent iteration

### Skipping
These tests skip gracefully if traject config doesn't exist yet.

## Writing Tests

When adding new tests:
- Use pytest fixtures from `conftest.py`
- Keep unit tests fast (< 1 second each)
- Add integration tests to appropriate subdirectories
- Use `pytest.skip()` for tests that require optional dependencies

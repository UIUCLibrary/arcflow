# Testing Documentation

## Overview

The arcflow repository includes multiple tiers of tests:

- **Tier 1: Unit Tests** - Fast tests including traject smoke tests (~40-60 seconds)
- **Tier 2: Integration Tests** - Full integration tests with Solr and other services (~10 minutes)

## Traject Smoke Tests

Tier 1 includes traject smoke tests that verify Ruby/traject functionality without Solr.

### What Gets Tested
- ✅ Traject config has valid Ruby syntax
- ✅ Traject can load configuration
- ✅ XML transformation works (without indexing)

### Performance
- First run: ~60 seconds (includes gem installation)
- Subsequent runs: ~40 seconds (gems cached by bundler)
- Still fast enough for agent iteration loops!

### Requirements
- Ruby 3.1+
- Bundler
- Traject gem (installed via `bundle install`)

### Why This Matters
Catches 80% of traject issues immediately, before waiting 10 minutes for full integration tests with Solr.

### Skipping
Tests automatically skip if traject config doesn't exist yet, so they won't block development.

## Running Tests

### Run all unit tests (default)
```bash
pytest tests/ -v
```

### Run only traject smoke tests
```bash
pytest tests/unit/test_traject_smoke.py -v
```

### Run all tests including integration tests
```bash
pytest tests/ -v -m ""
```

### Run with coverage
```bash
pytest tests/ -v --cov=arcflow
```

## Test Markers

Tests are marked with pytest markers to control execution:

- `unit` - Fast unit tests including traject smoke tests
- `integration` - Integration tests requiring external services
- `slow` - Tests taking >10 seconds

By default, integration tests are excluded. To run all tests:
```bash
pytest tests/ -v -m ""
```

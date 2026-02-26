# Testing and CI/CD Infrastructure Plan for ArcFlow

This document outlines a phased approach to implementing automated testing and CI/CD infrastructure for the arcflow repository. The goal is two-fold:
1. **Test Coverage**: Ensure code quality and catch regressions
2. **Agent Testing Environment**: Enable Copilot agents to test PRs against infrastructure and iterate without manual intervention on live systems

## Overview

The plan is divided into 6 phases, ordered by complexity and ROI (Return on Investment). Early phases provide quick wins and enable future development, while later phases add polish and production-grade features.

---

## Phase 1: Foundation - Basic Testing Infrastructure

**Effort**: 1-2 days  
**ROI**: ⭐⭐⭐⭐⭐ High  
**Priority**: Critical

### Goals
Establish the minimum viable testing infrastructure that enables continuous integration and provides immediate value.

### Tasks

#### 1.1 Set up pytest framework
- Install pytest and pytest-cov as development dependencies
- Create `tests/` directory structure:
  ```
  tests/
  ├── __init__.py
  ├── conftest.py          # Shared fixtures
  ├── test_utils.py        # Utility function tests
  └── fixtures/            # Mock data files
      ├── mock_aspace_responses.json
      └── sample_ead.xml
  ```
- Create `conftest.py` with base fixtures for mocking

#### 1.2 GitHub Actions CI Workflow
- Create `.github/workflows/ci.yml`:
  - Run on: push, pull_request
  - Test matrix: Python 3.8, 3.9, 3.10, 3.11
  - Steps: checkout, setup Python, install dependencies, run linters, run tests
  - Upload coverage reports to codecov.io

#### 1.3 Linting Configuration
- Add `flake8` or `pylint` to development dependencies
- Create `.flake8` or `pylintrc` configuration
- Enforce basic style rules (line length, imports, etc.)
- Add linting step to CI workflow

#### 1.4 Initial Test Suite
Write first 5-10 tests to validate infrastructure:
- `test_xml_escape()` - Test XML escaping utility
- `test_extract_labels()` - Test classification label extraction
- `test_config_file_loading()` - Test YAML configuration parsing
- `test_pid_file_creation()` - Test process locking
- `test_get_ead_id_from_file()` - Test EAD ID extraction

#### 1.5 Code Coverage Reporting
- Configure pytest-cov to generate coverage reports
- Add coverage badge to README.md
- Set minimum coverage threshold (start low, e.g., 30%, increase over time)

### Deliverables
- ✅ Tests run automatically on every PR
- ✅ Test failures block PR merges
- ✅ Basic code coverage visibility
- ✅ Linting catches style issues early

### Why This Matters
This phase provides **immediate feedback** for developers and agents. A failing test or lint check prevents broken code from being merged. This is the foundation for everything else.

---

## Phase 2: Core Logic Testing

**Effort**: 2-3 days  
**ROI**: ⭐⭐⭐⭐⭐ High  
**Priority**: High

### Goals
Test the critical business logic that defines arcflow's functionality, particularly the complex agent filtering and XML manipulation.

### Tasks

#### 2.1 Agent Filtering Tests
Test `is_target_agent()` and related logic:
- Test system user exclusion (is_user field)
- Test system-generated agent exclusion
- Test repository agent exclusion (is_repo_agent)
- Test donor-only agent exclusion
- Test creator role inclusion
- Test linked published records logic
- Test edge cases (multiple roles, missing fields)

#### 2.2 XML Manipulation Tests
- Test XML escaping vs. pass-through for structured content
- Test bioghist injection into EAD XML
- Test recordgroup/subgroup label injection
- Test XML parsing and DOM manipulation
- Test handling of malformed XML

#### 2.3 Configuration Handling Tests
- Test `.archivessnake.yml` parsing
- Test `.arcflow.yml` timestamp handling
- Test missing configuration file error handling
- Test invalid configuration format handling

#### 2.4 Timestamp and Modified-Since Logic
- Test `last_updated` timestamp comparison
- Test force-update mode bypassing timestamps
- Test modified_since parameter in API calls
- Test datetime parsing and timezone handling

#### 2.5 Mock ArchivesSpace Client
Create comprehensive mocks:
- Mock `ASnakeClient.authorize()`
- Mock repository queries
- Mock resource queries with resolve parameters
- Mock agent queries with filtering
- Mock EAC-CPF XML generation
- Mock error responses (401, 404, 500)

#### 2.6 File Management Tests
- Test `save_file()` with various XML content
- Test symlink creation and directory structure
- Test file deletion and cleanup
- Test handling of write permissions errors

### Deliverables
- ✅ Core business logic has >80% test coverage
- ✅ Agent filtering is thoroughly validated
- ✅ XML manipulation is safe and correct
- ✅ Configuration edge cases are handled

### Why This Matters
These are the functions most likely to have bugs and the hardest to test manually. Comprehensive tests here give confidence that arcflow's core logic is correct.

---

## Phase 3: Integration Testing

**Effort**: 3-4 days  
**ROI**: ⭐⭐⭐⭐ Medium-High  
**Priority**: Medium

### Goals
Test how components work together, including interactions with external systems (mocked or real).

### Tasks

#### 3.1 Mock Solr Server
- Use `responses` library or create test Solr HTTP mock
- Mock POST requests for document indexing
- Mock DELETE requests for document removal
- Mock query responses for verification
- Test error handling (Solr down, timeout, 400 errors)

#### 3.2 EAD Processing Workflow Tests
Test `update_eads()` end-to-end:
- Mock ArchivesSpace responses for repositories and resources
- Mock traject subprocess calls
- Verify XML files are created correctly
- Verify Solr indexing is called with correct parameters
- Test error handling (missing EAD, invalid XML)

#### 3.3 Creator Processing Workflow Tests
Test `process_creators()` end-to-end:
- Mock agent API responses
- Mock traject subprocess calls
- Verify EAC-CPF XML files are generated
- Verify Solr indexing is called
- Test `--agents-only` and `--skip-creator-indexing` modes

#### 3.4 Subprocess Call Tests
Mock and verify:
- `traject` command invocations
- `bundle exec` command invocations
- `bundle show` for finding gems
- Handle subprocess errors and non-zero exit codes

#### 3.5 Parallel Processing Tests
- Test ThreadPool with mocked tasks
- Test error handling in parallel tasks
- Test graceful degradation (some tasks fail, others succeed)
- Test resource cleanup after parallel execution

#### 3.6 Traject Config Discovery Tests
Test `find_traject_config()`:
- Mock `--arcuit-dir` parameter
- Mock `bundle show arcuit` output
- Test fallback to example config
- Test error when no config found

### Deliverables
- ✅ Multi-component workflows are tested
- ✅ External system interactions are verified
- ✅ Error propagation is correct
- ✅ Parallel processing is reliable

### Why This Matters
Integration tests catch issues that unit tests miss, like incorrect API calls or mismatched data formats between components.

---

## Phase 4: End-to-End Testing

**Effort**: 4-5 days  
**ROI**: ⭐⭐⭐ Medium  
**Priority**: Medium

### Goals
Test arcflow in a realistic environment with real instances of ArchivesSpace, Solr, and ArcLight.

### Tasks

#### 4.1 Docker Compose Test Environment
Create `docker-compose.test.yml`:
- ArchivesSpace container (pre-populated with test data)
- Solr container (pre-configured with ArcLight schema)
- ArcLight container (optional, for full stack testing)
- Test data initialization scripts

#### 4.2 Full Workflow Tests
Test `python -m arcflow.main` with real services:
- Test initial run with empty Solr
- Test incremental update (modified_since)
- Test force-update mode (full reindex)
- Test agents-only mode
- Test collections-only mode

#### 4.3 Data Validation Tests
After test runs:
- Verify Solr document counts
- Verify XML file generation
- Verify PDF file generation
- Verify symlink structure
- Verify `.arcflow.yml` timestamp updates

#### 4.4 Performance Benchmarking
- Measure indexing throughput (collections/minute)
- Measure agent processing throughput
- Measure memory usage
- Identify bottlenecks for optimization

#### 4.5 Regression Test Suite
Create test fixtures for known issues:
- Test previously reported bugs
- Test edge cases discovered in production
- Test compatibility with ArchivesSpace versions

### Deliverables
- ✅ One-command test environment setup
- ✅ Full workflow validation
- ✅ Agents can test PRs against real infrastructure
- ✅ Performance baselines established

### Why This Matters
End-to-end tests give the highest confidence that arcflow works in production. The Docker environment enables agents to test PRs without needing manual setup.

---

## Phase 5: Advanced CI/CD

**Effort**: 2-3 days  
**ROI**: ⭐⭐⭐ Medium-Low  
**Priority**: Low

### Goals
Add development tools and automation to improve code quality and developer experience.

### Tasks

#### 5.1 Pre-commit Hooks
- Install `pre-commit` framework
- Configure hooks:
  - Run linters (flake8, pylint)
  - Run formatters (black, isort)
  - Check for secrets (detect-secrets)
  - Check YAML/JSON validity
  - Check for large files

#### 5.2 Type Checking
- Add type hints to function signatures
- Configure `mypy` for static type checking
- Add mypy to CI workflow
- Gradually increase type coverage

#### 5.3 Security Scanning
- Add `bandit` for Python security issues
- Add `safety` for dependency vulnerability scanning
- Add security checks to CI workflow
- Configure issue notifications

#### 5.4 Dependency Management
- Configure Dependabot for automated updates
- Set update schedule (weekly)
- Configure auto-merge for minor/patch updates
- Test dependency updates in CI before merging

#### 5.5 Test Artifacts and Reporting
- Generate HTML coverage reports
- Upload test results in JUnit XML format
- Create test summary comments on PRs
- Archive logs and artifacts for debugging

#### 5.6 Developer Documentation
- Document how to run tests locally
- Document how to add new tests
- Document how to use Docker test environment
- Create contributing guidelines for testing

### Deliverables
- ✅ Pre-commit hooks prevent common mistakes
- ✅ Type safety reduces runtime errors
- ✅ Security issues are caught early
- ✅ Dependencies stay up-to-date automatically

### Why This Matters
These tools catch issues before they reach CI, saving time and making development smoother. However, they're lower priority than functional testing.

---

## Phase 6: Production-Ready Enhancements

**Effort**: 3-4 days  
**ROI**: ⭐⭐ Low  
**Priority**: Low

### Goals
Add polish and production-grade features for mature CI/CD pipeline.

### Tasks

#### 6.1 Smoke Tests for Deployments
- Create minimal test suite for post-deployment validation
- Test ArchivesSpace connectivity
- Test Solr connectivity
- Test file system permissions
- Run in production after deployments

#### 6.2 Test Data Generation
- Create utilities to generate synthetic test data
- Generate ArchivesSpace test fixtures
- Generate EAD/EAC-CPF test files
- Support various edge cases and scenarios

#### 6.3 Mutation Testing
- Install `mutmut` for mutation testing
- Generate mutants from source code
- Verify tests catch introduced bugs
- Identify weak test coverage areas

#### 6.4 Performance Regression Tests
- Establish performance baselines
- Track indexing throughput over time
- Alert on performance degradation
- Optimize slow operations

#### 6.5 Load Testing
- Test parallel processing with high volumes
- Test ThreadPool under load
- Test memory usage with large datasets
- Identify concurrency issues

#### 6.6 External Monitoring Integration
- Send test results to monitoring systems
- Create dashboards for test trends
- Alert on test failures
- Track coverage trends over time

### Deliverables
- ✅ Production deployments are validated automatically
- ✅ Test quality is measured objectively
- ✅ Performance regressions are caught
- ✅ Load handling is verified

### Why This Matters
These are "nice-to-have" features that add polish but aren't critical for basic testing and CI/CD. They become valuable as the project matures.

---

## Recommended Implementation Order

For **maximum ROI with minimal effort**, implement in this order:

1. **Start with Phase 1** (Foundation) - This is essential and provides immediate value
2. **Move to Phase 2** (Core Logic) - Tests the most critical functionality
3. **Skip to Phase 4.1** (Docker Compose) - Gives agents a test environment quickly
4. **Complete Phase 3** (Integration) - Now that you have environment + core tests
5. **Add Phase 4.2-4.5** (E2E Tests) - Full validation
6. **Add Phase 5** (Advanced) - As time permits
7. **Add Phase 6** (Production) - Only if needed

## Success Metrics

### Short-term (After Phase 1-2)
- ✅ CI runs on every PR
- ✅ Core logic has >60% test coverage
- ✅ Agents get immediate feedback on test failures

### Medium-term (After Phase 3-4)
- ✅ Integration tests cover major workflows
- ✅ Docker environment enables full testing
- ✅ Test coverage >75%

### Long-term (After Phase 5-6)
- ✅ Code quality tools prevent issues proactively
- ✅ Performance is monitored and stable
- ✅ Test coverage >85%

---

## Reference: Previous Conversation

This plan is based on **PR #19** which laid out initial ideas for testing infrastructure. That PR is currently open but had no actual implementation yet.

**PR #19 Link**: https://github.com/UIUCLibrary/arcflow/pull/19

This document expands on those ideas with detailed phasing, ROI analysis, and specific implementation tasks.

---

## Getting Started

To begin implementation, start with Phase 1:

```bash
# Install test dependencies
pip install pytest pytest-cov flake8 responses

# Create test directory
mkdir -p tests/fixtures

# Create first test file
# tests/test_utils.py

# Run tests
pytest

# Run with coverage
pytest --cov=arcflow --cov-report=html
```

Then create `.github/workflows/ci.yml` to run tests in CI.

---

## Questions or Feedback?

This plan is designed to be flexible. Phases can be reordered, split, or combined based on:
- Available development time
- Specific pain points in current workflow
- Agent testing needs
- Production requirements

The key is to start with Phase 1 (foundation) and build incrementally from there.

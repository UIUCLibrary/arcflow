# ArcFlow Tests

Comprehensive test suite for the arcflow repository to accelerate AI agent development workflows.

## Running Tests

### Run All Tests

```bash
pytest
```

### Run Specific Test Files

```bash
pytest tests/test_file_operations.py
pytest tests/test_ead_operations.py
```

### Run Tests by Marker

```bash
# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration

# Skip slow tests
pytest -m "not slow"
```

### Run with Coverage Report

```bash
# Terminal report
pytest --cov=arcflow --cov-report=term-missing

# HTML report (opens in browser)
pytest --cov=arcflow --cov-report=html
open htmlcov/index.html
```

### Run Specific Test Functions

```bash
pytest tests/test_utilities.py::test_get_repo_id
pytest tests/test_file_operations.py::TestSaveFile::test_save_file_success
```

## Test Organization

### Infrastructure Files

- **`conftest.py`** - Shared pytest fixtures (mock clients, temp directories, sample data)
- **`README.md`** - This file
- **`pytest.ini`** - Test configuration (in repository root)

### Test Files

1. **`test_file_operations.py`** - File I/O operations
   - `save_file()` - Writing files with error handling
   - `create_symlink()` - Creating symbolic links
   - `get_ead_from_symlink()` - Extracting EAD IDs from symlinks

2. **`test_subprocess_fixes.py`** - Subprocess and shell operations
   - `glob.glob()` wildcard expansion in batch file processing

3. **`test_ead_operations.py`** - EAD XML operations
   - `get_ead_id_from_file()` - Extracting EAD IDs from XML
   - Dots-to-dashes sanitization in EAD IDs

4. **`test_batching.py`** - Batch processing logic
   - Batch size calculations
   - Edge cases (empty lists, single items, exact multiples)

5. **`test_config_discovery.py`** - Configuration file discovery
   - `find_traject_config()` - Multi-path search logic
   - Priority order: arcuit_dir → bundle show → fallback

6. **`test_xml_manipulation.py`** - XML content handling
   - `xml_escape()` for plain text labels
   - `get_creator_bioghist()` - Biographical note extraction
   - Proper handling of structured XML vs plain text

7. **`test_utilities.py`** - Simple helper functions
   - `get_repo_id()` - Repository ID extraction
   - Path construction utilities

8. **`test_agent_filtering.py`** - **STUB ONLY**
   - All tests intentionally skipped
   - Documents need for refactoring before testing
   - See file for details on complexity issues

## Writing New Tests

### Use Shared Fixtures

```python
def test_example(temp_dir, mock_asnake_client, sample_agent):
    """Use fixtures from conftest.py."""
    # temp_dir: Temporary directory for file operations
    # mock_asnake_client: Mock ArchivesSpace client
    # sample_agent: Sample agent data structure
    pass
```

### Mark Your Tests

```python
import pytest

@pytest.mark.unit
def test_simple_function():
    """Unit test that doesn't need external dependencies."""
    pass

@pytest.mark.integration
def test_with_mocked_api():
    """Integration test with mocked external services."""
    pass

@pytest.mark.slow
def test_long_running():
    """Test that takes significant time."""
    pass
```

### Test Structure

Follow the Arrange-Act-Assert pattern:

```python
def test_example():
    # Arrange: Set up test data
    input_data = "test"
    
    # Act: Execute the function under test
    result = function_to_test(input_data)
    
    # Assert: Verify the results
    assert result == expected_value
```

### Mocking External Dependencies

```python
from unittest.mock import Mock, patch

def test_with_mock():
    # Mock ArchivesSpace API calls
    with patch('arcflow.main.ASnakeClient') as mock_client:
        mock_client.return_value.get.return_value.json.return_value = {}
        # Test code here
```

## Test Coverage Goals

- **Target**: 80%+ code coverage for new features
- **Focus**: Test critical paths and edge cases
- **Skip**: Complex filtering logic that needs refactoring (see `test_agent_filtering.py`)

## Continuous Integration

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests
- Python versions: 3.9, 3.10, 3.11

See `.github/workflows/test.yml` for CI configuration.

## Dependencies

Testing requires:
- `pytest>=7.0.0` - Test framework
- `pytest-cov>=4.0.0` - Coverage reporting
- `pytest-mock>=3.10.0` - Mocking utilities

Install with:
```bash
pip install -r requirements.txt
```

## Troubleshooting

### Tests Fail to Import arcflow

Make sure you're running from the repository root:
```bash
cd /path/to/arcflow
pytest
```

### Coverage Report Not Generated

Ensure pytest-cov is installed:
```bash
pip install pytest-cov
```

### Mock Client Issues

If tests fail with authentication errors, ensure you're using the `mock_asnake_client` fixture:
```python
def test_example(mock_asnake_client):
    # Use mock_asnake_client instead of real client
    pass
```

## Contributing Tests

When adding new functionality:

1. Write tests first (TDD approach recommended)
2. Use existing fixtures from `conftest.py`
3. Add new fixtures if needed (keep them reusable)
4. Mark tests appropriately (`@pytest.mark.unit`, etc.)
5. Run tests locally before committing
6. Ensure coverage doesn't decrease

## Notes on Test Philosophy

- **Minimal mocking**: Only mock external dependencies (API calls, file system when appropriate)
- **Real logic testing**: Test actual business logic, not mocks
- **Edge cases matter**: Test boundary conditions, empty inputs, error paths
- **Fast feedback**: Most tests should run in milliseconds
- **Clear failures**: Test names and assertions should make failures obvious

## Known Limitations

- **Agent filtering**: Logic too complex to test effectively in current state (see `test_agent_filtering.py`)
- **Subprocess tests**: May not work on non-Unix systems
- **Traject integration**: Requires Ruby/bundler setup (mocked in tests)

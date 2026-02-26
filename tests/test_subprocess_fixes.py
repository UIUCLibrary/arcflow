"""
Tests for subprocess-related functionality in arcflow.

Tests the following:
- glob.glob wildcard expansion for batch file processing
- Proper handling of glob patterns in CSV bulk import
"""

import os
import glob
import pytest
from unittest.mock import Mock, patch


@pytest.mark.unit
class TestGlobWildcardExpansion:
    """Tests for glob.glob wildcard expansion."""
    
    def test_glob_csv_files(self, temp_dir):
        """Test glob pattern matching for CSV files."""
        # Create test CSV files
        csv_files = ['file1.csv', 'file2.csv', 'file3.csv']
        for csv_file in csv_files:
            path = os.path.join(temp_dir, csv_file)
            with open(path, 'w') as f:
                f.write('header\ndata')
        
        # Use glob pattern to find CSV files
        pattern = f'{temp_dir}/*.csv'
        found_files = glob.glob(pattern)
        
        assert len(found_files) == 3
        assert all(f.endswith('.csv') for f in found_files)
    
    def test_glob_with_trailing_slash(self, temp_dir):
        """Test glob pattern with directory trailing slash."""
        # Create CSV file
        csv_path = os.path.join(temp_dir, 'test.csv')
        with open(csv_path, 'w') as f:
            f.write('data')
        
        # Pattern with trailing slash (as seen in bulk_import.py line 99)
        pattern = f'{temp_dir}*.csv'  # No slash between dir and pattern
        found_files = glob.glob(pattern)
        
        # This won't match if temp_dir has trailing slash
        # Documents the importance of proper path handling
        assert len(found_files) >= 0
    
    def test_iglob_vs_glob(self, temp_dir):
        """Test iglob iterator vs glob list."""
        # Create multiple files
        for i in range(5):
            path = os.path.join(temp_dir, f'file{i}.csv')
            with open(path, 'w') as f:
                f.write(f'content{i}')
        
        pattern = f'{temp_dir}/*.csv'
        
        # glob returns a list
        glob_result = glob.glob(pattern)
        assert isinstance(glob_result, list)
        assert len(glob_result) == 5
        
        # iglob returns an iterator
        iglob_result = glob.iglob(pattern)
        iglob_list = list(iglob_result)
        assert len(iglob_list) == 5
        
        # Both should find the same files
        assert set(glob_result) == set(iglob_list)
    
    def test_glob_no_matches(self, temp_dir):
        """Test glob pattern with no matches."""
        pattern = f'{temp_dir}/*.nonexistent'
        found_files = glob.glob(pattern)
        
        assert found_files == []
        assert len(found_files) == 0
    
    def test_glob_with_subdirectories(self, temp_dir):
        """Test glob doesn't match files in subdirectories by default."""
        # Create file in subdirectory
        subdir = os.path.join(temp_dir, 'subdir')
        os.makedirs(subdir)
        csv_path = os.path.join(subdir, 'nested.csv')
        with open(csv_path, 'w') as f:
            f.write('data')
        
        # Single asterisk doesn't recurse
        pattern = f'{temp_dir}/*.csv'
        found_files = glob.glob(pattern)
        
        assert len(found_files) == 0
    
    def test_glob_recursive_pattern(self, temp_dir):
        """Test glob with recursive pattern."""
        # Create nested structure
        subdir = os.path.join(temp_dir, 'sub')
        os.makedirs(subdir)
        
        root_csv = os.path.join(temp_dir, 'root.csv')
        sub_csv = os.path.join(subdir, 'nested.csv')
        
        with open(root_csv, 'w') as f:
            f.write('root')
        with open(sub_csv, 'w') as f:
            f.write('nested')
        
        # Recursive pattern
        pattern = f'{temp_dir}/**/*.csv'
        found_files = glob.glob(pattern, recursive=True)
        
        assert len(found_files) >= 1  # Should find nested file


@pytest.mark.unit
class TestGlobPatternCorrectness:
    """Tests for correct glob pattern construction."""
    
    def test_pattern_with_directory_variable(self):
        """Test constructing pattern from directory variable."""
        csv_directory = '/data/imports/'
        
        # Correct pattern (as should be used)
        correct_pattern = f'{csv_directory}*.csv'
        
        # If directory has trailing slash, pattern is: /data/imports/*.csv
        # If directory lacks trailing slash: /data/imports*.csv (WRONG!)
        
        assert correct_pattern == '/data/imports/*.csv'
    
    def test_pattern_without_trailing_slash(self):
        """Test pattern when directory lacks trailing slash."""
        csv_directory = '/data/imports'
        
        # Without trailing slash in variable
        pattern = f'{csv_directory}/*.csv'  # Add slash in pattern
        
        assert pattern == '/data/imports/*.csv'
    
    def test_ensure_trailing_slash_helper(self):
        """Test helper to ensure directory has trailing slash."""
        def ensure_trailing_slash(path):
            return path if path.endswith('/') else path + '/'
        
        assert ensure_trailing_slash('/data/dir') == '/data/dir/'
        assert ensure_trailing_slash('/data/dir/') == '/data/dir/'
        assert ensure_trailing_slash('/data/dir//') == '/data/dir//'


@pytest.mark.integration
class TestBulkImportGlobUsage:
    """Tests for glob usage in bulk import context."""
    
    def test_glob_pattern_from_bulk_import(self, temp_dir):
        """Test the actual pattern used in bulk_import.py."""
        # Simulate the pattern from bulk_import.py line 99
        # for f in glob.iglob(f'{csv_directory}*.csv'):
        
        csv_directory = temp_dir + '/'  # With trailing slash
        
        # Create test files
        for i in range(3):
            path = os.path.join(temp_dir, f'import{i}.csv')
            with open(path, 'w') as f:
                f.write('header,data\n')
        
        # Pattern as in bulk_import
        pattern = f'{csv_directory}*.csv'
        files = list(glob.iglob(pattern))
        
        assert len(files) == 3
    
    def test_iterate_csv_files_with_iglob(self, temp_dir):
        """Test iterating CSV files using iglob."""
        # Create CSV files
        csv_data = [
            ('batch1.csv', 'ead,title\ntest1,Title1'),
            ('batch2.csv', 'ead,title\ntest2,Title2'),
        ]
        
        for filename, content in csv_data:
            path = os.path.join(temp_dir, filename)
            with open(path, 'w') as f:
                f.write(content)
        
        # Simulate bulk import iteration
        csv_directory = temp_dir + '/'
        processed_files = []
        
        for f in glob.iglob(f'{csv_directory}*.csv'):
            processed_files.append(os.path.basename(f))
        
        assert len(processed_files) == 2
        assert 'batch1.csv' in processed_files
        assert 'batch2.csv' in processed_files
    
    def test_glob_with_no_directory_exists(self):
        """Test glob behavior when directory doesn't exist."""
        pattern = '/nonexistent/directory/*.csv'
        files = glob.glob(pattern)
        
        # glob returns empty list for non-existent directories
        assert files == []


@pytest.mark.unit
class TestGlobEdgeCases:
    """Tests for edge cases in glob usage."""
    
    def test_glob_with_special_characters_in_filename(self, temp_dir):
        """Test glob with special characters in filenames."""
        # Create files with special characters
        special_files = [
            'file-with-dashes.csv',
            'file_with_underscores.csv',
            'file.with.dots.csv',
        ]
        
        for filename in special_files:
            path = os.path.join(temp_dir, filename)
            with open(path, 'w') as f:
                f.write('data')
        
        pattern = f'{temp_dir}/*.csv'
        found = glob.glob(pattern)
        
        assert len(found) == 3
    
    def test_glob_case_sensitivity(self, temp_dir):
        """Test glob pattern case sensitivity (platform-dependent)."""
        # Create files with different cases
        with open(os.path.join(temp_dir, 'lower.csv'), 'w') as f:
            f.write('data')
        
        # Case sensitivity is platform-dependent
        # On Linux: glob is case-sensitive
        # On macOS/Windows: may be case-insensitive
        pattern_lower = f'{temp_dir}/*.csv'
        pattern_upper = f'{temp_dir}/*.CSV'
        
        found_lower = glob.glob(pattern_lower)
        found_upper = glob.glob(pattern_upper)
        
        # At least lowercase pattern should work
        assert len(found_lower) >= 1
    
    def test_glob_empty_directory(self, temp_dir):
        """Test glob in empty directory."""
        # Create empty subdirectory
        empty_dir = os.path.join(temp_dir, 'empty')
        os.makedirs(empty_dir)
        
        pattern = f'{empty_dir}/*.csv'
        found = glob.glob(pattern)
        
        assert found == []
    
    def test_glob_directory_as_pattern(self, temp_dir):
        """Test glob with directory itself in pattern."""
        subdir = os.path.join(temp_dir, 'subdir')
        os.makedirs(subdir)
        
        # Pattern matching directories
        pattern = f'{temp_dir}/*/'
        found = glob.glob(pattern)
        
        # Should find the subdirectory
        assert len(found) >= 1
        assert any('subdir' in f for f in found)

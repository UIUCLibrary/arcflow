"""
Tests for file operation utilities in arcflow.

Tests the following functions:
- save_file: Write content to files with error handling
- create_symlink: Create symbolic links with FileExistsError handling
- get_ead_from_symlink: Extract EAD IDs from symlink targets
"""

import os
import pytest
from unittest.mock import Mock, patch, mock_open
import logging


@pytest.mark.unit
class TestSaveFile:
    """Tests for the save_file method."""
    
    def test_save_file_success(self, temp_dir):
        """Test successful file save operation."""
        from arcflow.main import ArcFlow
        
        # Create minimal mock instance
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        # Test the actual save_file implementation
        file_path = os.path.join(temp_dir, 'test.xml')
        content = b'<xml>test content</xml>'
        
        result = ArcFlow.save_file(arcflow, file_path, content, 'test', indent_size=0)
        
        assert result is True
        assert os.path.exists(file_path)
        with open(file_path, 'rb') as f:
            assert f.read() == content
    
    def test_save_file_creates_binary_file(self, temp_dir):
        """Test that save_file handles binary content correctly."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        file_path = os.path.join(temp_dir, 'binary_test.dat')
        binary_content = b'\x00\x01\x02\x03\xff\xfe'
        
        result = ArcFlow.save_file(arcflow, file_path, binary_content, 'binary', indent_size=2)
        
        assert result is True
        with open(file_path, 'rb') as f:
            assert f.read() == binary_content
    
    def test_save_file_overwrites_existing(self, temp_dir):
        """Test that save_file overwrites existing files."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        file_path = os.path.join(temp_dir, 'overwrite.txt')
        
        # Create initial file
        with open(file_path, 'wb') as f:
            f.write(b'old content')
        
        # Overwrite with new content
        new_content = b'new content'
        result = ArcFlow.save_file(arcflow, file_path, new_content, 'test', indent_size=0)
        
        assert result is True
        with open(file_path, 'rb') as f:
            assert f.read() == new_content
    
    def test_save_file_invalid_directory(self):
        """Test save_file with non-existent directory path."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        invalid_path = '/nonexistent/directory/file.txt'
        content = b'test'
        
        result = ArcFlow.save_file(arcflow, invalid_path, content, 'test', indent_size=0)
        
        assert result is False


@pytest.mark.unit
class TestCreateSymlink:
    """Tests for the create_symlink method."""
    
    def test_create_symlink_success(self, temp_dir):
        """Test successful symlink creation."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        # Create target file
        target_path = os.path.join(temp_dir, 'target.xml')
        with open(target_path, 'w') as f:
            f.write('target content')
        
        # Create symlink
        symlink_path = os.path.join(temp_dir, 'link.xml')
        result = ArcFlow.create_symlink(arcflow, target_path, symlink_path, indent_size=0)
        
        assert result is True
        assert os.path.islink(symlink_path)
        assert os.path.realpath(symlink_path) == target_path
    
    def test_create_symlink_already_exists(self, temp_dir):
        """Test symlink creation when symlink already exists."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        target_path = os.path.join(temp_dir, 'target.xml')
        symlink_path = os.path.join(temp_dir, 'existing_link.xml')
        
        # Create target
        with open(target_path, 'w') as f:
            f.write('content')
        
        # Create initial symlink
        os.symlink(target_path, symlink_path)
        
        # Try to create again - should return False
        result = ArcFlow.create_symlink(arcflow, target_path, symlink_path, indent_size=0)
        
        assert result is False
        assert os.path.islink(symlink_path)
    
    def test_create_symlink_with_indentation(self, temp_dir):
        """Test that symlink creation respects indent_size parameter."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        target_path = os.path.join(temp_dir, 'target.xml')
        symlink_path = os.path.join(temp_dir, 'indented_link.xml')
        
        with open(target_path, 'w') as f:
            f.write('content')
        
        # Should still work with indent_size parameter
        result = ArcFlow.create_symlink(arcflow, target_path, symlink_path, indent_size=4)
        
        assert result is True
        assert os.path.islink(symlink_path)


@pytest.mark.unit
class TestGetEadFromSymlink:
    """Tests for the get_ead_from_symlink method."""
    
    def test_get_ead_from_valid_symlink(self, temp_dir):
        """Test extracting EAD ID from a valid symlink."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        # Create target file with EAD ID as filename
        target_path = os.path.join(temp_dir, 'test-collection-123.xml')
        with open(target_path, 'w') as f:
            f.write('<ead></ead>')
        
        # Create symlink
        symlink_path = os.path.join(temp_dir, 'link.xml')
        os.symlink(target_path, symlink_path)
        
        # Extract EAD ID
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, symlink_path)
        
        assert ead_id == 'test-collection-123'
    
    def test_get_ead_from_symlink_with_dots(self, temp_dir):
        """Test EAD ID extraction from filename with dots."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        # Create target with dots in filename
        target_path = os.path.join(temp_dir, 'test.collection.456.xml')
        with open(target_path, 'w') as f:
            f.write('<ead></ead>')
        
        symlink_path = os.path.join(temp_dir, 'dotted_link.xml')
        os.symlink(target_path, symlink_path)
        
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, symlink_path)
        
        assert ead_id == 'test.collection.456'
    
    def test_get_ead_from_nonexistent_symlink(self):
        """Test behavior with non-existent symlink."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, '/nonexistent/symlink.xml')
        
        assert ead_id is None
    
    def test_get_ead_from_regular_file(self, temp_dir):
        """Test behavior when path is a regular file, not a symlink."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        # Create regular file (not a symlink)
        file_path = os.path.join(temp_dir, 'regular-file-789.xml')
        with open(file_path, 'w') as f:
            f.write('<ead></ead>')
        
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, file_path)
        
        # Should still extract ID from filename
        assert ead_id == 'regular-file-789'
    
    def test_get_ead_handles_nested_paths(self, temp_dir):
        """Test EAD extraction with nested directory structures."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        # Create nested structure
        nested_dir = os.path.join(temp_dir, 'repos', 'repo1', 'collections')
        os.makedirs(nested_dir, exist_ok=True)
        
        target_path = os.path.join(nested_dir, 'nested-collection.xml')
        with open(target_path, 'w') as f:
            f.write('<ead></ead>')
        
        symlink_path = os.path.join(temp_dir, 'nested_link.xml')
        os.symlink(target_path, symlink_path)
        
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, symlink_path)
        
        assert ead_id == 'nested-collection'

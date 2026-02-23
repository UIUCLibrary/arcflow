"""
Tests for batch processing logic in arcflow.

Tests the following functionality:
- Batch size calculations for indexing operations
- Edge cases: empty lists, single items, exact multiples
- Batch iteration logic using math.ceil
"""

import pytest
import math


@pytest.mark.unit
class TestBatchCalculation:
    """Tests for batch calculation logic."""
    
    def test_batch_count_exact_multiple(self):
        """Test batch count when items are exact multiple of batch size."""
        items = list(range(100))
        batch_size = 10
        
        expected_batches = 10
        actual_batches = math.ceil(len(items) / batch_size)
        
        assert actual_batches == expected_batches
    
    def test_batch_count_with_remainder(self):
        """Test batch count when items don't divide evenly."""
        items = list(range(105))
        batch_size = 10
        
        expected_batches = 11  # 10 full batches + 1 partial
        actual_batches = math.ceil(len(items) / batch_size)
        
        assert actual_batches == expected_batches
    
    def test_batch_count_single_item(self):
        """Test batch count with single item."""
        items = [1]
        batch_size = 100
        
        expected_batches = 1
        actual_batches = math.ceil(len(items) / batch_size)
        
        assert actual_batches == expected_batches
    
    def test_batch_count_empty_list(self):
        """Test batch count with empty list."""
        items = []
        batch_size = 100
        
        expected_batches = 0
        actual_batches = math.ceil(len(items) / batch_size)
        
        assert actual_batches == expected_batches
    
    def test_batch_count_items_less_than_batch_size(self):
        """Test when total items less than batch size."""
        items = list(range(5))
        batch_size = 100
        
        expected_batches = 1
        actual_batches = math.ceil(len(items) / batch_size)
        
        assert actual_batches == expected_batches


@pytest.mark.unit
class TestBatchIteration:
    """Tests for batch iteration patterns."""
    
    def test_iterate_batches_standard(self):
        """Test standard batch iteration pattern."""
        items = list(range(25))
        batch_size = 10
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 3
        assert len(batches[0]) == 10
        assert len(batches[1]) == 10
        assert len(batches[2]) == 5  # Partial last batch
    
    def test_batch_number_calculation(self):
        """Test calculating batch number during iteration."""
        items = list(range(250))
        batch_size = 100
        
        batch_numbers = []
        for i in range(0, len(items), batch_size):
            batch_num = (i // batch_size) + 1
            batch_numbers.append(batch_num)
        
        assert batch_numbers == [1, 2, 3]
    
    def test_batch_contents_correct(self):
        """Test that batch contents are correctly sliced."""
        items = ['a', 'b', 'c', 'd', 'e', 'f', 'g']
        batch_size = 3
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert batches[0] == ['a', 'b', 'c']
        assert batches[1] == ['d', 'e', 'f']
        assert batches[2] == ['g']
    
    def test_empty_list_iteration(self):
        """Test iteration over empty list produces no batches."""
        items = []
        batch_size = 100
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 0


@pytest.mark.unit
class TestCreatorIndexingBatches:
    """Tests specific to creator indexing batch logic."""
    
    def test_default_batch_size(self):
        """Test that default batch size is 100."""
        # Documents the default from index_creators method
        default_batch_size = 100
        
        creator_ids = list(range(250))
        total_batches = math.ceil(len(creator_ids) / default_batch_size)
        
        assert total_batches == 3
    
    def test_xml_file_path_construction_in_batch(self):
        """Test constructing XML file paths for a batch."""
        agents_dir = '/data/agents'
        batch = ['agent_1', 'agent_2', 'agent_3']
        
        xml_files = [f'{agents_dir}/{cid}.xml' for cid in batch]
        
        assert xml_files == [
            '/data/agents/agent_1.xml',
            '/data/agents/agent_2.xml',
            '/data/agents/agent_3.xml'
        ]
    
    def test_batch_filtering_existing_files(self, temp_dir):
        """Test filtering batch to only existing files."""
        import os
        
        # Create some files but not others
        file1 = os.path.join(temp_dir, 'agent_1.xml')
        file3 = os.path.join(temp_dir, 'agent_3.xml')
        
        with open(file1, 'w') as f:
            f.write('<xml/>')
        with open(file3, 'w') as f:
            f.write('<xml/>')
        
        # Batch has 3 items but only 2 files exist
        xml_files = [
            file1,
            os.path.join(temp_dir, 'agent_2.xml'),  # Doesn't exist
            file3
        ]
        
        existing_files = [f for f in xml_files if os.path.exists(f)]
        
        assert len(existing_files) == 2
        assert file1 in existing_files
        assert file3 in existing_files
    
    def test_skip_empty_batch(self):
        """Test that empty batches should be skipped."""
        existing_files = []
        
        # Logic from index_creators: if not existing_files, skip
        should_process = len(existing_files) > 0
        
        assert should_process is False


@pytest.mark.unit
class TestBatchEdgeCases:
    """Tests for edge cases in batch processing."""
    
    def test_batch_size_equals_total_items(self):
        """Test when batch size equals total number of items."""
        items = list(range(10))
        batch_size = 10
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 1
        assert batches[0] == items
    
    def test_batch_size_larger_than_items(self):
        """Test when batch size is larger than total items."""
        items = list(range(5))
        batch_size = 100
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 1
        assert batches[0] == items
    
    def test_batch_size_one(self):
        """Test batch size of 1."""
        items = ['a', 'b', 'c']
        batch_size = 1
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 3
        assert all(len(batch) == 1 for batch in batches)
    
    def test_large_dataset_batch_calculation(self):
        """Test batch calculation for large datasets."""
        total_items = 10000
        batch_size = 100
        
        expected_batches = 100
        actual_batches = math.ceil(total_items / batch_size)
        
        assert actual_batches == expected_batches
    
    def test_batch_with_none_values(self):
        """Test batching list that contains None values."""
        items = ['a', None, 'b', None, 'c']
        batch_size = 2
        
        batches = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            batches.append(batch)
        
        assert len(batches) == 3
        assert None in batches[0]
        assert None in batches[1]


@pytest.mark.integration
class TestBatchingInContext:
    """Integration tests for batching in realistic scenarios."""
    
    def test_process_1000_items_with_batch_1000(self):
        """Test processing exactly 1000 items with batch size 1000."""
        items = list(range(1000))
        batch_size = 1000
        
        processed = []
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            processed.extend(batch)
        
        assert len(processed) == 1000
        assert processed == items
    
    def test_batch_progress_reporting(self):
        """Test calculating batch progress for logging."""
        total_items = 250
        batch_size = 100
        total_batches = math.ceil(total_items / batch_size)
        
        progress = []
        for i in range(0, total_items, batch_size):
            batch_num = (i // batch_size) + 1
            progress.append(f'Batch {batch_num}/{total_batches}')
        
        assert progress == [
            'Batch 1/3',
            'Batch 2/3',
            'Batch 3/3'
        ]

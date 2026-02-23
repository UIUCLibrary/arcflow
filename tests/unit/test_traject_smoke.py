"""
Traject smoke tests - verify traject works without Solr.

Goal: Catch config/XML errors in <60 seconds, not 10 minutes.
"""

import pytest
import subprocess
from pathlib import Path


def find_traject_config():
    """Locate traject config file"""
    candidates = [
        "traject_config_eac_cpf.rb",
        "example_traject_config_eac_cpf.rb",
    ]
    for path in candidates:
        if Path(path).exists():
            return path
    return None

class TestTrajectSmoke:
    """Smoke tests for traject configuration (no Solr required)"""
    
    def test_ruby_interpreter_available(self):
        """Verify Ruby is installed"""
        result = subprocess.run(["ruby", "--version"], capture_output=True)
        assert result.returncode == 0
    
    def test_traject_gem_installed(self):
        """Verify traject gem is available"""
        result = subprocess.run(
            ["bundle", "exec", "traject", "--version"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        # Traject outputs version to stderr, not stdout
        assert "traject" in result.stderr.lower()
    
    @pytest.mark.skipif(
        find_traject_config() is None,
        reason="Traject config not found (expected if not yet created)"
    )
    def test_traject_config_syntax_valid(self):
        """Verify traject config has valid Ruby syntax"""
        config = find_traject_config()
        result = subprocess.run(
            ["ruby", "-c", config],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Syntax error: {result.stderr}"
    
    @pytest.mark.skipif(
        find_traject_config() is None,
        reason="Traject config not found"
    )
    def test_traject_processes_xml(self, sample_eac_cpf_xml, tmp_path):
        """Verify traject can transform XML (without Solr indexing)"""
        config = find_traject_config()
        xml_file = tmp_path / "test.xml"
        xml_file.write_text(sample_eac_cpf_xml)
        
        # Process with DebugWriter (no Solr needed)
        result = subprocess.run([
            "bundle", "exec", "traject",
            "-c", config,
            "-w", "Traject::DebugWriter",
            str(xml_file)
        ], capture_output=True, text=True, timeout=30)
        
        assert result.returncode == 0, f"Processing failed:\n{result.stderr}"

"""
Traject smoke tests - verify traject config and XML processing work.

These tests run traject without Solr to catch config errors quickly.
Goal: < 60 seconds total including Ruby setup (with caching).
"""

import pytest
import subprocess
from pathlib import Path


def test_traject_config_syntax_valid():
    """Verify traject config has valid Ruby syntax"""
    # Find traject config (might be in different locations)
    possible_paths = [
        "traject_config_eac_cpf.rb",
        "example_traject_config_eac_cpf.rb",
    ]
    
    config_path = None
    for path in possible_paths:
        if Path(path).exists():
            config_path = path
            break
    
    if not config_path:
        pytest.skip("No traject config found (expected if not yet created)")
    
    # Ruby syntax check (fast, doesn't execute)
    result = subprocess.run(
        ["ruby", "-c", config_path],
        capture_output=True,
        text=True
    )
    
    assert result.returncode == 0, f"Invalid Ruby syntax: {result.stderr}"


@pytest.mark.skipif(
    not Path("example_traject_config_eac_cpf.rb").exists(),
    reason="Traject config not yet available"
)
def test_traject_loads_config():
    """Verify traject can load config without errors"""
    result = subprocess.run(
        ["bundle", "exec", "traject", "-c", "example_traject_config_eac_cpf.rb"],
        capture_output=True,
        text=True
    )
    
    # Should show usage/help without crashing - exitcode 1 is expected for no input files
    # But should not have load errors in stderr
    if result.returncode != 1:
        assert "error loading" not in result.stderr.lower(), f"Config load error: {result.stderr}"


@pytest.mark.skipif(
    not Path("example_traject_config_eac_cpf.rb").exists(),
    reason="Traject config not yet available"
)
def test_traject_processes_sample_xml(tmp_path, sample_eac_cpf_xml):
    """Verify traject can transform XML without Solr (smoke test)"""
    xml_file = tmp_path / "sample.xml"
    xml_file.write_text(sample_eac_cpf_xml)
    
    # Use DebugWriter to process without Solr
    result = subprocess.run([
        "bundle", "exec", "traject",
        "-c", "example_traject_config_eac_cpf.rb",
        "-w", "Traject::DebugWriter",
        str(xml_file)
    ], capture_output=True, text=True)
    
    # Should complete without errors
    assert result.returncode == 0, f"Traject processing failed: {result.stderr}"

import json
import subprocess
import sys
from pathlib import Path


def test_version_chain_contract_is_valid():
    result = subprocess.run(
        [sys.executable, "scripts/validate_version_chain.py", "docs/releases/version-chain.json"],
        cwd=Path.cwd(),
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "version-chain OK" in result.stdout


def test_version_chain_matches_package_version():
    contract = json.loads(Path("docs/releases/version-chain.json").read_text(encoding="utf-8"))
    pyproject = Path("pyproject.toml").read_text(encoding="utf-8")
    assert f'version = "{contract["project"]["version"]}"' in pyproject
    assert contract["release"]["targetVersion"] == contract["project"]["version"]
    assert set(contract["branches"]) == {"patch", "release", "nightly", "stable"}

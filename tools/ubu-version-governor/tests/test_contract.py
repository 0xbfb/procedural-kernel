from pathlib import Path
import json
import pytest

from ubu_version_governor.contract import ContractError, load_contract
from ubu_version_governor.planner import build_plan


def write_json(tmp_path: Path, data: dict) -> Path:
    path = tmp_path / "version-chain.json"
    path.write_text(json.dumps(data), encoding="utf-8")
    return path


def valid_contract() -> dict:
    return {
        "schemaVersion": "1.0",
        "project": {"name": "demo", "version": "0.2.0"},
        "release": {"channel": "release", "targetVersion": "0.2.0", "promoteTo": ["release", "nightly"], "tagPrefix": "v"},
        "branches": {"patch": "patch/{version}", "release": "release/{version}", "nightly": "nightly", "stable": "stable"},
        "commits": [{"message": "chore(release): prepare 0.2.0", "include": ["."]}],
        "push": {"enabled": True, "remote": "origin", "branches": True, "tags": True},
        "safety": {"requireCleanWorkingTree": False, "requireBranch": None, "allowBranchCreate": True, "allowBranchReset": False},
    }


def test_load_contract_and_build_plan(tmp_path: Path):
    contract = load_contract(write_json(tmp_path, valid_contract()))
    assert contract.project_name == "demo"
    assert contract.tag_name == "v0.2.0"
    plan = build_plan(contract, push_requested=True)
    assert any("release/0.2.0" in step for step in plan.steps)
    assert any("nightly" in step for step in plan.steps)


def test_invalid_promotion_is_rejected(tmp_path: Path):
    data = valid_contract()
    data["release"]["promoteTo"] = ["production"]
    with pytest.raises(ContractError):
        load_contract(write_json(tmp_path, data))

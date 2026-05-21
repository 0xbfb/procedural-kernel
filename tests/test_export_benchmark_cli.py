import json

from procedural_kernel.benchmark import run_generation_benchmark
from procedural_kernel.cli import main
from procedural_kernel.exporters.json_bundle import export_json_bundle
from procedural_kernel.simulation import run_temporal_simulation
from procedural_kernel.storage import SQLiteStore


def test_export_json_bundle_contains_versioned_contract(tmp_path):
    db = tmp_path / "bundle.sqlite"
    run_temporal_simulation(db_path=db, seed="bundle", events=5)

    with SQLiteStore(db) as store:
        bundle = export_json_bundle(store, seed="bundle", generated_at="2026-05-21T00:00:00Z")

    assert bundle["schema_version"] == "bundle.v1"
    assert bundle["world_version"] == "0.1.3"
    assert bundle["seed"] == "bundle"
    assert bundle["metadata"]["storage"]["events"] == 5
    assert bundle["chunks"]
    assert bundle["entities"]
    assert len(bundle["events"]) == 5
    assert bundle["snapshots"]


def test_cli_export_writes_json_bundle(tmp_path, capsys):
    db = tmp_path / "export.sqlite"
    out = tmp_path / "world_bundle.json"
    assert main(["simulate", "--storage", str(db), "--seed", "export", "--events", "3"]) == 0
    capsys.readouterr()

    code = main(["export", "--storage", str(db), "--out", str(out), "--seed", "export"])
    summary = capsys.readouterr().out
    assert code == 0
    assert out.exists()
    assert '"schema_version": "bundle.v1"' in summary
    payload = json.loads(out.read_text(encoding="utf-8"))
    assert payload["schema_version"] == "bundle.v1"
    assert payload["metadata"]["storage"]["events"] == 3


def test_cli_inspect_storage_summary(tmp_path, capsys):
    db = tmp_path / "inspect.sqlite"
    assert main(["simulate", "--storage", str(db), "--events", "2"]) == 0
    capsys.readouterr()

    code = main(["inspect", "--storage", str(db)])
    out = capsys.readouterr().out
    assert code == 0
    assert '"mode": "storage"' in out
    assert '"schema_version": "storage.v1"' in out
    assert '"events": 2' in out


def test_benchmark_generates_requested_entities():
    result = run_generation_benchmark(entities=1_000, seed="bench", entities_per_chunk=250)
    assert result.generated_entities == 1_000
    assert result.chunks == 4
    assert result.digest.startswith("benchmark:")
    assert result.entities_per_second > 0


def test_cli_benchmark_runs(capsys):
    code = main(["benchmark", "--entities", "1000", "--seed", "bench"])
    out = capsys.readouterr().out
    assert code == 0
    assert '"requested_entities": 1000' in out
    assert '"generated_entities": 1000' in out

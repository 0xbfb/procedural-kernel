from procedural_kernel.cli import main


def test_cli_doctor_runs(capsys):
    code = main(["doctor", "--seed", "test"])
    out = capsys.readouterr().out
    assert code == 0
    assert '"ok": true' in out
    assert "sample_chunk_id" in out


def test_cli_inspect_runs(capsys):
    code = main(["inspect", "--seed", "test", "--layer", "city", "--x", "1", "--y", "2"])
    out = capsys.readouterr().out
    assert code == 0
    assert '"schema_version": "chunk.v1"' in out


def test_cli_simulate_and_replay_runs(tmp_path, capsys):
    db = tmp_path / "sim.sqlite"
    code = main(["simulate", "--storage", str(db), "--seed", "test", "--events", "3"])
    out = capsys.readouterr().out
    assert code == 0
    assert '"ok": true' in out
    assert '"patches"' in out

    replay_code = main(["replay", "--storage", str(db)])
    replay_out = capsys.readouterr().out
    assert replay_code == 0
    assert '"events": 3' in replay_out
    assert '"latest_snapshot_id"' in replay_out

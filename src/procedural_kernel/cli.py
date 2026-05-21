"""Command line interface for Procedural Kernel."""

from __future__ import annotations

import argparse
import platform
import sys
from pathlib import Path
from typing import Sequence

import numpy as np
import orjson
import pydantic

from procedural_kernel import __version__
from procedural_kernel.benchmark import run_generation_benchmark
from procedural_kernel.chunks import generate_chunk
from procedural_kernel.events import make_event
from procedural_kernel.exporters.json_bundle import write_json_bundle
from procedural_kernel.reports.markdown import simulation_report_markdown
from procedural_kernel.serialization import dumps
from procedural_kernel.simulation import run_temporal_simulation
from procedural_kernel.storage import SQLiteStore


def _snapshot_summary(snapshot) -> dict[str, object] | None:
    if snapshot is None:
        return None
    return {
        "id": snapshot.id,
        "tick": snapshot.tick,
        "event_count": snapshot.event_count,
        "schema_version": snapshot.schema_version,
        "state_included": False,
    }


def _cmd_doctor(args: argparse.Namespace) -> int:
    sample = generate_chunk(seed=args.seed, layer="doctor", x=0, y=0)
    with SQLiteStore(":memory:") as store:
        store.store_chunk(sample)
        event = make_event(
            "entity.patch",
            tick=1,
            scope=sample.id,
            payload={
                "entity_id": sample.entities[0].id,
                "path": "doctor.ok",
                "value": True,
            },
        )
        store.append_event(event)
        storage_stats = store.stats()
    report = {
        "ok": True,
        "package": "procedural-kernel",
        "version": __version__,
        "python": platform.python_version(),
        "platform": platform.platform(),
        "dependencies": {
            "numpy": np.__version__,
            "orjson": getattr(orjson, "__version__", "unknown"),
            "pydantic": pydantic.__version__,
        },
        "sample_chunk_id": sample.id,
        "sqlite_smoke": storage_stats,
    }
    print(dumps(report, pretty=True).decode("utf-8"))
    return 0


def _inspect_storage(args: argparse.Namespace) -> dict[str, object]:
    with SQLiteStore(args.db) as store:
        latest_snapshot = store.latest_snapshot()
        report: dict[str, object] = {
            "ok": True,
            "mode": "storage",
            "db_path": str(args.db),
            "metadata": store.metadata(),
            "stats": store.stats(),
            "latest_snapshot": _snapshot_summary(latest_snapshot),
        }
        if args.entity:
            report["entity_id"] = args.entity
            report["entity_state"] = store.resolve_entity(args.entity)
        else:
            chunks = store.list_chunks()
            report["chunk_ids"] = [chunk.id for chunk in chunks[: args.limit]]
            report["sample_entities"] = [
                entity.model_dump(mode="json")
                for chunk in chunks[: args.limit]
                for entity in chunk.entities[:2]
            ][: args.limit]
        return report


def _inspect_chunk(args: argparse.Namespace) -> dict[str, object]:
    sample = generate_chunk(
        seed=args.seed,
        layer=args.layer,
        x=args.x,
        y=args.y,
        region=args.region,
        entity_count=args.entities,
    )
    return {"ok": True, "mode": "chunk", "chunk": sample.model_dump(mode="json")}


def _cmd_inspect(args: argparse.Namespace) -> int:
    report = _inspect_storage(args) if args.db else _inspect_chunk(args)
    print(dumps(report, pretty=True).decode("utf-8"))
    return 0


def _cmd_simulate(args: argparse.Namespace) -> int:
    report = run_temporal_simulation(
        db_path=args.db,
        seed=args.seed,
        layer=args.layer,
        x=args.x,
        y=args.y,
        events=args.events,
        snapshot=not args.no_snapshot,
    )
    if args.report == "markdown":
        rendered = simulation_report_markdown(report)
        if args.report_file:
            Path(args.report_file).write_text(rendered, encoding="utf-8")
        print(rendered)
    else:
        rendered = dumps(report, pretty=True).decode("utf-8")
        if args.report_file:
            Path(args.report_file).write_text(rendered + "\n", encoding="utf-8")
        print(rendered)
    return 0


def _cmd_replay(args: argparse.Namespace) -> int:
    db_path = Path(args.db)
    if str(args.db) != ":memory:" and not db_path.exists():
        print(f"Database not found: {db_path}", file=sys.stderr)
        return 1

    with SQLiteStore(args.db) as store:
        latest_snapshot = store.latest_snapshot()
        report: dict[str, object] = {
            "ok": True,
            "db_path": str(args.db),
            "metadata": store.metadata(),
            "stats": store.stats(),
            "latest_snapshot": _snapshot_summary(latest_snapshot),
        }
        if args.entity:
            report["entity_id"] = args.entity
            report["entity_state"] = store.resolve_entity(args.entity)
        else:
            report["events"] = [event.model_dump(mode="json") for event in store.list_events(limit=args.limit)]
    print(dumps(report, pretty=True).decode("utf-8"))
    return 0


def _cmd_export(args: argparse.Namespace) -> int:
    with SQLiteStore(args.db) as store:
        summary = write_json_bundle(
            store,
            args.out,
            seed=args.seed,
            world_version=args.world_version,
            include_events=not args.no_events,
            include_snapshots=not args.no_snapshots,
            event_limit=args.event_limit,
        )
    print(dumps(summary, pretty=True).decode("utf-8"))
    return 0


def _cmd_benchmark(args: argparse.Namespace) -> int:
    result = run_generation_benchmark(
        entities=args.entities,
        seed=args.seed,
        entities_per_chunk=args.entities_per_chunk,
    ).as_dict()
    rendered = dumps(result, pretty=True).decode("utf-8")
    if args.report_file:
        Path(args.report_file).write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return 0


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="procedural-kernel")
    parser.add_argument("--version", action="version", version=f"procedural-kernel {__version__}")
    sub = parser.add_subparsers(dest="command", required=True)

    doctor = sub.add_parser("doctor", help="Run environment and deterministic smoke checks.")
    doctor.add_argument("--seed", default="procedural-kernel-doctor")
    doctor.set_defaults(func=_cmd_doctor)

    inspect = sub.add_parser("inspect", help="Inspect deterministic chunks or persisted SQLite state.")
    inspect.add_argument("--storage", "--db", dest="db", default=None)
    inspect.add_argument("--entity", default=None)
    inspect.add_argument("--limit", type=int, default=25)
    inspect.add_argument("--seed", default="procedural-kernel-inspect")
    inspect.add_argument("--layer", default="city")
    inspect.add_argument("--region", default="world")
    inspect.add_argument("--x", type=int, default=0)
    inspect.add_argument("--y", type=int, default=0)
    inspect.add_argument("--entities", type=int, default=4)
    inspect.set_defaults(func=_cmd_inspect)

    simulate = sub.add_parser("simulate", help="Run a tiny deterministic simulation into SQLite.")
    simulate.add_argument("--storage", "--db", dest="db", default="procedural_kernel.sqlite")
    simulate.add_argument("--seed", default="procedural-kernel-sim")
    simulate.add_argument("--layer", default="city")
    simulate.add_argument("--x", type=int, default=0)
    simulate.add_argument("--y", type=int, default=0)
    simulate.add_argument("--events", type=int, default=2)
    simulate.add_argument("--no-snapshot", action="store_true")
    simulate.add_argument("--report", choices=("json", "markdown"), default="json")
    simulate.add_argument("--report-file", default=None)
    simulate.set_defaults(func=_cmd_simulate)

    replay = sub.add_parser("replay", help="Inspect replayable persisted state from SQLite.")
    replay.add_argument("--storage", "--db", dest="db", default="procedural_kernel.sqlite")
    replay.add_argument("--entity", default=None)
    replay.add_argument("--limit", type=int, default=25)
    replay.set_defaults(func=_cmd_replay)

    export = sub.add_parser("export", help="Export a versioned engine-facing JSON bundle.")
    export.add_argument("--storage", "--db", dest="db", default="procedural_kernel.sqlite")
    export.add_argument("--out", required=True)
    export.add_argument("--seed", default="unknown")
    export.add_argument("--world-version", default="0.1.2")
    export.add_argument("--event-limit", type=int, default=None)
    export.add_argument("--no-events", action="store_true")
    export.add_argument("--no-snapshots", action="store_true")
    export.set_defaults(func=_cmd_export)

    benchmark = sub.add_parser("benchmark", help="Run deterministic generation benchmarks.")
    benchmark.add_argument("--entities", type=int, default=10_000)
    benchmark.add_argument("--seed", default="procedural-kernel-benchmark")
    benchmark.add_argument("--entities-per-chunk", type=int, default=128)
    benchmark.add_argument("--report-file", default=None)
    benchmark.set_defaults(func=_cmd_benchmark)

    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())

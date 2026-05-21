"""Versioned JSON bundle exporter.

The exporter is intentionally engine-agnostic. It serializes the current
procedural storage view into a stable contract that renderers, launchers or
build pipelines can consume without importing the Python package at runtime.
"""

from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from procedural_kernel.serialization import dumps
from procedural_kernel.storage import SQLiteStore

BUNDLE_SCHEMA_VERSION = "bundle.v1"
DEFAULT_WORLD_VERSION = "0.1.3"
KERNEL_VERSION = "0.1.3"


def _utc_now_iso() -> str:
    return datetime.now(UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def export_json_bundle(
    store: SQLiteStore,
    *,
    seed: str = "unknown",
    world_version: str = DEFAULT_WORLD_VERSION,
    include_events: bool = True,
    include_snapshots: bool = True,
    event_limit: int | None = None,
    generated_at: str | None = None,
) -> dict[str, Any]:
    """Build a versioned JSON-serializable bundle from a SQLite store.

    The materialized entity state is derived from procedural base chunks plus
    persisted patches. Events are included by default so the bundle can be
    audited or replayed by external tools if needed.
    """

    chunks = store.list_chunks()
    materialized = store.build_materialized_state()
    events = store.list_events(limit=event_limit) if include_events else []
    latest_snapshot = store.latest_snapshot() if include_snapshots else None

    return {
        "schema_version": BUNDLE_SCHEMA_VERSION,
        "world_version": world_version,
        "kernel_version": KERNEL_VERSION,
        "seed": seed,
        "generated_at": generated_at or _utc_now_iso(),
        "metadata": {
            "storage": store.stats(),
            "chunk_count": len(chunks),
            "entity_count": len(materialized.get("entities", {})),
            "event_count": len(events),
            "snapshot_included": latest_snapshot is not None,
        },
        "chunks": [chunk.model_dump(mode="json") for chunk in chunks],
        "entities": materialized.get("entities", {}),
        "events": [event.model_dump(mode="json") for event in events],
        "snapshots": [latest_snapshot.model_dump(mode="json")] if latest_snapshot else [],
    }


def write_json_bundle(
    store: SQLiteStore,
    out: str | Path,
    *,
    seed: str = "unknown",
    world_version: str = DEFAULT_WORLD_VERSION,
    include_events: bool = True,
    include_snapshots: bool = True,
    event_limit: int | None = None,
) -> dict[str, Any]:
    """Write a pretty JSON bundle and return a small export summary."""

    bundle = export_json_bundle(
        store,
        seed=seed,
        world_version=world_version,
        include_events=include_events,
        include_snapshots=include_snapshots,
        event_limit=event_limit,
    )
    out_path = Path(out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(dumps(bundle, pretty=True) + b"\n")
    return {
        "ok": True,
        "out": str(out_path),
        "schema_version": bundle["schema_version"],
        "world_version": bundle["world_version"],
        "chunks": len(bundle["chunks"]),
        "entities": len(bundle["entities"]),
        "events": len(bundle["events"]),
        "snapshots": len(bundle["snapshots"]),
    }

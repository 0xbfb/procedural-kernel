"""SQLite storage adapter for events, patches, chunks and snapshots."""

from __future__ import annotations

import sqlite3
from collections.abc import Iterable
from pathlib import Path
from typing import Any

from procedural_kernel.events import ReducerRegistry, event_to_patches
from procedural_kernel.ids import stable_id
from procedural_kernel.schemas import Event, GeneratedChunk, Patch, Snapshot
from procedural_kernel.serialization import dumps, loads
from procedural_kernel.state import apply_patch_map, entity_base_state


class SQLiteStore:
    """Small SQLite-backed store for local procedural state.

    The store keeps the append-only event log and a materialized patch overlay.
    The world base remains procedural; only generated chunk summaries, events,
    patches and optional snapshots are persisted.
    """

    def __init__(self, path: str | Path = ":memory:") -> None:
        self.path = str(path)
        self.connection = sqlite3.connect(self.path)
        self.connection.row_factory = sqlite3.Row
        self.initialize()

    def close(self) -> None:
        self.connection.close()

    def __enter__(self) -> "SQLiteStore":
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        self.close()

    def initialize(self) -> None:
        self.connection.executescript(
            """
            PRAGMA journal_mode=WAL;
            PRAGMA foreign_keys=ON;

            CREATE TABLE IF NOT EXISTS metadata (
                key TEXT PRIMARY KEY,
                value_json BLOB NOT NULL
            );

            CREATE TABLE IF NOT EXISTS chunks (
                id TEXT PRIMARY KEY,
                layer TEXT NOT NULL,
                region TEXT NOT NULL,
                x INTEGER NOT NULL,
                y INTEGER NOT NULL,
                version TEXT NOT NULL,
                seed TEXT NOT NULL,
                chunk_json BLOB NOT NULL,
                generated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS events (
                id TEXT PRIMARY KEY,
                tick INTEGER NOT NULL,
                type TEXT NOT NULL,
                scope TEXT NOT NULL,
                payload_json BLOB NOT NULL,
                schema_version TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS patches (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                entity_id TEXT NOT NULL,
                path TEXT NOT NULL,
                value_json BLOB NOT NULL,
                tick INTEGER NOT NULL,
                source_event_id TEXT NOT NULL,
                schema_version TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(entity_id, path, source_event_id),
                FOREIGN KEY(source_event_id) REFERENCES events(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS snapshots (
                id TEXT PRIMARY KEY,
                tick INTEGER NOT NULL,
                event_count INTEGER NOT NULL,
                state_json BLOB NOT NULL,
                schema_version TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );

            CREATE INDEX IF NOT EXISTS idx_chunks_key ON chunks(layer, region, x, y, version);
            CREATE INDEX IF NOT EXISTS idx_events_tick ON events(tick, id);
            CREATE INDEX IF NOT EXISTS idx_events_type ON events(type);
            CREATE INDEX IF NOT EXISTS idx_patches_entity ON patches(entity_id, tick, id);
            CREATE INDEX IF NOT EXISTS idx_patches_event ON patches(source_event_id);
            CREATE INDEX IF NOT EXISTS idx_snapshots_tick ON snapshots(tick);
            """
        )
        default_metadata = {
            "storage_schema_version": "storage.v1",
            "world_schema_version": "world.v1",
            "snapshot_policy": {"default_every_events": 1000},
        }
        for key, value in default_metadata.items():
            self.connection.execute(
                "INSERT OR IGNORE INTO metadata(key, value_json) VALUES (?, ?)",
                (key, dumps(value)),
            )
        self.connection.commit()

    def set_metadata(self, key: str, value: Any) -> None:
        self.connection.execute(
            """
            INSERT INTO metadata(key, value_json)
            VALUES (?, ?)
            ON CONFLICT(key) DO UPDATE SET value_json = excluded.value_json
            """,
            (key, dumps(value)),
        )
        self.connection.commit()

    def get_metadata(self, key: str, default: Any = None) -> Any:
        row = self.connection.execute("SELECT value_json FROM metadata WHERE key = ?", (key,)).fetchone()
        if row is None:
            return default
        return loads(row["value_json"])

    def store_chunk(self, chunk: GeneratedChunk) -> None:
        self.connection.execute(
            """
            INSERT INTO chunks(id, layer, region, x, y, version, seed, chunk_json)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                seed = excluded.seed,
                chunk_json = excluded.chunk_json,
                generated_at = CURRENT_TIMESTAMP
            """,
            (
                chunk.id,
                chunk.key.layer,
                chunk.key.region,
                chunk.key.x,
                chunk.key.y,
                chunk.key.version,
                str(chunk.seed),
                dumps(chunk),
            ),
        )
        self.connection.commit()

    def get_chunk(self, chunk_id: str) -> GeneratedChunk | None:
        row = self.connection.execute("SELECT chunk_json FROM chunks WHERE id = ?", (chunk_id,)).fetchone()
        if row is None:
            return None
        return GeneratedChunk.model_validate(loads(row["chunk_json"]))

    def list_chunks(self) -> list[GeneratedChunk]:
        rows = self.connection.execute("SELECT chunk_json FROM chunks ORDER BY id").fetchall()
        return [GeneratedChunk.model_validate(loads(row["chunk_json"])) for row in rows]

    def append_event(
        self,
        event: Event,
        *,
        patches: Iterable[Patch] | None = None,
        registry: ReducerRegistry | None = None,
    ) -> bool:
        """Append one event and its derived patches.

        Returns True when the event was inserted. Duplicate event IDs are ignored
        so replay/import operations can be idempotent.
        """

        with self.connection:
            cursor = self.connection.execute(
                """
                INSERT OR IGNORE INTO events(id, tick, type, scope, payload_json, schema_version)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    event.id,
                    event.tick,
                    event.type,
                    event.scope,
                    dumps(event.payload),
                    event.schema_version,
                ),
            )
            inserted = cursor.rowcount == 1
            if not inserted:
                return False

            derived = list(patches) if patches is not None else event_to_patches(event, registry)
            for patch in derived:
                self.connection.execute(
                    """
                    INSERT OR IGNORE INTO patches(
                        entity_id, path, value_json, tick, source_event_id, schema_version
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (
                        patch.entity_id,
                        patch.path,
                        dumps(patch.value),
                        patch.tick,
                        patch.source_event_id,
                        patch.schema_version,
                    ),
                )
            return True

    def list_events(self, *, after_tick: int | None = None, limit: int | None = None) -> list[Event]:
        sql = "SELECT * FROM events"
        params: list[Any] = []
        if after_tick is not None:
            sql += " WHERE tick > ?"
            params.append(after_tick)
        sql += " ORDER BY tick, id"
        if limit is not None:
            sql += " LIMIT ?"
            params.append(limit)
        rows = self.connection.execute(sql, params).fetchall()
        return [self._row_to_event(row) for row in rows]

    def list_patches(self, *, entity_id: str | None = None) -> list[Patch]:
        sql = "SELECT * FROM patches"
        params: list[Any] = []
        if entity_id is not None:
            sql += " WHERE entity_id = ?"
            params.append(entity_id)
        sql += " ORDER BY tick, id"
        rows = self.connection.execute(sql, params).fetchall()
        return [self._row_to_patch(row) for row in rows]

    def latest_patch_map(self, entity_id: str) -> dict[str, Any]:
        rows = self.connection.execute(
            """
            SELECT * FROM (
                SELECT
                    p.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY p.path
                        ORDER BY p.tick DESC, p.id DESC
                    ) AS rn
                FROM patches p
                WHERE p.entity_id = ?
            ) ranked
            WHERE rn = 1
            ORDER BY path
            """,
            (entity_id,),
        ).fetchall()
        return {row["path"]: loads(row["value_json"]) for row in rows}

    def resolve_entity(self, entity_id: str, base_state: dict[str, Any] | None = None) -> dict[str, Any]:
        if base_state is None:
            entity = self.find_entity_ref(entity_id)
            if entity is None:
                base_state = {"id": entity_id}
            else:
                base_state = entity_base_state(entity)
        return apply_patch_map(base_state, self.latest_patch_map(entity_id))

    def find_entity_ref(self, entity_id: str) -> dict[str, Any] | None:
        for chunk in self.list_chunks():
            for entity in chunk.entities:
                if entity.id == entity_id:
                    return entity.model_dump(mode="json")
        return None

    def build_materialized_state(self) -> dict[str, Any]:
        entities: dict[str, dict[str, Any]] = {}
        for chunk in self.list_chunks():
            for entity in chunk.entities:
                entities[entity.id] = self.resolve_entity(entity.id, entity_base_state(entity))
        return {
            "chunks": [chunk.model_dump(mode="json") for chunk in self.list_chunks()],
            "entities": entities,
        }

    def create_snapshot(self, *, tick: int | None = None, state: dict[str, Any] | None = None) -> Snapshot:
        event_count = self.count_events()
        if tick is None:
            tick = self.latest_tick()
        if state is None:
            state = self.build_materialized_state()
        snapshot_id = stable_id("snapshot", tick, event_count)
        snapshot = Snapshot(id=snapshot_id, tick=tick, event_count=event_count, state=state)
        self.connection.execute(
            """
            INSERT INTO snapshots(id, tick, event_count, state_json, schema_version)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                event_count = excluded.event_count,
                state_json = excluded.state_json,
                schema_version = excluded.schema_version,
                created_at = CURRENT_TIMESTAMP
            """,
            (snapshot.id, snapshot.tick, snapshot.event_count, dumps(snapshot.state), snapshot.schema_version),
        )
        self.connection.commit()
        return snapshot

    def latest_snapshot(self) -> Snapshot | None:
        row = self.connection.execute(
            "SELECT * FROM snapshots ORDER BY tick DESC, event_count DESC LIMIT 1"
        ).fetchone()
        if row is None:
            return None
        return Snapshot(
            id=row["id"],
            tick=int(row["tick"]),
            event_count=int(row["event_count"]),
            state=loads(row["state_json"]),
            schema_version=row["schema_version"],
        )

    def count_events(self) -> int:
        return int(self.connection.execute("SELECT COUNT(*) AS total FROM events").fetchone()["total"])

    def count_patches(self) -> int:
        return int(self.connection.execute("SELECT COUNT(*) AS total FROM patches").fetchone()["total"])

    def count_chunks(self) -> int:
        return int(self.connection.execute("SELECT COUNT(*) AS total FROM chunks").fetchone()["total"])

    def count_snapshots(self) -> int:
        return int(self.connection.execute("SELECT COUNT(*) AS total FROM snapshots").fetchone()["total"])

    def latest_tick(self) -> int:
        row = self.connection.execute("SELECT COALESCE(MAX(tick), 0) AS tick FROM events").fetchone()
        return int(row["tick"])

    def metadata(self) -> dict[str, Any]:
        rows = self.connection.execute("SELECT key, value_json FROM metadata ORDER BY key").fetchall()
        return {row["key"]: loads(row["value_json"]) for row in rows}

    def stats(self) -> dict[str, Any]:
        snapshot = self.latest_snapshot()
        return {
            "chunks": self.count_chunks(),
            "events": self.count_events(),
            "patches": self.count_patches(),
            "snapshots": self.count_snapshots(),
            "latest_tick": self.latest_tick(),
            "latest_snapshot_id": snapshot.id if snapshot else None,
            "schema_version": self.get_metadata("storage_schema_version", "storage.v1"),
        }

    @staticmethod
    def _row_to_event(row: sqlite3.Row) -> Event:
        return Event(
            id=row["id"],
            tick=int(row["tick"]),
            type=row["type"],
            scope=row["scope"],
            payload=loads(row["payload_json"]),
            schema_version=row["schema_version"],
        )

    @staticmethod
    def _row_to_patch(row: sqlite3.Row) -> Patch:
        return Patch(
            entity_id=row["entity_id"],
            path=row["path"],
            value=loads(row["value_json"]),
            tick=int(row["tick"]),
            source_event_id=row["source_event_id"],
            schema_version=row["schema_version"],
        )

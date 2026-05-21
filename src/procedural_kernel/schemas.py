"""Pydantic schemas used at package boundaries.

Internal hot paths can use dataclasses/dicts later, but public inputs and exports
should be validated and versioned.
"""

from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


class WorldConfig(BaseModel):
    model_config = ConfigDict(extra="forbid")

    seed: str = "procedural-kernel-dev"
    world_version: str = "0.1.2"
    schema_version: str = "world.v1"
    snapshot_every_events: int = Field(default=1000, ge=1)


class ChunkKey(BaseModel):
    model_config = ConfigDict(extra="forbid")

    layer: str
    x: int
    y: int
    region: str = "world"
    version: str = "0.1"


class EntityRef(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    kind: str
    chunk_id: str
    metadata: dict[str, Any] = Field(default_factory=dict)


class Event(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    tick: int = Field(ge=0)
    type: str
    scope: str = "world"
    payload: dict[str, Any] = Field(default_factory=dict)
    schema_version: str = "event.v1"


class Patch(BaseModel):
    model_config = ConfigDict(extra="forbid")

    entity_id: str
    path: str
    value: Any
    tick: int = Field(ge=0)
    source_event_id: str
    schema_version: str = "patch.v1"


class GeneratedChunk(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    key: ChunkKey
    seed: int
    terrain_score: float
    danger_score: float
    resource_score: float
    entities: list[EntityRef] = Field(default_factory=list)
    schema_version: Literal["chunk.v1"] = "chunk.v1"


class Snapshot(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    tick: int = Field(ge=0)
    event_count: int = Field(ge=0)
    state: dict[str, Any] = Field(default_factory=dict)
    schema_version: Literal["snapshot.v1"] = "snapshot.v1"

"""Event construction and reducer primitives."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any

from procedural_kernel.ids import event_id
from procedural_kernel.schemas import Event, Patch

Reducer = Callable[[Event], list[Patch]]


class ReducerRegistry:
    """Small reducer registry for event-type based patch generation."""

    def __init__(self) -> None:
        self._reducers: dict[str, Reducer] = {}

    def register(self, event_type: str, reducer: Reducer) -> None:
        if not event_type:
            raise ValueError("event_type is required")
        self._reducers[event_type] = reducer

    def reduce(self, event: Event) -> list[Patch]:
        reducer = self._reducers.get(event.type)
        if reducer is None:
            return []
        return reducer(event)


def make_event(
    event_type: str,
    *,
    tick: int,
    scope: str = "world",
    payload: dict[str, Any] | None = None,
    explicit_id: str | None = None,
) -> Event:
    """Create a stable event object from explicit inputs."""

    payload = payload or {}
    eid = explicit_id or event_id(event_type, tick, scope, payload)
    return Event(id=eid, tick=tick, type=event_type, scope=scope, payload=payload)


def _patch(event: Event, entity_id: str, path: str, value: Any) -> Patch:
    return Patch(
        entity_id=entity_id,
        path=path,
        value=value,
        tick=event.tick,
        source_event_id=event.id,
    )


def reduce_npc_killed(event: Event) -> list[Patch]:
    entity_id = str(event.payload["entity_id"])
    patches = [
        _patch(event, entity_id, "alive", False),
        _patch(event, entity_id, "death.tick", event.tick),
    ]
    if "killed_by" in event.payload:
        patches.append(_patch(event, entity_id, "death.killed_by", event.payload["killed_by"]))
    if "reason" in event.payload:
        patches.append(_patch(event, entity_id, "death.reason", event.payload["reason"]))
    return patches


def reduce_entity_patch(event: Event) -> list[Patch]:
    return [
        _patch(
            event,
            entity_id=str(event.payload["entity_id"]),
            path=str(event.payload["path"]),
            value=event.payload.get("value"),
        )
    ]


def reduce_entity_patches(event: Event) -> list[Patch]:
    entity_id = str(event.payload["entity_id"])
    raw_patches = event.payload.get("patches", {})
    if not isinstance(raw_patches, dict):
        raise ValueError("entity.patches payload requires a 'patches' object")
    return [_patch(event, entity_id, str(path), value) for path, value in raw_patches.items()]


def default_registry() -> ReducerRegistry:
    registry = ReducerRegistry()
    registry.register("npc.killed", reduce_npc_killed)
    registry.register("entity.patch", reduce_entity_patch)
    registry.register("entity.patches", reduce_entity_patches)
    return registry


def event_to_patches(event: Event, registry: ReducerRegistry | None = None) -> list[Patch]:
    """Reduce one event into zero or more materialized patches."""

    return (registry or default_registry()).reduce(event)

"""Replay helpers for rebuilding patch overlays from an event stream."""

from __future__ import annotations

from collections.abc import Iterable
from typing import Any

from procedural_kernel.events import ReducerRegistry, event_to_patches
from procedural_kernel.schemas import Event, Patch
from procedural_kernel.state import apply_patches


def replay_patches(
    events: Iterable[Event], *, registry: ReducerRegistry | None = None
) -> list[Patch]:
    """Reduce an ordered event stream into materialized patches."""

    patches: list[Patch] = []
    for event in sorted(events, key=lambda item: (item.tick, item.id)):
        patches.extend(event_to_patches(event, registry))
    return patches


def replay_entity_state(
    events: Iterable[Event],
    *,
    entity_id: str,
    base_state: dict[str, Any] | None = None,
    registry: ReducerRegistry | None = None,
) -> dict[str, Any]:
    """Rebuild one entity state from events only."""

    base = {"id": entity_id} if base_state is None else dict(base_state)
    patches = [patch for patch in replay_patches(events, registry=registry) if patch.entity_id == entity_id]
    return apply_patches(base, patches)

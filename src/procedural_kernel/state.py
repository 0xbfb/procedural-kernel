"""State overlays built from deterministic base data plus persisted patches."""

from __future__ import annotations

from copy import deepcopy
from typing import Any, Iterable, Mapping

from procedural_kernel.schemas import EntityRef, Patch


def entity_base_state(entity: EntityRef | Mapping[str, Any]) -> dict[str, Any]:
    """Create a minimal materialized state for an entity reference.

    The base state is deterministic and intentionally small. Domain projects can
    extend it before applying patches, but this gives the kernel stable defaults.
    """

    if isinstance(entity, EntityRef):
        entity_id = entity.id
        kind = entity.kind
        chunk_id = entity.chunk_id
        metadata = dict(entity.metadata)
    else:
        entity_id = str(entity["id"])
        kind = str(entity["kind"])
        chunk_id = str(entity["chunk_id"])
        metadata = dict(entity.get("metadata", {}))

    state: dict[str, Any] = {
        "id": entity_id,
        "kind": kind,
        "chunk_id": chunk_id,
        "metadata": metadata,
    }
    if kind == "npc":
        state["alive"] = True
    return state


def set_path(target: dict[str, Any], path: str, value: Any) -> dict[str, Any]:
    """Set a dotted path on a dictionary and return the mutated dictionary."""

    if not path or path.startswith(".") or path.endswith("."):
        raise ValueError("patch path must be a non-empty dotted path")

    current: dict[str, Any] = target
    parts = path.split(".")
    for part in parts[:-1]:
        if not part:
            raise ValueError("patch path cannot contain empty segments")
        next_value = current.get(part)
        if not isinstance(next_value, dict):
            next_value = {}
            current[part] = next_value
        current = next_value

    leaf = parts[-1]
    if not leaf:
        raise ValueError("patch path cannot contain empty segments")
    current[leaf] = value
    return target


def get_path(target: Mapping[str, Any], path: str, default: Any = None) -> Any:
    """Read a dotted path from a nested mapping."""

    current: Any = target
    for part in path.split("."):
        if not isinstance(current, Mapping) or part not in current:
            return default
        current = current[part]
    return current


def apply_patches(base_state: Mapping[str, Any], patches: Iterable[Patch]) -> dict[str, Any]:
    """Return a resolved state by applying patches over a base state copy."""

    resolved = deepcopy(dict(base_state))
    ordered = sorted(patches, key=lambda patch: (patch.tick, patch.source_event_id, patch.path))
    for patch in ordered:
        set_path(resolved, patch.path, deepcopy(patch.value))
    return resolved


def apply_patch_map(base_state: Mapping[str, Any], patch_map: Mapping[str, Any]) -> dict[str, Any]:
    """Apply the latest value per path over a base state copy."""

    resolved = deepcopy(dict(base_state))
    for path, value in sorted(patch_map.items()):
        set_path(resolved, path, deepcopy(value))
    return resolved

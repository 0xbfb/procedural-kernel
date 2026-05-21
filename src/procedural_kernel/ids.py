"""Stable identifiers for procedural entities."""

from __future__ import annotations

import re
from typing import Any

from procedural_kernel.rng import stable_hash_bytes

_SLUG_RE = re.compile(r"[^a-zA-Z0-9_.:-]+")


def slug(value: Any) -> str:
    """Return a conservative slug that remains readable in JSON and filenames."""

    raw = str(value).strip().lower()
    raw = _SLUG_RE.sub("-", raw).strip("-")
    return raw or "empty"


def stable_id(kind: str, *parts: Any, digest_size: int = 6) -> str:
    """Create a stable ID with a readable prefix and compact digest suffix."""

    safe_kind = slug(kind)
    readable = ":".join(slug(part) for part in parts if str(part) != "")
    digest = stable_hash_bytes(safe_kind, *parts, digest_size=digest_size).hex()
    if readable:
        return f"{safe_kind}:{readable}:{digest}"
    return f"{safe_kind}:{digest}"


def chunk_id(layer: str, x: int, y: int, region: str = "world", version: str = "0.1") -> str:
    return stable_id("chunk", version, region, layer, x, y)


def entity_id(kind: str, chunk: str, role: str, ordinal: int = 0) -> str:
    return stable_id("entity", kind, chunk, role, ordinal)


def event_id(event_type: str, tick: int, scope: str, *parts: Any) -> str:
    """Create a stable event ID without embedding large payloads in the readable prefix."""

    digest = stable_hash_bytes("event", event_type, tick, scope, *parts, digest_size=6).hex()
    return f"event:{slug(event_type)}:{slug(tick)}:{slug(scope)}:{digest}"

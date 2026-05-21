"""Deterministic seed derivation and RNG helpers.

The core rule is simple: every generated value must be derived from explicit
inputs. No timestamps, global counters, process IDs, or platform-local paths.
"""

from __future__ import annotations

from hashlib import blake2b
from typing import Any

import numpy as np

_SEP = ""
_UINT64_MAX = (1 << 64) - 1


def _normalize_part(part: Any) -> str:
    if isinstance(part, bytes):
        return part.hex()
    if isinstance(part, float):
        return repr(part)
    return str(part)


def stable_hash_bytes(*parts: Any, digest_size: int = 16) -> bytes:
    """Return a stable BLAKE2b digest for explicit namespace parts."""

    if not parts:
        raise ValueError("stable_hash_bytes requires at least one part")

    h = blake2b(digest_size=digest_size)
    for part in parts:
        h.update(_normalize_part(part).encode("utf-8"))
        h.update(_SEP.encode("utf-8"))
    return h.digest()


def stable_int(*parts: Any, bits: int = 64) -> int:
    """Return a deterministic unsigned integer derived from the given parts."""

    if bits <= 0 or bits > 128:
        raise ValueError("bits must be between 1 and 128")
    digest = stable_hash_bytes(*parts, digest_size=16)
    value = int.from_bytes(digest, byteorder="big", signed=False)
    if bits == 128:
        return value
    return value & ((1 << bits) - 1)


def derive_seed(world_seed: str | int, *namespace: Any) -> int:
    """Derive a NumPy-compatible seed from a root seed and namespace."""

    return stable_int("seed", world_seed, *namespace, bits=64) & _UINT64_MAX


def rng_for(world_seed: str | int, *namespace: Any) -> np.random.Generator:
    """Create a deterministic NumPy Generator for a namespace."""

    return np.random.default_rng(derive_seed(world_seed, *namespace))

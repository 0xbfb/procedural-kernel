"""Deterministic chunk generation primitives."""

from __future__ import annotations

from procedural_kernel.ids import chunk_id, entity_id
from procedural_kernel.rng import derive_seed, rng_for
from procedural_kernel.schemas import ChunkKey, EntityRef, GeneratedChunk


def generate_chunk(
    *,
    seed: str | int,
    layer: str,
    x: int,
    y: int,
    region: str = "world",
    version: str = "0.1",
    entity_count: int = 4,
) -> GeneratedChunk:
    """Generate a small deterministic chunk summary.

    This is intentionally modest. Later prompts will add persistent overlays,
    simulation and export contracts.
    """

    if entity_count < 0:
        raise ValueError("entity_count must be >= 0")

    key = ChunkKey(layer=layer, x=x, y=y, region=region, version=version)
    cid = chunk_id(layer=layer, x=x, y=y, region=region, version=version)
    derived = derive_seed(seed, "chunk", version, region, layer, x, y)
    rng = rng_for(seed, "chunk", version, region, layer, x, y)

    terrain_score = float(rng.random())
    danger_score = float(rng.random())
    resource_score = float(rng.random())

    roles = ["keeper", "trader", "wanderer", "guard", "witness", "artisan"]
    entities: list[EntityRef] = []
    for ordinal in range(entity_count):
        role = roles[int(rng.integers(0, len(roles)))]
        kind = "npc" if ordinal % 2 == 0 else "poi"
        entities.append(
            EntityRef(
                id=entity_id(kind, cid, role, ordinal),
                kind=kind,
                chunk_id=cid,
                metadata={"role": role, "ordinal": ordinal},
            )
        )

    return GeneratedChunk(
        id=cid,
        key=key,
        seed=derived,
        terrain_score=terrain_score,
        danger_score=danger_score,
        resource_score=resource_score,
        entities=entities,
    )

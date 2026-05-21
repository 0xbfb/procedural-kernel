"""Small deterministic benchmarks for procedural generation hot paths."""

from __future__ import annotations

from dataclasses import dataclass
from time import perf_counter
from typing import Any

from procedural_kernel.chunks import generate_chunk
from procedural_kernel.rng import stable_hash_bytes


@dataclass(frozen=True)
class BenchmarkResult:
    """Serializable benchmark result."""

    ok: bool
    seed: str
    requested_entities: int
    generated_entities: int
    chunks: int
    entities_per_chunk: int
    seconds: float
    entities_per_second: float
    digest: str

    def as_dict(self) -> dict[str, Any]:
        return {
            "ok": self.ok,
            "seed": self.seed,
            "requested_entities": self.requested_entities,
            "generated_entities": self.generated_entities,
            "chunks": self.chunks,
            "entities_per_chunk": self.entities_per_chunk,
            "seconds": round(self.seconds, 6),
            "entities_per_second": round(self.entities_per_second, 2),
            "digest": self.digest,
        }


def run_generation_benchmark(
    *,
    entities: int = 10_000,
    seed: str = "procedural-kernel-benchmark",
    entities_per_chunk: int = 128,
) -> BenchmarkResult:
    """Generate deterministic chunks until the requested entity count is reached."""

    if entities < 1:
        raise ValueError("entities must be >= 1")
    if entities_per_chunk < 1:
        raise ValueError("entities_per_chunk must be >= 1")

    start = perf_counter()
    generated = 0
    chunks = 0
    first_entity_id: str | None = None
    last_entity_id: str | None = None
    score_accumulator = 0.0

    while generated < entities:
        remaining = entities - generated
        current_count = min(entities_per_chunk, remaining)
        chunk = generate_chunk(
            seed=seed,
            layer="benchmark",
            region="bench",
            x=chunks,
            y=chunks % 17,
            entity_count=current_count,
        )
        if chunk.entities:
            first_entity_id = first_entity_id or chunk.entities[0].id
            last_entity_id = chunk.entities[-1].id
        score_accumulator += chunk.terrain_score + chunk.danger_score + chunk.resource_score
        generated += len(chunk.entities)
        chunks += 1

    seconds = perf_counter() - start
    entities_per_second = generated / seconds if seconds > 0 else float("inf")
    digest = "benchmark:" + stable_hash_bytes(
        seed,
        entities,
        chunks,
        first_entity_id or "none",
        last_entity_id or "none",
        round(score_accumulator, 8),
        digest_size=12,
    ).hex()
    return BenchmarkResult(
        ok=True,
        seed=seed,
        requested_entities=entities,
        generated_entities=generated,
        chunks=chunks,
        entities_per_chunk=entities_per_chunk,
        seconds=seconds,
        entities_per_second=entities_per_second,
        digest=digest,
    )

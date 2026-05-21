from procedural_kernel.chunks import generate_chunk
from procedural_kernel.serialization import dumps, loads


def test_same_seed_same_chunk():
    a = generate_chunk(seed="s", layer="city", x=10, y=3)
    b = generate_chunk(seed="s", layer="city", x=10, y=3)
    assert a == b


def test_different_seed_changes_chunk_values():
    a = generate_chunk(seed="s1", layer="city", x=10, y=3)
    b = generate_chunk(seed="s2", layer="city", x=10, y=3)
    assert a.id == b.id
    assert a.seed != b.seed
    assert (a.terrain_score, a.danger_score, a.resource_score) != (
        b.terrain_score,
        b.danger_score,
        b.resource_score,
    )


def test_serialization_roundtrip():
    chunk = generate_chunk(seed="s", layer="forest", x=1, y=2)
    encoded = dumps(chunk)
    decoded = loads(encoded)
    assert decoded["id"] == chunk.id
    assert decoded["schema_version"] == "chunk.v1"

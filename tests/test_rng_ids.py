from procedural_kernel.ids import chunk_id, entity_id
from procedural_kernel.rng import derive_seed, stable_int


def test_same_seed_same_integer():
    assert stable_int("world", "chunk", 1, 2) == stable_int("world", "chunk", 1, 2)


def test_different_seed_different_integer():
    assert stable_int("world-a", "chunk", 1, 2) != stable_int("world-b", "chunk", 1, 2)


def test_derive_seed_is_stable():
    assert derive_seed("root", "city", 10, 3) == derive_seed("root", "city", 10, 3)


def test_chunk_id_is_stable():
    assert chunk_id("city", 10, 3) == chunk_id("city", 10, 3)


def test_entity_id_is_stable():
    cid = chunk_id("city", 10, 3)
    assert entity_id("npc", cid, "blacksmith", 0) == entity_id("npc", cid, "blacksmith", 0)

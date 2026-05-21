from procedural_kernel.chunks import generate_chunk
from procedural_kernel.events import event_to_patches, make_event
from procedural_kernel.replay import replay_entity_state, replay_patches
from procedural_kernel.state import entity_base_state
from procedural_kernel.storage import SQLiteStore


def test_npc_killed_event_reduces_to_persistent_patches():
    chunk = generate_chunk(seed="s", layer="city", x=1, y=2)
    npc = next(entity for entity in chunk.entities if entity.kind == "npc")
    event = make_event(
        "npc.killed",
        tick=10,
        scope=chunk.id,
        payload={"entity_id": npc.id, "killed_by": "player"},
    )

    with SQLiteStore(":memory:") as store:
        store.store_chunk(chunk)
        assert store.append_event(event) is True
        assert store.append_event(event) is False

        assert store.count_events() == 1
        assert store.count_patches() == 3
        state = store.resolve_entity(npc.id)

    assert state["alive"] is False
    assert state["death"]["tick"] == 10
    assert state["death"]["killed_by"] == "player"


def test_entity_patch_latest_value_wins_per_path():
    chunk = generate_chunk(seed="s", layer="city", x=1, y=2)
    npc = next(entity for entity in chunk.entities if entity.kind == "npc")

    with SQLiteStore(":memory:") as store:
        store.store_chunk(chunk)
        store.append_event(
            make_event(
                "entity.patch",
                tick=2,
                scope=chunk.id,
                payload={"entity_id": npc.id, "path": "stats.fear", "value": 0.1},
            )
        )
        store.append_event(
            make_event(
                "entity.patch",
                tick=10,
                scope=chunk.id,
                payload={"entity_id": npc.id, "path": "stats.fear", "value": 0.9},
            )
        )
        state = store.resolve_entity(npc.id)

    assert state["stats"]["fear"] == 0.9


def test_snapshot_materializes_chunk_entities_and_patches():
    chunk = generate_chunk(seed="s", layer="city", x=1, y=2)
    npc = next(entity for entity in chunk.entities if entity.kind == "npc")

    with SQLiteStore(":memory:") as store:
        store.store_chunk(chunk)
        store.append_event(
            make_event(
                "npc.killed",
                tick=1,
                scope=chunk.id,
                payload={"entity_id": npc.id},
            )
        )
        snapshot = store.create_snapshot()
        latest = store.latest_snapshot()

    assert latest is not None
    assert latest.id == snapshot.id
    assert latest.state["entities"][npc.id]["alive"] is False


def test_replay_from_events_matches_store_resolution():
    chunk = generate_chunk(seed="s", layer="city", x=1, y=2)
    npc = next(entity for entity in chunk.entities if entity.kind == "npc")
    event = make_event(
        "npc.killed",
        tick=1,
        scope=chunk.id,
        payload={"entity_id": npc.id, "killed_by": "player"},
    )

    with SQLiteStore(":memory:") as store:
        store.store_chunk(chunk)
        store.append_event(event)
        stored_state = store.resolve_entity(npc.id)
        replayed_state = replay_entity_state(
            store.list_events(), entity_id=npc.id, base_state=entity_base_state(npc)
        )

    assert replayed_state == stored_state


def test_unknown_event_generates_no_patches():
    event = make_event("unknown.event", tick=1, payload={"anything": True})
    assert event_to_patches(event) == []
    assert replay_patches([event]) == []

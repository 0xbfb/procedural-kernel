from procedural_kernel.chunks import generate_chunk
from procedural_kernel.decisions import DecisionOption, choose_decision
from procedural_kernel.events import make_event
from procedural_kernel.future import FutureEventQueue
from procedural_kernel.replay import replay_entity_state
from procedural_kernel.simulation import run_temporal_simulation
from procedural_kernel.state import entity_base_state
from procedural_kernel.storage import SQLiteStore


def test_decision_is_deterministic_with_same_context_and_seed():
    options = [
        DecisionOption("flee", weights={"fear": 1.0}, bias=0.1),
        DecisionOption("talk", weights={"trust": 1.0}, bias=0.1),
    ]
    context = {"fear": 0.8, "trust": 0.2}

    first = choose_decision(options=options, context=context, seed="s", namespace="npc:1")
    second = choose_decision(options=options, context=context, seed="s", namespace="npc:1")

    assert first.as_dict() == second.as_dict()
    assert first.selected == "flee"


def test_decision_changes_when_context_or_weights_change():
    options = [
        DecisionOption("flee", weights={"fear": 1.0}, bias=0.0),
        DecisionOption("talk", weights={"trust": 1.0}, bias=0.0),
    ]

    afraid = choose_decision(options=options, context={"fear": 0.9, "trust": 0.1}, seed="s")
    trusting = choose_decision(options=options, context={"fear": 0.1, "trust": 0.9}, seed="s")

    assert afraid.selected == "flee"
    assert trusting.selected == "talk"


def test_future_events_process_by_tick_then_stable_id():
    later = make_event("entity.patch", tick=5, scope="s", payload={"entity_id": "e", "path": "v", "value": 3})
    early_b = make_event("entity.patch", tick=1, scope="s", payload={"entity_id": "e", "path": "b", "value": 2})
    early_a = make_event("entity.patch", tick=1, scope="s", payload={"entity_id": "e", "path": "a", "value": 1})

    queue = FutureEventQueue([later, early_b, early_a])
    drained = queue.drain()

    assert [event.tick for event in drained] == [1, 1, 5]
    assert [event.id for event in drained[:2]] == sorted([early_a.id, early_b.id])


def test_temporal_simulation_persists_events_and_patches(tmp_path):
    db = tmp_path / "sim.sqlite"
    report = run_temporal_simulation(db_path=db, seed="sim", events=12)

    assert report["ok"] is True
    assert report["stats"]["events"] == 12
    assert report["stats"]["patches"] >= 12
    assert report["stats"]["snapshots"] == 1
    processed_ticks = [event["tick"] for event in report["processed_events"]]
    assert processed_ticks == sorted(processed_ticks)

    with SQLiteStore(db) as store:
        assert store.count_events() == 12
        assert store.count_patches() >= 12
        assert store.latest_snapshot() is not None


def test_replay_after_temporal_simulation_matches_store_state(tmp_path):
    db = tmp_path / "sim.sqlite"
    report = run_temporal_simulation(db_path=db, seed="replay", events=9)
    entity_id = report["target_entity_id"]

    with SQLiteStore(db) as store:
        entity = store.find_entity_ref(entity_id)
        assert entity is not None
        stored_state = store.resolve_entity(entity_id)
        replayed_state = replay_entity_state(
            store.list_events(),
            entity_id=entity_id,
            base_state=entity_base_state(entity),
        )

    assert replayed_state == stored_state


def test_region_discovery_style_patch_is_replayable(tmp_path):
    chunk = generate_chunk(seed="region", layer="city", x=0, y=0)
    player_id = "player:1"
    event = make_event(
        "entity.patch",
        tick=3,
        scope=chunk.id,
        payload={"entity_id": player_id, "path": "discovered.current_chunk", "value": True},
    )

    with SQLiteStore(tmp_path / "state.sqlite") as store:
        store.store_chunk(chunk)
        store.append_event(event)
        state = store.resolve_entity(player_id)

    assert state["discovered"]["current_chunk"] is True

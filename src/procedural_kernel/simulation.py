"""Deterministic temporal simulations for CLI smoke checks and tests."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from procedural_kernel.chunks import generate_chunk
from procedural_kernel.decisions import DecisionOption, choose_decision
from procedural_kernel.events import make_event
from procedural_kernel.future import FutureEventQueue
from procedural_kernel.ids import stable_id
from procedural_kernel.storage import SQLiteStore


def default_simulation_options() -> list[DecisionOption]:
    """Return a small auditable action set for the demo simulation."""

    return [
        DecisionOption(
            "kill_npc",
            weights={"danger": 1.10, "resources": -0.20, "stability": -0.35},
            bias=0.05,
        ),
        DecisionOption(
            "discover_region",
            weights={"resources": 0.75, "danger": -0.25, "stability": 0.15},
            bias=0.15,
        ),
        DecisionOption(
            "remember_marker",
            weights={"memory_pressure": 0.80, "danger": 0.10},
            bias=0.10,
        ),
        DecisionOption(
            "shift_reputation",
            weights={"stability": 0.65, "resources": 0.20, "danger": -0.10},
            bias=0.08,
        ),
    ]


def _event_from_decision(
    *,
    selected: str,
    tick: int,
    ordinal: int,
    scope: str,
    npc_id: str,
    player_id: str,
    faction_id: str,
    score: float,
) -> Any:
    if selected == "kill_npc":
        return make_event(
            "npc.killed",
            tick=tick,
            scope=scope,
            payload={
                "entity_id": npc_id,
                "killed_by": "simulation",
                "reason": "utility_score",
                "ordinal": ordinal,
            },
        )
    if selected == "discover_region":
        return make_event(
            "entity.patch",
            tick=tick,
            scope=scope,
            payload={
                "entity_id": player_id,
                "path": f"discovered.{stable_id('chunk_ref', scope).replace(':', '_').replace('.', '_')}",
                "value": True,
                "ordinal": ordinal,
            },
        )
    if selected == "shift_reputation":
        return make_event(
            "entity.patch",
            tick=tick,
            scope=scope,
            payload={
                "entity_id": faction_id,
                "path": "reputation.player",
                "value": round(score, 6),
                "ordinal": ordinal,
            },
        )
    return make_event(
        "entity.patch",
        tick=tick,
        scope=scope,
        payload={
            "entity_id": npc_id,
            "path": f"memory.event_{ordinal}",
            "value": {"tick": tick, "kind": selected, "score": round(score, 6)},
            "ordinal": ordinal,
        },
    )


def run_temporal_simulation(
    *,
    db_path: str | Path = ":memory:",
    seed: str = "procedural-kernel-sim",
    layer: str = "city",
    x: int = 0,
    y: int = 0,
    events: int = 2,
    snapshot: bool = True,
) -> dict[str, Any]:
    """Generate one chunk, schedule decisions as future events, then persist due events."""

    if events < 1:
        raise ValueError("events must be >= 1")

    with SQLiteStore(db_path) as store:
        chunk = generate_chunk(seed=seed, layer=layer, x=x, y=y, entity_count=4)
        store.store_chunk(chunk)
        target = next(entity for entity in chunk.entities if entity.kind == "npc")
        player_id = stable_id("entity", "player", seed, "simulation")
        faction_id = stable_id("faction", chunk.id, "locals")

        queue = FutureEventQueue()
        decisions: list[dict[str, Any]] = []
        options = default_simulation_options()
        max_tick_window = max(1, min(events, 9))

        for ordinal in range(1, events + 1):
            context = {
                "danger": chunk.danger_score,
                "resources": chunk.resource_score,
                "stability": 1.0 - chunk.danger_score,
                "memory_pressure": ordinal / events,
            }
            decision = choose_decision(
                options=options,
                context=context,
                seed=seed,
                namespace=f"{chunk.id}:{ordinal}",
            )
            # Non-monotonic scheduling proves the future queue, not insertion order,
            # determines processing order. The ordinal remains in payload for uniqueness.
            tick = 1 + ((ordinal * 7) % max_tick_window)
            event = _event_from_decision(
                selected=decision.selected,
                tick=tick,
                ordinal=ordinal,
                scope=chunk.id,
                npc_id=target.id,
                player_id=player_id,
                faction_id=faction_id,
                score=decision.score,
            )
            queue.push(event)
            decisions.append(
                {
                    "ordinal": ordinal,
                    "tick": tick,
                    "selected": decision.selected,
                    "score": decision.score,
                    "event_id": event.id,
                    "breakdowns": [
                        {
                            "option": item.option,
                            "score": item.score,
                            "contributions": item.contributions,
                        }
                        for item in decision.breakdowns
                    ],
                }
            )

        processed_events = queue.drain()
        for event in processed_events:
            store.append_event(event)

        snap = store.create_snapshot() if snapshot else None
        resolved = store.resolve_entity(target.id)
        return {
            "ok": True,
            "db_path": str(db_path),
            "chunk_id": chunk.id,
            "target_entity_id": target.id,
            "player_entity_id": player_id,
            "faction_id": faction_id,
            "target_state": resolved,
            "snapshot_id": snap.id if snap else None,
            "stats": store.stats(),
            "decisions": decisions,
            "processed_events": [event.model_dump(mode="json") for event in processed_events],
        }


def run_minimal_simulation(**kwargs: Any) -> dict[str, Any]:
    """Backward-compatible wrapper kept for earlier prompt tests."""

    return run_temporal_simulation(**kwargs)

"""Minimal Procedural Kernel usage example."""

from pathlib import Path
from tempfile import TemporaryDirectory

from procedural_kernel.chunks import generate_chunk
from procedural_kernel.events import make_event
from procedural_kernel.exporters.json_bundle import write_json_bundle
from procedural_kernel.storage import SQLiteStore


def main() -> None:
    chunk = generate_chunk(seed="example", layer="city", x=1, y=2)
    npc = next(entity for entity in chunk.entities if entity.kind == "npc")

    with TemporaryDirectory() as tmp:
        db = Path(tmp) / "example.sqlite"
        out = Path(tmp) / "world_bundle.json"
        with SQLiteStore(db) as store:
            store.store_chunk(chunk)
            store.append_event(
                make_event(
                    "npc.killed",
                    tick=1,
                    scope=chunk.id,
                    payload={"entity_id": npc.id, "killed_by": "example"},
                )
            )
            resolved = store.resolve_entity(npc.id)
            assert resolved["alive"] is False
            summary = write_json_bundle(store, out, seed="example")

        print({"entity_id": npc.id, "alive": resolved["alive"], "export": summary})


if __name__ == "__main__":
    main()

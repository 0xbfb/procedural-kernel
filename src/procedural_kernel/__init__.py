"""Procedural Kernel: deterministic procedural data primitives for game engines."""

from procedural_kernel.benchmark import run_generation_benchmark
from procedural_kernel.chunks import generate_chunk
from procedural_kernel.decisions import DecisionOption, DecisionResult, choose_decision
from procedural_kernel.events import event_to_patches, make_event
from procedural_kernel.exporters import export_json_bundle, write_json_bundle
from procedural_kernel.future import FutureEventQueue
from procedural_kernel.ids import chunk_id, entity_id, event_id, stable_id
from procedural_kernel.rng import derive_seed, stable_int
from procedural_kernel.schemas import ChunkKey, EntityRef, Event, Patch, Snapshot, WorldConfig
from procedural_kernel.storage import SQLiteStore

__all__ = [
    "ChunkKey",
    "EntityRef",
    "DecisionOption",
    "DecisionResult",
    "Event",
    "Patch",
    "FutureEventQueue",
    "SQLiteStore",
    "Snapshot",
    "WorldConfig",
    "export_json_bundle",
    "choose_decision",
    "chunk_id",
    "derive_seed",
    "entity_id",
    "event_id",
    "event_to_patches",
    "generate_chunk",
    "run_generation_benchmark",
    "make_event",
    "stable_id",
    "stable_int",
    "write_json_bundle",
]

__version__ = "0.1.3.1"

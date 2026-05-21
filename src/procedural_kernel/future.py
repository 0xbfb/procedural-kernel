"""Simple deterministic future-event queue ordered by tick and stable ID."""

from __future__ import annotations

from dataclasses import dataclass, field
from heapq import heappop, heappush

from procedural_kernel.schemas import Event


@dataclass(order=True, frozen=True)
class ScheduledEvent:
    """Event scheduled for future processing."""

    tick: int
    event_id: str
    event: Event = field(compare=False)

    @classmethod
    def from_event(cls, event: Event) -> "ScheduledEvent":
        return cls(tick=event.tick, event_id=event.id, event=event)


class FutureEventQueue:
    """Priority queue for future events.

    Sorting rule is deliberately boring and auditable: lower tick first, then
    stable event ID. That gives deterministic behavior across platforms.
    """

    def __init__(self, events: list[Event] | None = None) -> None:
        self._heap: list[ScheduledEvent] = []
        for event in events or []:
            self.push(event)

    def __len__(self) -> int:
        return len(self._heap)

    def push(self, event: Event) -> None:
        heappush(self._heap, ScheduledEvent.from_event(event))

    def peek(self) -> Event | None:
        if not self._heap:
            return None
        return self._heap[0].event

    def pop_due(self, *, up_to_tick: int) -> list[Event]:
        due: list[Event] = []
        while self._heap and self._heap[0].tick <= up_to_tick:
            due.append(heappop(self._heap).event)
        return due

    def drain(self) -> list[Event]:
        due: list[Event] = []
        while self._heap:
            due.append(heappop(self._heap).event)
        return due

    def to_list(self) -> list[Event]:
        return [item.event for item in sorted(self._heap)]

"""Pure scoring primitives for lightweight deterministic decisions.

The module intentionally avoids a DSL. A decision is just explicit feature
weights plus deterministic tie-breaking derived from explicit inputs.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Mapping

from procedural_kernel.rng import stable_int
from procedural_kernel.serialization import dumps, to_plain

Number = int | float | bool


@dataclass(frozen=True)
class DecisionOption:
    """One possible action with auditable scoring weights."""

    name: str
    weights: Mapping[str, float]
    bias: float = 0.0
    payload: Mapping[str, Any] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if not self.name:
            raise ValueError("decision option name is required")
        if not self.weights:
            raise ValueError("decision option weights are required")


@dataclass(frozen=True)
class ScoreBreakdown:
    """Audit information for one option score."""

    option: str
    score: float
    bias: float
    contributions: dict[str, float]
    tie_breaker: int


@dataclass(frozen=True)
class DecisionResult:
    """Selected option plus full score audit trail."""

    selected: str
    score: float
    payload: dict[str, Any]
    breakdowns: list[ScoreBreakdown]

    def as_dict(self) -> dict[str, Any]:
        return {
            "selected": self.selected,
            "score": self.score,
            "payload": self.payload,
            "breakdowns": [
                {
                    "option": item.option,
                    "score": item.score,
                    "bias": item.bias,
                    "contributions": item.contributions,
                    "tie_breaker": item.tie_breaker,
                }
                for item in self.breakdowns
            ],
        }


def _numeric_context_value(context: Mapping[str, Any], feature: str) -> float:
    value = context.get(feature, 0.0)
    if isinstance(value, bool):
        return 1.0 if value else 0.0
    if isinstance(value, (int, float)):
        return float(value)
    return 0.0


def score_option(option: DecisionOption, context: Mapping[str, Any]) -> ScoreBreakdown:
    """Score one option from explicit numeric context features."""

    contributions = {
        feature: _numeric_context_value(context, feature) * float(weight)
        for feature, weight in option.weights.items()
    }
    score = float(option.bias) + sum(contributions.values())
    return ScoreBreakdown(
        option=option.name,
        score=score,
        bias=float(option.bias),
        contributions=contributions,
        tie_breaker=0,
    )


def choose_decision(
    *,
    options: list[DecisionOption],
    context: Mapping[str, Any],
    seed: str | int,
    namespace: str = "decision",
) -> DecisionResult:
    """Choose the highest scoring option with stable deterministic tie-breaking."""

    if not options:
        raise ValueError("at least one decision option is required")

    context_key = dumps(to_plain(dict(context))).decode("utf-8")
    scored: list[ScoreBreakdown] = []
    for option in options:
        base = score_option(option, context)
        tie_breaker = stable_int("decision.tie", seed, namespace, option.name, context_key, bits=64)
        scored.append(
            ScoreBreakdown(
                option=base.option,
                score=base.score,
                bias=base.bias,
                contributions=base.contributions,
                tie_breaker=tie_breaker,
            )
        )

    scored.sort(key=lambda item: (item.score, item.tie_breaker, item.option), reverse=True)
    selected = scored[0]
    selected_option = next(option for option in options if option.name == selected.option)
    return DecisionResult(
        selected=selected.option,
        score=selected.score,
        payload=dict(to_plain(dict(selected_option.payload))),
        breakdowns=scored,
    )

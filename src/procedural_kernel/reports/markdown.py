"""Markdown reports for small simulation runs."""

from __future__ import annotations

from typing import Any, Mapping


def simulation_report_markdown(report: Mapping[str, Any]) -> str:
    """Render a compact Markdown summary from a simulation report dictionary."""

    stats = dict(report.get("stats", {}))
    decisions = list(report.get("decisions", []))
    processed = list(report.get("processed_events", []))

    lines = [
        "# Procedural Kernel — Simulation Report",
        "",
        f"- OK: `{str(report.get('ok', False)).lower()}`",
        f"- Database: `{report.get('db_path', ':memory:')}`",
        f"- Chunk: `{report.get('chunk_id', 'n/a')}`",
        f"- Target entity: `{report.get('target_entity_id', 'n/a')}`",
        f"- Events: `{stats.get('events', 0)}`",
        f"- Patches: `{stats.get('patches', 0)}`",
        f"- Snapshots: `{stats.get('snapshots', 0)}`",
        f"- Latest tick: `{stats.get('latest_tick', 0)}`",
        "",
        "## Decisions",
        "",
    ]

    if not decisions:
        lines.append("No decisions recorded.")
    else:
        lines.append("| Tick | Selected | Score |")
        lines.append("|---:|---|---:|")
        for item in decisions[:25]:
            lines.append(
                f"| {item.get('tick', '')} | `{item.get('selected', '')}` | {float(item.get('score', 0.0)):.6f} |"
            )

    lines.extend(["", "## Processed events", ""])
    if not processed:
        lines.append("No processed events recorded.")
    else:
        lines.append("| Tick | Type | ID |")
        lines.append("|---:|---|---|")
        for item in processed[:25]:
            lines.append(f"| {item.get('tick', '')} | `{item.get('type', '')}` | `{item.get('id', '')}` |")

    return "\n".join(lines) + "\n"

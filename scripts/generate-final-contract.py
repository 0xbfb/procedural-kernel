#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description="Gera contrato final de release a partir do version-chain.json.")
    parser.add_argument("--input", default="docs/releases/version-chain.json")
    parser.add_argument("--output", default="docs/releases/version-chain.final.json")
    parser.add_argument("--checked-by", default="manual")
    args = parser.parse_args()

    source = Path(args.input)
    output = Path(args.output)
    data = load_json(source)

    project = data.get("project", {})
    release = data.get("release", {})
    version = project.get("version") or release.get("targetVersion")

    final_contract = {
        "schemaVersion": data.get("schemaVersion", "1.0"),
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "checkedBy": args.checked_by,
        "project": project,
        "release": release,
        "branches": data.get("branches", {}),
        "commits": data.get("commits", []),
        "commands": data.get("commands", {}),
        "push": data.get("push", {}),
        "safety": data.get("safety", {}),
        "docs": data.get("docs", {}),
        "summary": {
            "version": version,
            "tag": f"{release.get('tagPrefix', 'v')}{version}",
            "promoteTo": release.get("promoteTo", []),
            "pushEnabled": bool(data.get("push", {}).get("enabled", False)),
        },
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(final_contract, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Contrato final gerado: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

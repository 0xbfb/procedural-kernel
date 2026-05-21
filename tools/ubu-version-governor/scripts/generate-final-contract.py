from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Gera um version-chain.json mínimo.")
    parser.add_argument("--project", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--promote-to", default="release,nightly")
    parser.add_argument("--output", default="docs/releases/version-chain.json")
    args = parser.parse_args()

    promote_to = [item.strip() for item in args.promote_to.split(",") if item.strip()]
    data = {
        "schemaVersion": "1.0",
        "project": {"name": args.project, "version": args.version},
        "release": {
            "channel": "release",
            "targetVersion": args.version,
            "promoteTo": promote_to,
            "tagPrefix": "v",
            "tagMessage": f"Release {args.version}",
        },
        "branches": {"patch": "patch/{version}", "release": "release/{version}", "nightly": "nightly", "stable": "stable"},
        "commits": [{"message": f"chore(release): prepare {args.version}", "include": ["."], "allowEmpty": False}],
        "commands": {"beforeAll": [], "validation": [], "afterAll": []},
        "push": {"enabled": True, "remote": "origin", "branches": True, "tags": True},
        "safety": {"requireCleanWorkingTree": False, "requireBranch": None, "allowBranchCreate": True, "allowBranchReset": False},
    }
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Contrato gerado: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

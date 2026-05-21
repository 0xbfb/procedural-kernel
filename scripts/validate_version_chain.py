from __future__ import annotations

import json
import sys
from pathlib import Path

REQUIRED_TOP_LEVEL = {"schemaVersion", "project", "release", "branches", "commits", "push", "safety"}
REQUIRED_BRANCHES = {"patch", "release", "nightly", "stable"}
VALID_PROMOTIONS = {"release", "nightly", "stable"}


def fail(message: str) -> int:
    print(f"version-chain inválido: {message}")
    return 1


def main(argv: list[str] | None = None) -> int:
    args = argv if argv is not None else sys.argv[1:]
    path = Path(args[0] if args else "docs/releases/version-chain.json")
    if not path.exists():
        return fail(f"arquivo não encontrado: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    missing = REQUIRED_TOP_LEVEL.difference(data)
    if missing:
        return fail(f"campos ausentes: {sorted(missing)}")
    project = data["project"]
    release = data["release"]
    branches = data["branches"]
    if not project.get("name") or not project.get("version"):
        return fail("project.name e project.version são obrigatórios")
    if release.get("targetVersion") != project.get("version"):
        return fail("release.targetVersion deve bater com project.version")
    promotions = set(release.get("promoteTo", []))
    if not promotions or not promotions.issubset(VALID_PROMOTIONS):
        return fail("release.promoteTo deve conter apenas release, nightly e/ou stable")
    if "stable" in promotions and "release" not in promotions:
        return fail("stable só pode ser promovida passando por release")
    missing_branches = REQUIRED_BRANCHES.difference(branches)
    if missing_branches:
        return fail(f"branches ausentes: {sorted(missing_branches)}")
    if not isinstance(data.get("commits"), list) or not data["commits"]:
        return fail("commits deve ter ao menos um item")
    print(f"version-chain OK: {project['name']} {project['version']} -> {', '.join(release['promoteTo'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

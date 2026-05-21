from __future__ import annotations

import json
import sys
from pathlib import Path


def main(argv: list[str] | None = None) -> int:
    args = argv if argv is not None else sys.argv[1:]
    path = Path(args[0] if args else "docs/releases/version-chain.json")
    if not path.exists():
        print(f"ERRO: contrato nao encontrado: {path}")
        return 1

    data = json.loads(path.read_text(encoding="utf-8"))
    project = data["project"]
    release = data["release"]
    branches = data["branches"]
    commands = data.get("commands", {})
    push = data.get("push", {})

    version = project["version"]
    release_branch = branches["release"].format(version=version)
    tag_name = f"{release.get('tagPrefix', 'v')}{version}"

    steps: list[str] = []
    steps.append(f"Validar contrato {path}.")
    for command in commands.get("validation", []):
        steps.append(f"Executar validacao: {command}")
    for commit in data.get("commits", []):
        includes = ", ".join(commit.get("include", ["."]))
        steps.append(f"Criar commit: {commit['message']} | include: {includes}")
    steps.append(f"Criar/atualizar branch: {release_branch}")
    steps.append(f"Criar tag: {tag_name}")
    for target in release.get("promoteTo", []):
        branch = branches[target].format(version=version)
        steps.append(f"Promover para {target}: {branch}")
    if push.get("enabled"):
        steps.append(f"Publicar branches/tags em {push.get('remote', 'origin')}")
    else:
        steps.append("Push desabilitado no contrato; publicar manualmente apos revisao.")

    print("Plano ISO/3.1E")
    print("=" * 16)
    for index, step in enumerate(steps, start=1):
        print(f"{index:02d}. {step}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

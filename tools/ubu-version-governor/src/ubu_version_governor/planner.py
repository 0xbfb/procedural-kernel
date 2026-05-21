from __future__ import annotations

from dataclasses import dataclass
from .contract import VersionContract


@dataclass(frozen=True)
class Plan:
    steps: list[str]

    def as_text(self) -> str:
        lines = ["Plano ISO/3.1 E"]
        lines.append("=" * 16)
        for index, step in enumerate(self.steps, start=1):
            lines.append(f"{index:02d}. {step}")
        return "\n".join(lines)


def build_plan(contract: VersionContract, *, push_requested: bool = False) -> Plan:
    steps: list[str] = []
    release_branch = contract.branch_for("release")

    steps.append(f"Validar repositório Git e contrato schemaVersion={contract.schema_version}.")
    if contract.safety.require_branch:
        steps.append(f"Confirmar branch atual obrigatória: {contract.safety.require_branch}.")
    if contract.safety.require_clean_working_tree:
        steps.append("Confirmar working tree limpa antes de iniciar.")

    for command in contract.commands_before_all:
        steps.append(f"Executar comando beforeAll: {command}")

    for commit in contract.commits:
        includes = ", ".join(f"`{item}`" for item in commit.include)
        steps.append(f"Criar commit '{commit.message}' incluindo: {includes}.")

    steps.append(f"Criar ou atualizar branch de release: {release_branch}.")
    steps.append(f"Criar tag {contract.tag_name} em {release_branch}.")

    for target in contract.promote_to:
        target_branch = contract.branch_for(target)
        if target == "release":
            steps.append(f"Manter release publicada em {target_branch}.")
        else:
            steps.append(f"Promover {release_branch} para {target_branch}.")

    for command in contract.commands_validation:
        steps.append(f"Executar validação: {command}")

    for command in contract.commands_after_all:
        steps.append(f"Executar comando afterAll: {command}")

    if push_requested and contract.push.enabled:
        if contract.push.branches:
            branches = [contract.branch_for(target) for target in contract.promote_to]
            if release_branch not in branches:
                branches.insert(0, release_branch)
            steps.append(f"Push de branches para {contract.push.remote}: {', '.join(dict.fromkeys(branches))}.")
        if contract.push.tags:
            steps.append(f"Push de tags para {contract.push.remote}.")
    else:
        steps.append("Não executar push; use --push junto de --apply para publicar.")

    return Plan(steps)

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any
import json

VALID_CHANNELS = {"patch", "release", "nightly", "stable"}
PROMOTION_CHANNELS = {"release", "nightly", "stable"}


class ContractError(ValueError):
    """Raised when version-chain.json is invalid."""


@dataclass(frozen=True)
class CommitSpec:
    message: str
    include: list[str] = field(default_factory=lambda: ["."])
    allow_empty: bool = False


@dataclass(frozen=True)
class PushSpec:
    enabled: bool = False
    remote: str = "origin"
    branches: bool = True
    tags: bool = True
    force_with_lease: bool = False


@dataclass(frozen=True)
class SafetySpec:
    require_clean_working_tree: bool = True
    require_branch: str | None = None
    allow_branch_create: bool = True
    allow_branch_reset: bool = False


@dataclass(frozen=True)
class VersionContract:
    raw: dict[str, Any]
    schema_version: str
    project_name: str
    version: str
    channel: str
    promote_to: list[str]
    tag_prefix: str
    tag_message: str | None
    branches: dict[str, str]
    commits: list[CommitSpec]
    commands_before_all: list[str]
    commands_validation: list[str]
    commands_after_all: list[str]
    push: PushSpec
    safety: SafetySpec

    @property
    def tag_name(self) -> str:
        return f"{self.tag_prefix}{self.version}"

    def branch_for(self, channel: str) -> str:
        template = self.branches[channel]
        return template.format(version=self.version, channel=channel)


def _as_list(value: Any, *, field_name: str) -> list[Any]:
    if value is None:
        return []
    if not isinstance(value, list):
        raise ContractError(f"Campo '{field_name}' deve ser uma lista.")
    return value


def load_contract(path: str | Path) -> VersionContract:
    path = Path(path)
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ContractError(f"Arquivo não encontrado: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ContractError(f"JSON inválido em {path}: {exc}") from exc

    if not isinstance(raw, dict):
        raise ContractError("O contrato precisa ser um objeto JSON.")

    project = raw.get("project") or {}
    release = raw.get("release") or {}
    branches = raw.get("branches") or {}
    commands = raw.get("commands") or {}
    push_raw = raw.get("push") or {}
    safety_raw = raw.get("safety") or {}

    schema_version = str(raw.get("schemaVersion") or "").strip()
    project_name = str(project.get("name") or "").strip()
    version = str(release.get("targetVersion") or project.get("version") or "").strip()
    channel = str(release.get("channel") or "release").strip()
    promote_to = [str(item).strip() for item in _as_list(release.get("promoteTo", ["release"]), field_name="release.promoteTo")]
    tag_prefix = str(release.get("tagPrefix") or "v")
    tag_message = release.get("tagMessage")

    errors: list[str] = []
    if not schema_version:
        errors.append("schemaVersion é obrigatório.")
    if not project_name:
        errors.append("project.name é obrigatório.")
    if not version:
        errors.append("project.version ou release.targetVersion é obrigatório.")
    if channel not in VALID_CHANNELS:
        errors.append(f"release.channel inválido: {channel}")
    invalid_promotions = [item for item in promote_to if item not in PROMOTION_CHANNELS]
    if invalid_promotions:
        errors.append(f"release.promoteTo contém canais inválidos: {', '.join(invalid_promotions)}")
    for required_branch in ["patch", "release", "nightly", "stable"]:
        if not branches.get(required_branch):
            errors.append(f"branches.{required_branch} é obrigatório.")

    commits_raw = _as_list(raw.get("commits", []), field_name="commits")
    commits: list[CommitSpec] = []
    for index, item in enumerate(commits_raw, start=1):
        if not isinstance(item, dict):
            errors.append(f"commits[{index}] precisa ser objeto.")
            continue
        message = str(item.get("message") or "").strip()
        if not message:
            errors.append(f"commits[{index}].message é obrigatório.")
        include = [str(path) for path in _as_list(item.get("include", ["."]), field_name=f"commits[{index}].include")]
        commits.append(CommitSpec(message=message, include=include or ["."], allow_empty=bool(item.get("allowEmpty", False))))

    if errors:
        raise ContractError("Contrato inválido:\n- " + "\n- ".join(errors))

    return VersionContract(
        raw=raw,
        schema_version=schema_version,
        project_name=project_name,
        version=version,
        channel=channel,
        promote_to=promote_to,
        tag_prefix=tag_prefix,
        tag_message=str(tag_message) if tag_message else None,
        branches={str(k): str(v) for k, v in branches.items()},
        commits=commits,
        commands_before_all=[str(x) for x in _as_list(commands.get("beforeAll", []), field_name="commands.beforeAll")],
        commands_validation=[str(x) for x in _as_list(commands.get("validation", []), field_name="commands.validation")],
        commands_after_all=[str(x) for x in _as_list(commands.get("afterAll", []), field_name="commands.afterAll")],
        push=PushSpec(
            enabled=bool(push_raw.get("enabled", False)),
            remote=str(push_raw.get("remote") or "origin"),
            branches=bool(push_raw.get("branches", True)),
            tags=bool(push_raw.get("tags", True)),
            force_with_lease=bool(push_raw.get("forceWithLease", False)),
        ),
        safety=SafetySpec(
            require_clean_working_tree=bool(safety_raw.get("requireCleanWorkingTree", True)),
            require_branch=safety_raw.get("requireBranch"),
            allow_branch_create=bool(safety_raw.get("allowBranchCreate", True)),
            allow_branch_reset=bool(safety_raw.get("allowBranchReset", False)),
        ),
    )

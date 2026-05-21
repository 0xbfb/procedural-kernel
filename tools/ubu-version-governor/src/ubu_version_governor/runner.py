from __future__ import annotations

from pathlib import Path
import subprocess

from .contract import VersionContract
from .git_ops import Git, GitError


class RunnerError(RuntimeError):
    """Raised when the release chain cannot proceed."""


def run_shell(command: str, *, repo: Path, dry_run: bool) -> None:
    if dry_run:
        print(f"[dry-run] {command}")
        return
    result = subprocess.run(command, cwd=repo, shell=True, text=True, check=False)
    if result.returncode != 0:
        raise RunnerError(f"Comando falhou ({result.returncode}): {command}")


def apply_contract(contract: VersionContract, *, repo: Path, apply: bool, push: bool, allow_dirty: bool = False) -> None:
    dry_run = not apply
    git = Git(repo=repo, dry_run=dry_run)

    if not git.is_repo():
        raise RunnerError(f"Diretório não é um repositório Git: {repo}")

    current_branch = git.current_branch()
    if contract.safety.require_branch and current_branch != contract.safety.require_branch:
        raise RunnerError(
            f"Branch atual '{current_branch}' difere da obrigatória '{contract.safety.require_branch}'."
        )

    if contract.safety.require_clean_working_tree and not allow_dirty:
        status = git.status_porcelain()
        if status:
            raise RunnerError("Working tree possui alterações. Use --allow-dirty ou ajuste safety.requireCleanWorkingTree.")

    if git.tag_exists(contract.tag_name):
        raise RunnerError(f"Tag já existe: {contract.tag_name}")

    for command in contract.commands_before_all:
        run_shell(command, repo=repo, dry_run=dry_run)

    source_branch = current_branch
    for commit in contract.commits:
        git.add_and_commit(commit.include, commit.message, allow_empty=commit.allow_empty)

    release_branch = contract.branch_for("release")
    git.checkout_or_create(release_branch, allow_create=contract.safety.allow_branch_create)
    if release_branch != source_branch and git.branch_exists(source_branch):
        git.merge_no_ff(source_branch, f"chore(version): merge {source_branch} into {release_branch}")

    git.create_tag(contract.tag_name, contract.tag_message)

    promoted_branches: list[str] = [release_branch]
    for target in contract.promote_to:
        if target == "release":
            continue
        target_branch = contract.branch_for(target)
        git.checkout_or_create(target_branch, allow_create=contract.safety.allow_branch_create)
        git.merge_no_ff(release_branch, f"chore(version): promote {contract.version} to {target}")
        promoted_branches.append(target_branch)

    for command in contract.commands_validation:
        run_shell(command, repo=repo, dry_run=dry_run)

    for command in contract.commands_after_all:
        run_shell(command, repo=repo, dry_run=dry_run)

    if push:
        if not contract.push.enabled:
            raise RunnerError("Push solicitado, mas push.enabled=false no contrato.")
        if contract.push.branches:
            for branch in dict.fromkeys(promoted_branches):
                git.push_branch(contract.push.remote, branch)
        if contract.push.tags:
            git.push_tags(contract.push.remote)
    else:
        print("Push não executado. Use --push para publicar branches/tags.")

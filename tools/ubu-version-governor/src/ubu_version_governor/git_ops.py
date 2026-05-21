from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import shutil
import subprocess


class GitError(RuntimeError):
    """Raised when a Git command fails."""


@dataclass
class Git:
    repo: Path
    dry_run: bool = True

    def check_available(self) -> None:
        if shutil.which("git") is None:
            raise GitError("Git não encontrado no PATH.")

    def run(self, args: list[str], *, capture: bool = False) -> str:
        self.check_available()
        cmd = ["git", *args]
        printable = " ".join(cmd)
        if self.dry_run and not capture:
            print(f"[dry-run] {printable}")
            return ""
        result = subprocess.run(
            cmd,
            cwd=self.repo,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            details = (result.stderr or result.stdout or "").strip()
            raise GitError(f"Falha ao executar '{printable}': {details}")
        return result.stdout.strip()

    def current_branch(self) -> str:
        return self.run(["rev-parse", "--abbrev-ref", "HEAD"], capture=True)

    def is_repo(self) -> bool:
        try:
            self.run(["rev-parse", "--is-inside-work-tree"], capture=True)
            return True
        except GitError:
            return False

    def status_porcelain(self) -> str:
        return self.run(["status", "--porcelain"], capture=True)

    def branch_exists(self, branch: str) -> bool:
        try:
            self.run(["rev-parse", "--verify", branch], capture=True)
            return True
        except GitError:
            return False

    def tag_exists(self, tag: str) -> bool:
        try:
            self.run(["rev-parse", "--verify", f"refs/tags/{tag}"], capture=True)
            return True
        except GitError:
            return False

    def checkout_or_create(self, branch: str, *, allow_create: bool) -> None:
        if self.branch_exists(branch):
            self.run(["checkout", branch])
            return
        if not allow_create:
            raise GitError(f"Branch não existe e criação está bloqueada: {branch}")
        self.run(["checkout", "-b", branch])

    def add_and_commit(self, include: list[str], message: str, *, allow_empty: bool) -> None:
        for path in include:
            self.run(["add", path])
        args = ["commit", "-m", message]
        if allow_empty:
            args.insert(1, "--allow-empty")
        self.run(args)

    def merge_no_ff(self, source: str, message: str) -> None:
        self.run(["merge", "--no-ff", source, "-m", message])

    def create_tag(self, tag: str, message: str | None) -> None:
        if message:
            self.run(["tag", "-a", tag, "-m", message])
        else:
            self.run(["tag", tag])

    def push_branch(self, remote: str, branch: str) -> None:
        self.run(["push", remote, branch])

    def push_tags(self, remote: str) -> None:
        self.run(["push", remote, "--tags"])

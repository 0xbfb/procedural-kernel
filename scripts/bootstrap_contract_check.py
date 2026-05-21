from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def run(cmd: list[str], *, root: Path) -> None:
    print("$ " + " ".join(cmd))
    subprocess.run(cmd, cwd=root, check=True)


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    storage = root / ".tmp" / "bootstrap_contract.sqlite"
    bundle = root / ".tmp" / "bootstrap_contract_bundle.json"
    storage.parent.mkdir(exist_ok=True)
    if storage.exists():
        storage.unlink()
    run([sys.executable, "-m", "compileall", "-q", "src", "tests"], root=root)
    run([sys.executable, "-m", "pytest", "-q"], root=root)
    run([sys.executable, "-m", "procedural_kernel.cli", "doctor"], root=root)
    run([sys.executable, "-m", "procedural_kernel.cli", "simulate", "--seed", "bootstrap", "--events", "25", "--storage", str(storage)], root=root)
    run([sys.executable, "-m", "procedural_kernel.cli", "replay", "--storage", str(storage), "--limit", "3"], root=root)
    run([sys.executable, "-m", "procedural_kernel.cli", "export", "--storage", str(storage), "--out", str(bundle), "--seed", "bootstrap"], root=root)
    run([sys.executable, "scripts/validate_version_chain.py", "docs/releases/version-chain.json"], root=root)
    print("bootstrap-contract OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    tool_src = root / "tools" / "ubu-version-governor" / "src"
    contract = root / "docs" / "releases" / "version-chain.json"
    env = dict(__import__("os").environ)
    env["PYTHONPATH"] = str(tool_src) + (";" + env["PYTHONPATH"] if "PYTHONPATH" in env else "")
    return subprocess.call([
        sys.executable,
        "-m",
        "ubu_version_governor",
        "plan",
        "--input",
        str(contract),
    ], env=env, cwd=root)


if __name__ == "__main__":
    raise SystemExit(main())

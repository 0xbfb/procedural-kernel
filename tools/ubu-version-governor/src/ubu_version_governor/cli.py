from __future__ import annotations

from pathlib import Path
import argparse
import json
import shutil

from . import __version__
from .contract import ContractError, load_contract
from .git_ops import Git
from .planner import build_plan
from .runner import RunnerError, apply_contract


def cmd_doctor(args: argparse.Namespace) -> int:
    repo = Path(args.repo).resolve()
    print(f"UBU Version Governor {__version__}")
    print(f"Repo: {repo}")
    print(f"Python OK")
    print(f"Git: {'OK' if shutil.which('git') else 'NÃO ENCONTRADO'}")
    git = Git(repo=repo, dry_run=False)
    print(f"Repositório Git: {'SIM' if git.is_repo() else 'NÃO'}")
    return 0


def cmd_plan(args: argparse.Namespace) -> int:
    contract = load_contract(args.input)
    plan = build_plan(contract, push_requested=args.push)
    if args.format == "json":
        print(json.dumps({"steps": plan.steps}, ensure_ascii=False, indent=2))
    else:
        print(plan.as_text())
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    contract = load_contract(args.input)
    print(f"Contrato válido: {contract.project_name} {contract.version} -> {', '.join(contract.promote_to)}")
    return 0


def cmd_apply(args: argparse.Namespace) -> int:
    contract = load_contract(args.input)
    plan = build_plan(contract, push_requested=args.push)
    print(plan.as_text())
    print("")
    if not args.apply:
        print("Modo dry-run: nenhum comando real será executado. Use --apply para executar.")
    apply_contract(
        contract,
        repo=Path(args.repo).resolve(),
        apply=args.apply,
        push=args.push,
        allow_dirty=args.allow_dirty,
    )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="ubu-version-governor")
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")

    sub = parser.add_subparsers(dest="command", required=True)

    doctor = sub.add_parser("doctor", help="Verifica ambiente e repositório.")
    doctor.add_argument("--repo", default=".")
    doctor.set_defaults(func=cmd_doctor)

    validate = sub.add_parser("validate", help="Valida o contrato JSON.")
    validate.add_argument("--input", required=True)
    validate.set_defaults(func=cmd_validate)

    plan = sub.add_parser("plan", help="Mostra plano de execução sem alterar nada.")
    plan.add_argument("--input", required=True)
    plan.add_argument("--format", choices=["text", "json"], default="text")
    plan.add_argument("--push", action="store_true", help="Inclui etapas de push no plano.")
    plan.set_defaults(func=cmd_plan)

    apply_parser = sub.add_parser("apply", help="Executa a cadeia de versionamento; dry-run por padrão.")
    apply_parser.add_argument("--input", required=True)
    apply_parser.add_argument("--repo", default=".")
    apply_parser.add_argument("--apply", action="store_true", help="Executa comandos reais.")
    apply_parser.add_argument("--push", action="store_true", help="Publica branches/tags; requer --apply.")
    apply_parser.add_argument("--allow-dirty", action="store_true", help="Permite working tree com alterações.")
    apply_parser.set_defaults(func=cmd_apply)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if getattr(args, "push", False) and not getattr(args, "apply", False) and args.command == "apply":
        parser.error("--push só pode ser usado com --apply.")
    try:
        return int(args.func(args))
    except (ContractError, RunnerError) as exc:
        print(f"ERRO: {exc}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

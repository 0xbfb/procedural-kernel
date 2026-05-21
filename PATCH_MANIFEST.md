# Patch Manifest — Procedural Kernel 0.1.3

## Identificação

- Projeto: `procedural-kernel`
- Release anterior: `0.1.2`
- Release gerada: `0.1.3`
- Tipo: patch de hardening, arquivos faltantes e sincronização UBU ISO

## Arquivos criados

- `.gitignore`
- `installer/install_menu.ps1`
- `scripts/generate-final-contract.py`
- `tools/README.md`
- `docs/releases/PATCH-0.1.3.md`
- `docs/releases/RELEASE-0.1.3.md`
- `docs/iso/ubu_iso_suite/**`
- `docs/iso/3.1e-kit-output/**`
- `docs/prompts/**`
- checklists/templates ISO em `docs/`

## Arquivos alterados

- `pyproject.toml`
- `src/procedural_kernel/__init__.py`
- `src/procedural_kernel/schemas.py`
- `src/procedural_kernel/exporters/json_bundle.py`
- `src/procedural_kernel/cli.py`
- `tests/test_export_benchmark_cli.py`
- `Makefile`
- `install.bat`
- `scripts/install/windows-install.bat`
- `scripts/version/plan_version_chain.py`
- `AGENTS.md`
- `README.md`
- `RELEASE_NOTES.md`
- `docs/README.md`
- `docs/releases/PATCH_NOTES.md`
- `docs/releases/RELEASE_NOTES.md`
- `docs/releases/version-chain.json`
- `examples/version-chain.example.json`

## Política dev-only

`tools/ubu-version-governor/` não deve ser rastreado nesta release. Se já estiver versionado no repositório remoto, remover do índice com:

```bash
git rm -r --cached tools/ubu-version-governor
```

## Validações previstas

```bash
python -m compileall -q src tests scripts
PYTHONPATH=src python -m pytest -q
PYTHONPATH=src python -m procedural_kernel.cli doctor
python scripts/validate_version_chain.py docs/releases/version-chain.json
python scripts/version/plan_version_chain.py docs/releases/version-chain.json
python scripts/generate-final-contract.py --input docs/releases/version-chain.json --output docs/releases/version-chain.final.json
```

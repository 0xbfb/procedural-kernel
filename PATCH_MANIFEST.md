# Patch Manifest — Procedural Kernel 0.1.2

## Base

- Release anterior: `0.1.1`
- Release gerada: `0.1.2`
- Escopo: UBU-ISO/3.0 + UBU-ISO/3.1E

## Arquivos novos/relevantes

- `Makefile`
- `Dockerfile`
- `docker-compose.yml`
- `.env.example`
- `.dockerignore`
- `docs/UBU-ISO-3.0-INICIALIZADORES-E-BOOTSTRAP.md`
- `docs/UBU-ISO-3.1E-COMMIT-VERSIONAMENTO.md`
- `docs/CHECKLIST-ISO-3.1E.md`
- `docs/MATRIZ-BRANCHES-TAGS.md`
- `docs/TEMPLATE-VERSION-CHAIN-JSON.md`
- `docs/PROMPT_FINAL_PATCH_VERSION_CHAIN.md`
- `docs/iso/ISO_ADOPTION.md`
- `docs/releases/version-chain.json`
- `schemas/ubu-version-chain.schema.json`
- `scripts/validate_version_chain.py`
- `scripts/version/plan_version_chain.py`
- `scripts/bootstrap_contract_check.py`
- `tools/ubu-version-governor/`
- `tests/test_version_chain.py`

## Arquivos atualizados

- `pyproject.toml`
- `src/procedural_kernel/__init__.py`
- `src/procedural_kernel/cli.py`
- `src/procedural_kernel/schemas.py`
- `src/procedural_kernel/exporters/json_bundle.py`
- `README.md`
- `AGENTS.md`
- `install.bat`
- `run.bat`
- `scripts/install/windows-install.bat`
- `scripts/install/windows-run.bat`
- `RELEASE_NOTES.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/RELEASE_AUDIT.md`

## Observação

Não houve alteração intencional no contrato de runtime do kernel procedural. A release fortalece bootstrap, documentação, versionamento e distribuição.

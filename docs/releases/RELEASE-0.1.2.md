# Release Notes — Procedural Kernel 0.1.2

A release `0.1.2` transforma o pacote em um projeto mais governável operacionalmente. O core procedural continua o mesmo, mas agora o repositório possui inicializadores padronizados, contrato de bootstrap e cadeia de versionamento auditável.

## Destaques

- UBU-ISO/3.0 aplicado: Makefile, Dockerfile, compose, bootstrap contract e `.env.example`.
- UBU-ISO/3.1E aplicado: contrato `version-chain.json`, schema, validação e ferramenta local de planejamento.
- Instalador Windows com menu de canal/branch: patch, release, nightly, stable ou branch customizada.
- `run.bat` busca atualizações antes de iniciar quando executado em clone Git.

## Validação recomendada

```bash
python -m compileall -q src tests scripts
PYTHONPATH=src pytest -q
PYTHONPATH=src python -m procedural_kernel.cli doctor
python scripts/validate_version_chain.py docs/releases/version-chain.json
PYTHONPATH=tools/ubu-version-governor/src python -m ubu_version_governor validate --input docs/releases/version-chain.json
```

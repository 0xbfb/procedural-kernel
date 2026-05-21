# Adoção UBU ISO — Procedural Kernel 0.1.2

Esta release adiciona os padrões operacionais restantes da suíte UBU:

- UBU-ISO/3.0 — inicializadores, bootstrap e contrato mínimo de execução.
- UBU-ISO/3.1E — esteira patch > release > nightly > stable.

## Decisões assumidas

- A versão desta release é `0.1.2`.
- A promoção proposta no contrato padrão é `release` e `nightly`.
- `stable` fica fora da promoção automática inicial para reduzir risco.
- `push.enabled=false` no contrato inicial. Push real deve ser opt-in.
- `tools/ubu-version-governor` é incluído como ferramenta local vendorizada para evitar dependência externa no primeiro ciclo.

## Arquivos centrais

- `docs/releases/version-chain.json`
- `schemas/ubu-version-chain.schema.json`
- `scripts/validate_version_chain.py`
- `scripts/version/plan_version_chain.py`
- `Makefile`
- `Dockerfile`
- `docker-compose.yml`
- `install.bat`
- `run.bat`

## Fluxo recomendado

```bash
python scripts/validate_version_chain.py docs/releases/version-chain.json
python scripts/version/plan_version_chain.py
```

Execução real de branch/tag/push deve ser feita apenas dentro de um clone Git revisado.

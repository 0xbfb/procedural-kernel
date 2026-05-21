# Release Checklist — Procedural Kernel 0.1.2

## Código

- [x] Versão do pacote atualizada para `0.1.2`.
- [x] `KERNEL_VERSION` atualizado para `0.1.2`.
- [x] `WorldConfig.world_version` atualizado para `0.1.2`.
- [x] Testes automatizados executados.

## UBU ISO/3.0

- [x] `Makefile` criado.
- [x] `Dockerfile` criado.
- [x] `docker-compose.yml` criado.
- [x] `.env.example` criado.
- [x] `.dockerignore` criado.
- [x] Bootstrap contract documentado e scriptado.

## UBU ISO/3.1E

- [x] `docs/releases/version-chain.json` criado.
- [x] Schema incluído em `schemas/ubu-version-chain.schema.json`.
- [x] Validador local criado.
- [x] Ferramenta `ubu-version-governor` incluída em `tools/`.
- [x] Menu de instalação por canal/branch adicionado ao `install.bat`.
- [x] `run.bat` atualiza antes de iniciar em clone Git.

## Observações

- `push.enabled=false` por padrão no contrato da release para evitar publicação acidental.
- Promoção proposta: `release` e `nightly`.
- `stable` deve ser promovida manualmente após validação ampliada.

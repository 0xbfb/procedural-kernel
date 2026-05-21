# Patch Notes — Procedural Kernel 0.1.2

## Escopo

Hardening de inicializadores e governança de versão com UBU-ISO/3.0 e UBU-ISO/3.1E.

## Alterações

- Adicionado `Makefile` com alvos de instalação, teste, doctor, simulação, export, benchmark e validação de version-chain.
- Adicionados `Dockerfile` e `docker-compose.yml` mínimos.
- Adicionados `.env.example` e `.dockerignore`.
- Adicionado `scripts/bootstrap_contract_check.py`.
- Adicionado contrato `docs/releases/version-chain.json`.
- Adicionado schema `schemas/ubu-version-chain.schema.json`.
- Adicionada ferramenta local `tools/ubu-version-governor`.
- Atualizados `install.bat` e `run.bat` para fluxo compatível com ISO/3.1E.
- Adicionados docs oficiais ISO/3.0 e ISO/3.1E ao projeto.

## Compatibilidade

Sem breaking changes intencionais no kernel Python em relação à `0.1.1`.

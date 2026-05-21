# Release Notes

## 0.1.3 — UBU ISO/3.0 + ISO/3.1E

A release `0.1.3` adiciona governança operacional de versão, inicializadores e cadeia `patch > release > nightly > stable`, sem alterar o core procedural.

Principais entregas:

- `Makefile`, `Dockerfile`, `docker-compose.yml`, `.env.example` e `.dockerignore`;
- `docs/releases/version-chain.json`;
- `schemas/ubu-version-chain.schema.json`;
- `scripts/validate_version_chain.py`;
- `tools/ubu-version-governor`;
- `install.bat` com menu de canal/branch;
- `run.bat` com atualização por Git antes do boot.


## 0.1.1 — Hardening UBU ISO

Data: 2026-05-21

A release `0.1.1` consolida a `0.1.0` como base limpa de projeto, adicionando documentação operacional, normas UBU e scripts Windows para instalação/execução.

### Destaques

- Adoção de UBU-ISO/1.0 para contratos, camadas e persistência de dados.
- Adoção de UBU-ISO/2.0 para documentação técnica e fluxo de release.
- Adoção de UBU-ISO/2.1 para `install.bat` e `run.bat`.
- `AGENTS.md` para orientar patches futuros.
- Release notes e patch notes padronizadas.
- Compatibilidade preservada com os contratos `bundle.v1`, `storage.v1`, `event.v1`, `patch.v1`, `snapshot.v1` e `chunk.v1`.

### Breaking changes

Nenhum breaking change intencional.

### Artefato final

```text
procedural_kernel_release_0_1_1.zip
```

## 0.1.0 — Release inicial

Base funcional do kernel procedural mínimo.

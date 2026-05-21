# Patch Notes — Procedural Kernel 0.1.3

## Tipo

Patch de hardening e sincronização de suíte ISO.

## Alterações

- Adiciona `.gitignore` raiz com política explícita para caches, ambientes locais, bancos SQLite e `tools/ubu-version-governor/` dev-only.
- Remove a dependência do versionador completo dentro do patch do projeto.
- Adiciona `installer/install_menu.ps1` como menu PowerShell auxiliar de instalação por canal/branch.
- Adiciona `scripts/generate-final-contract.py` para materializar `docs/releases/version-chain.final.json` sem depender de ferramenta externa.
- Atualiza `scripts/version/plan_version_chain.py` para gerar plano ISO/3.1E com stdlib.
- Sincroniza templates, checklists e matriz de comandos da suíte UBU ISO em `docs/iso/ubu_iso_suite/`.
- Adiciona templates/checklists ISO faltantes em `docs/` para acesso direto.
- Atualiza docs, version-chain, manifests e release notes para `0.1.3`.

## Compatibilidade

Sem breaking changes no runtime Python. O core procedural, CLI e contratos de bundle continuam compatíveis com `bundle.v1`.

## Observação operacional

Se `tools/ubu-version-governor/` já estiver rastreado no Git, remova do índice no fechamento da release:

```bash
git rm -r --cached tools/ubu-version-governor
```

A pasta pode continuar existindo localmente, mas não deve entrar no patch/release.

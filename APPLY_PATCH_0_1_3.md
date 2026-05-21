# Aplicação do patch 0.1.3 — Procedural Kernel

Este patch deve ser extraído por cima do repositório `procedural-kernel` na base `release/0.1.2`.

## O que este patch faz

- Atualiza versão para `0.1.3`.
- Adiciona arquivos faltantes de governança ISO.
- Sincroniza a suíte UBU ISO mais recente em `docs/iso/ubu_iso_suite/`.
- Adiciona `.gitignore` raiz.
- Adiciona `installer/install_menu.ps1`.
- Adiciona `scripts/generate-final-contract.py`.
- Remove dependência do governor completo dentro do patch do projeto.

## Atenção sobre ferramenta dev-only

Se `tools/ubu-version-governor/` já estiver rastreado no Git, remova do índice antes do commit:

```bash
git rm -r --cached tools/ubu-version-governor
```

A pasta está coberta por `.gitignore` e pode continuar localmente, mas não deve ser enviada como parte da release.

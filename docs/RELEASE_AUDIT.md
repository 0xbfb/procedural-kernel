# Release Audit — Procedural Kernel 0.1.2

## Resultado

Release `0.1.2` gerada como hardening de governança operacional.

## Escopo validado

- Kernel procedural mantido compatível com `0.1.2`.
- ISO/3.0 aplicada com inicializadores e bootstrap.
- ISO/3.1E aplicada com contrato JSON, schema, ferramenta de planejamento e menu de instalação.

## Riscos residuais

- Execução real dos `.bat` não foi validada neste ambiente Linux.
- Build com `python -m build` depende do módulo `build`, que pode não estar instalado no ambiente.
- Push/branch/tag não foram executados; o contrato está preparado para dry-run/planejamento seguro.

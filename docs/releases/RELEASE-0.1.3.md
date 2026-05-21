# Release Notes — Procedural Kernel 0.1.3

A release `0.1.3` corrige a lacuna de arquivos do repositório e sincroniza o projeto com a suíte UBU ISO empacotada no kit mais recente.

## Destaques

- `.gitignore` raiz adicionado.
- Política dev-only para `tools/ubu-version-governor/` aplicada.
- Menu PowerShell de instalação adicionado em `installer/install_menu.ps1`.
- Geração de contrato final adicionada via `scripts/generate-final-contract.py`.
- Planejamento de versionamento ISO/3.1E sem dependência externa.
- Templates/checklists ISO completos adicionados em documentação.
- Contrato `docs/releases/version-chain.json` atualizado para `0.1.3`.

## Validação recomendada

```bash
python -m compileall -q src tests scripts
PYTHONPATH=src python -m pytest -q
PYTHONPATH=src python -m procedural_kernel.cli doctor
python scripts/validate_version_chain.py docs/releases/version-chain.json
python scripts/version/plan_version_chain.py docs/releases/version-chain.json
python scripts/generate-final-contract.py --input docs/releases/version-chain.json --output docs/releases/version-chain.final.json
```

## Compatibilidade

Sem breaking changes intencionais no pacote `procedural_kernel`.

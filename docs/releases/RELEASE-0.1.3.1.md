# Release 0.1.3.1 — Governor hotfix

Release corretiva focada no `UBU Version Governor`.

## Entregável

- Pacote procedural permanece compatível com `0.1.3`.
- Governor embutido atualizado para `0.1.1`.
- Contrato de versionamento atualizado para suportar publicação segura com `--force-with-lease`.

## Validações esperadas

```bash
python -m compileall -q src tests scripts tools/ubu-version-governor/src tools/ubu-version-governor/tests
PYTHONPATH=src python -m pytest -q
python scripts/validate_version_chain.py docs/releases/version-chain.json
PYTHONPATH=tools/ubu-version-governor/src python -m ubu_version_governor validate --input docs/releases/version-chain.json
PYTHONPATH=tools/ubu-version-governor/src python -m ubu_version_governor plan --input docs/releases/version-chain.json --push
PYTHONPATH=tools/ubu-version-governor/src python -m pytest -q tools/ubu-version-governor/tests
```

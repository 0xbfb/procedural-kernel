# Release 0.1.0

Primeira release do projeto de referência para a UBU-ISO/3.1 E.

## Cadeia suportada

```text
patch > release > nightly > stable
```

## Comandos principais

```bash
python -m ubu_version_governor validate --input examples/version-chain.example.json
python -m ubu_version_governor plan --input examples/version-chain.example.json
python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply
python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply --push
```

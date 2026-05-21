# Prompt — gerar contrato final de versionamento ISO/3.1 E

Use este prompt no último patch antes de fechar uma release.

```markdown
Você deve finalizar o patch preparando a promoção de versão conforme UBU-ISO/3.1 E.

Gere ou atualize o arquivo `docs/releases/version-chain.json` com todos os dados necessários para o executor de versionamento.

Use a cadeia:

patch > release > nightly > stable

Regras:

1. Não execute push.
2. Não sobrescreva tags existentes.
3. Não atualize `stable` diretamente sem passar por `release/{version}`.
4. O JSON deve conter `project`, `release`, `branches`, `commits`, `commands`, `push`, `safety` e `docs`.
5. Inclua comandos de validação reais do projeto.
6. Inclua release notes e patch notes correspondentes.
7. Ao final, informe os comandos:
   - dry-run: `python -m ubu_version_governor plan --input docs/releases/version-chain.json`
   - apply local: `python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply`
   - apply com push: `python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply --push`
```

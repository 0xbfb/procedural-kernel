# Patch 0.1.3.1 — Atualização do UBU Version Governor

## Objetivo

Atualizar o `tools/ubu-version-governor` para que o fechamento de release consiga lidar melhor com branches de promoção já existentes, especialmente `release/*` e `nightly`.

## Alterações

- `tools/ubu-version-governor` atualizado para `0.1.1`.
- `push.forceWithLease` adicionado ao contrato `version-chain.json`.
- Planner passa a indicar quando o push será feito com `--force-with-lease`.
- Runner executa `git fetch --prune` antes de publicar branches com lease.
- `.gitignore` deixa de ignorar `tools/ubu-version-governor`, permitindo versionar o governor junto do projeto.
- Schema `schemas/ubu-version-chain.schema.json` atualizado.
- Contrato do projeto atualizado para `0.1.3.1`.

## Compatibilidade

Não altera o core procedural. A mudança é de governança/versionamento.

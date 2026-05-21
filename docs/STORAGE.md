# Storage SQLite

O storage inicial usa `sqlite3` direto, sem ORM.

## Tabelas

### `metadata`

Chave/valor JSON para versão e políticas.

Chaves iniciais:

- `storage_schema_version`: `storage.v1`
- `world_schema_version`: `world.v1`
- `snapshot_policy`: `{ "default_every_events": 1000 }`

### `chunks`

Persistência de resumos de chunks gerados. Não é o mundo inteiro.

### `events`

Log append-only de eventos processados. Eventos duplicados por ID são ignorados para permitir replay/import idempotente.

### `patches`

Overlay materializado por `entity_id` e `path`. O estado resolvido usa o patch mais recente por path.

### `snapshots`

Estado materializado de apoio para inspeção e evolução futura de replay otimizado.

## Estado resolvido

```text
base = entity_base_state(entity_ref)
overlay = latest_patch_map(entity_id)
resolved = apply_patch_map(base, overlay)
```

## Política de snapshots

A decisão do projeto mantida na 0.1.1 é snapshot a cada 1000 eventos. O Prompt 4 mantém snapshots manuais/por simulação; a automação rígida por threshold pode ser ampliada depois sem quebrar o contrato.

## Limitações conhecidas

- A fila futura não é persistida ainda.
- Migrações formais de schema ainda não existem.
- O replay otimizado a partir de snapshot ainda não substitui o caminho simples de materialização.


## UBU-ISO 0.1.1

Este documento participa da adoção UBU-ISO iniciada na release `0.1.1`. Mudanças futuras que afetem dados, schemas, storage, exportação, instalação ou CLI devem atualizar este documento e `docs/releases/PATCH_NOTES.md`.

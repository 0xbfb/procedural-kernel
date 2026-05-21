# Schemas

Os schemas públicos ficam em `procedural_kernel.schemas` e são validados com Pydantic.

## `WorldConfig`

Configuração geral de seed, versão de mundo, versão de schema e política de snapshots.

## `ChunkKey`

Identifica camada, região, coordenadas e versão de geração.

## `EntityRef`

Referência leve de entidade gerada no chunk:

```json
{
  "id": "npc:...",
  "kind": "npc",
  "chunk_id": "chunk:...",
  "metadata": {}
}
```

## `GeneratedChunk`

Resumo determinístico de chunk com scores e entidades.

## `Event`

Evento append-only:

```json
{
  "id": "event:...",
  "tick": 10,
  "type": "npc.killed",
  "scope": "chunk:...",
  "payload": {},
  "schema_version": "event.v1"
}
```

## `Patch`

Mudança materializada por entidade/path:

```json
{
  "entity_id": "npc:...",
  "path": "alive",
  "value": false,
  "tick": 10,
  "source_event_id": "event:...",
  "schema_version": "patch.v1"
}
```

## `Snapshot`

Estado materializado em ponto de controle.

## Bundle JSON

Gerado por `exporters/json_bundle.py`:

```json
{
  "schema_version": "bundle.v1",
  "world_version": "0.1.2",
  "kernel_version": "0.1.2",
  "seed": "uv",
  "generated_at": "...",
  "metadata": {},
  "chunks": [],
  "entities": {},
  "events": [],
  "snapshots": []
}
```

O bundle não depende da engine. A engine deve tratar versões desconhecidas de schema como incompatíveis até existir uma política formal de migração.


## UBU-ISO 0.1.1

Este documento participa da adoção UBU-ISO iniciada na release `0.1.1`. Mudanças futuras que afetem dados, schemas, storage, exportação, instalação ou CLI devem atualizar este documento e `docs/releases/PATCH_NOTES.md`.

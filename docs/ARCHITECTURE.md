# Arquitetura — Procedural Kernel

## Objetivo

O pacote é um kernel procedural mínimo, não uma engine. Ele existe para gerar dados determinísticos, persistir mudanças relevantes e exportar um contrato de dados que qualquer engine possa consumir.

## Princípio central

```text
estado atual = estado base procedural + patches persistidos
```

O estado base nasce de seed, namespace e coordenadas. As mudanças permanentes entram por eventos. Eventos geram patches. Snapshots materializam pontos de controle, mas não substituem o event log.

## Módulos principais

- `rng.py`: derivação determinística de seeds.
- `ids.py`: IDs estáveis para chunks, entidades e eventos.
- `chunks.py`: geração determinística de chunks.
- `events.py`: criação de eventos e reducers para patches.
- `storage.py`: adapter SQLite sem ORM.
- `state.py`: aplicação de patches sobre estado base.
- `decisions.py`: scoring puro/utility AI leve.
- `future.py`: fila futura por tick.
- `simulation.py`: simulação determinística mínima.
- `exporters/json_bundle.py`: bundle JSON versionado para engine.
- `benchmark.py`: benchmark sintético de geração.
- `cli.py`: interface operacional.

## Fronteiras

O pacote não contém renderer, assets, UI, loop de jogo, editor visual, IA generativa ou DSL pesada de behavior tree.

## Fluxo de uso

1. Gerar chunk determinístico.
2. Persistir chunk se ele precisa ser inspecionado/exportado.
3. Emitir eventos.
4. Reduzir eventos em patches.
5. Resolver entidade com base procedural + overlay.
6. Exportar bundle JSON para a engine.

## Crescimento futuro

As extensões pesadas devem ficar opcionais:

- `numpy` para hot paths numéricos já está no core por decisão de projeto.
- `numba` deve ficar no extra `fast`.
- `polars` e `duckdb` devem ficar no extra `analytics`.
- `hypothesis` deve ficar no extra `quality`.


## UBU-ISO 0.1.1

Este documento participa da adoção UBU-ISO iniciada na release `0.1.1`. Mudanças futuras que afetem dados, schemas, storage, exportação, instalação ou CLI devem atualizar este documento e `docs/releases/PATCH_NOTES.md`.

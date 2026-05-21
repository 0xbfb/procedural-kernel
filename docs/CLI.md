# CLI

Todos os comandos podem ser executados via console script:

```bash
procedural-kernel doctor
```

Ou diretamente pelo módulo:

```bash
PYTHONPATH=src python -m procedural_kernel.cli doctor
```

## `doctor`

Executa smoke checks de ambiente, dependências, geração determinística e SQLite.

```bash
procedural-kernel doctor
```

## `inspect`

Sem `--storage`, inspeciona um chunk determinístico:

```bash
procedural-kernel inspect --seed uv --layer city --x 10 --y 3
```

Com `--storage`, mostra resumo do SQLite:

```bash
procedural-kernel inspect --storage save.sqlite
```

Também pode resolver uma entidade específica:

```bash
procedural-kernel inspect --storage save.sqlite --entity npc:abc
```

## `simulate`

Executa uma simulação determinística mínima e persiste eventos no SQLite.

```bash
procedural-kernel simulate --storage save.sqlite --seed uv --events 100
```

Relatório Markdown:

```bash
procedural-kernel simulate --storage save.sqlite --events 10 --report markdown --report-file report.md
```

## `replay`

Lê o storage e mostra eventos, stats e snapshot mais recente.

```bash
procedural-kernel replay --storage save.sqlite
```

## `export`

Gera bundle JSON versionado para a engine.

```bash
procedural-kernel export --storage save.sqlite --out world_bundle.json --seed uv
```

Opções úteis:

```bash
procedural-kernel export --storage save.sqlite --out world_bundle.json --no-events
procedural-kernel export --storage save.sqlite --out world_bundle.json --event-limit 1000
procedural-kernel export --storage save.sqlite --out world_bundle.json --world-version 0.1.3
```

## `benchmark`

Gera entidades determinísticas em chunks sintéticos e reporta throughput.

```bash
procedural-kernel benchmark --entities 10000
procedural-kernel benchmark --entities 100000 --entities-per-chunk 512
```

## Alias

`--db` é aceito como alias de `--storage` nos comandos compatíveis.


## UBU-ISO 0.1.1

Este documento participa da adoção UBU-ISO iniciada na release `0.1.1`. Mudanças futuras que afetem dados, schemas, storage, exportação, instalação ou CLI devem atualizar este documento e `docs/releases/PATCH_NOTES.md`.

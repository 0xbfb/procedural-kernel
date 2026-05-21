# Módulo `procedural_kernel`

## Índice

- [Responsabilidade](#responsabilidade)
- [Estrutura](#estrutura)
- [Fluxos principais](#fluxos-principais)
- [Integrações](#integrações)
- [Testes](#testes)
- [Riscos de manutenção](#riscos-de-manutenção)
- [Documentos relacionados](#documentos-relacionados)

## Responsabilidade

Este módulo contém o kernel procedural mínimo. Ele gera conteúdo determinístico, aplica eventos, materializa patches, cria snapshots e exporta bundles JSON versionados para consumo por engines ou pipelines externos.

## Estrutura

- `rng.py`: seed derivada e inteiros estáveis.
- `ids.py`: IDs estáveis para chunks, entidades, eventos e snapshots.
- `chunks.py`: geração determinística por chunk/região/layer.
- `events.py`: criação de eventos e reducers para patches.
- `state.py`: resolução de estado base + overlay.
- `storage.py`: adapter SQLite.
- `simulation.py`: simulação temporal pequena.
- `future.py`: fila futura por tick.
- `decisions.py`: scoring puro.
- `exporters/`: saída JSON versionada.
- `reports/`: relatórios humanos simples.
- `cli.py`: comandos de linha de comando.

## Fluxos principais

1. `generate_chunk` cria o estado base determinístico.
2. `SQLiteStore.append_event` grava evento e patches derivados.
3. `SQLiteStore.resolve_entity` aplica overlay sobre estado base.
4. `run_temporal_simulation` agenda e processa eventos determinísticos.
5. `write_json_bundle` exporta contrato para engine/launcher.

## Integrações

O módulo não deve depender de engine, renderer, UI ou launcher. Integrações devem consumir a API pública ou o bundle JSON.

## Testes

```bash
PYTHONPATH=src pytest -q
PYTHONPATH=src python -m procedural_kernel.cli doctor
```

## Riscos de manutenção

- Alterar IDs ou seeds quebra determinismo.
- Alterar schemas exige atualização de docs e patch notes.
- Salvar mundo inteiro por padrão viola a arquitetura mínima.
- Colocar regra de UI/engine aqui aumenta acoplamento.

## Documentos relacionados

- [Arquitetura](../../docs/ARCHITECTURE.md)
- [Schemas](../../docs/SCHEMAS.md)
- [Storage](../../docs/STORAGE.md)
- [UBU-ISO/1.0](../../docs/UBU-ISO-1.0-DADOS-CAMADAS.md)

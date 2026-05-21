# Patch Notes

## 0.1.1 — Hardening UBU ISO

Data: 2026-05-21

### Adicionado

- Adoção inicial de UBU-ISO/1.0, UBU-ISO/2.0 e UBU-ISO/2.1.
- `AGENTS.md` com regras operacionais para agentes.
- `docs/README.md` e `docs/releases/`.
- `install.bat` e `run.bat` para instalação/execução Windows.
- `scripts/install/windows-install.bat` e `scripts/install/windows-run.bat` como cópias de referência.
- `logs/.gitkeep` para logs locais.
- README local em `src/procedural_kernel/README.md`.
- Exemplo mínimo em `examples/minimal_usage.py`.

### Alterado

- Versão do pacote atualizada para `0.1.1`.
- `DEFAULT_WORLD_VERSION`, `KERNEL_VERSION`, CLI `export --world-version` e `WorldConfig.world_version` alinhados para `0.1.1`.
- README principal reestruturado conforme UBU-ISO/2.0.
- `RELEASE_NOTES.md`, `PATCH_MANIFEST.md`, `docs/RELEASE_AUDIT.md` e `docs/RELEASE_CHECKLIST.md` atualizados para a release.

### Compatibilidade

- Sem breaking changes intencionais em relação à `0.1.0`.
- Storage permanece `storage.v1`.
- Bundle permanece `bundle.v1`.
- Schemas de entidade/chunk/evento/patch/snapshot permanecem `*.v1`.

### Validação

- `python -m compileall -q src tests`
- `PYTHONPATH=src pytest -q`
- `PYTHONPATH=src python -m procedural_kernel.cli doctor`
- `PYTHONPATH=src python -m procedural_kernel.cli simulate --seed release011 --events 100 --storage /tmp/pk_011.db --report json`
- `PYTHONPATH=src python -m procedural_kernel.cli replay --storage /tmp/pk_011.db --limit 3`
- `PYTHONPATH=src python -m procedural_kernel.cli inspect --storage /tmp/pk_011.db --limit 3`
- `PYTHONPATH=src python -m procedural_kernel.cli export --storage /tmp/pk_011.db --out /tmp/pk_011.json --seed release011`
- `PYTHONPATH=src python -m procedural_kernel.cli benchmark --entities 10000`

## 0.1.0 — Release inicial

Base funcional com determinismo, SQLite, eventos, patches, snapshots, replay, simulação temporal, export JSON, benchmark, CLI e documentação técnica inicial.

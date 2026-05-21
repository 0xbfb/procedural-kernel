# AGENTS — UBU Version Governor

## Papel do agente

Manter este projeto pequeno, auditável e seguro. Ele executa comandos Git potencialmente destrutivos, portanto toda alteração deve favorecer dry-run, validação e mensagens claras.

## Regras obrigatórias

1. Não tornar `--push` implícito.
2. Não fazer reset de branch por padrão.
3. Não sobrescrever tag existente sem flag/campo explícito futuro.
4. Manter `plan` livre de side effects.
5. Manter `apply` em dry-run quando `--apply` não for informado.
6. Atualizar `schemas/ubu-version-chain.schema.json` quando o contrato mudar.
7. Atualizar `docs/releases/` a cada release.
8. Manter `install.bat` com menu de canal/branch.
9. Manter `run.bat` buscando atualização antes do boot.

## Comandos úteis

```bash
python -m ubu_version_governor doctor
python -m ubu_version_governor plan --input examples/version-chain.example.json
python -m pytest
```

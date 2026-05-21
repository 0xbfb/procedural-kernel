# Release Notes

## 0.1.3 — UBU ISO suite sync

Data: 2026-05-21

A release `0.1.3` corrige arquivos faltantes do repositório, sincroniza a suíte UBU ISO mais recente e separa o versionador completo como ferramenta local de desenvolvimento.

### Destaques

- `.gitignore` raiz adicionado.
- Menu PowerShell auxiliar em `installer/install_menu.ps1`.
- Contrato final de release gerável via `scripts/generate-final-contract.py`.
- Planejamento ISO/3.1E sem dependência do governor completo dentro do repositório.
- Templates/checklists ISO sincronizados em `docs/iso/ubu_iso_suite/`.
- Política dev-only para `tools/ubu-version-governor/`.

### Breaking changes

Nenhum breaking change intencional no pacote `procedural_kernel`.

### Artefato

```text
procedural_kernel_patch_0_1_3_overlay.zip
```

## 0.1.1 — Hardening UBU ISO

Data: 2026-05-21

A release `0.1.1` consolida a `0.1.0` como base limpa de projeto, adicionando documentação operacional, normas UBU e scripts Windows para instalação/execução.

### Destaques

- Adoção de UBU-ISO/1.0 para contratos, camadas e persistência de dados.
- Adoção de UBU-ISO/2.0 para documentação técnica e fluxo de release.
- Adoção de UBU-ISO/2.1 para `install.bat` e `run.bat`.
- `AGENTS.md` para orientar patches futuros.
- Release notes e patch notes padronizadas.
- Compatibilidade preservada com os contratos `bundle.v1`, `storage.v1`, `event.v1`, `patch.v1`, `snapshot.v1` e `chunk.v1`.

### Breaking changes

Nenhum breaking change intencional.

### Artefato final

```text
procedural_kernel_release_0_1_1.zip
```

## 0.1.0 — Release inicial

Base funcional do kernel procedural mínimo.

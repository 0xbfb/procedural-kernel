# AGENTS — Procedural Kernel

Este projeto adota UBU-ISO/1.0, UBU-ISO/2.0 e UBU-ISO/2.1 a partir da release `0.1.1`.

## Leitura obrigatória antes de alterar

1. `docs/UBU-ISO-1.0-DADOS-CAMADAS.md`
2. `docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md`
3. `docs/UBU-ISO-2.1-INSTALACAO-BAT.md`
4. `README.md`
5. `docs/README.md`
6. `docs/releases/PATCH_NOTES.md`

## Regras locais do projeto

- O pacote deve continuar sendo um kernel procedural mínimo, sem virar engine completa.
- O core deve permanecer desacoplado de renderer, UI e launcher.
- Dados persistidos seguem o modelo: base procedural determinística + eventos + patches + snapshots.
- Mudanças de schema/export/storage exigem atualização de `docs/SCHEMAS.md`, `docs/STORAGE.md` e patch notes.
- `install.bat` e `run.bat` devem continuar seguros para Windows e não podem apagar saves, bancos SQLite, `.env` ou configs locais.
- Todo patch deve atualizar `PATCH_MANIFEST.md` e `docs/releases/PATCH_NOTES.md`.

---

# AGENTS — Padrão obrigatório para projetos UBU compatíveis com ISO/1.0, ISO/2.0 e ISO/2.1

> Este documento deve ser copiado ou incorporado ao `AGENTS.md` de cada projeto UBU. Ele define como agentes humanos ou de IA devem aplicar as normas em todo patch.

---

## Índice

- [Prioridade deste documento](#prioridade-deste-documento)
- [Leitura obrigatória antes de alterar o projeto](#leitura-obrigatória-antes-de-alterar-o-projeto)
- [Regra de adoção automática](#regra-de-adoção-automática)
- [Rotina obrigatória em todo patch](#rotina-obrigatória-em-todo-patch)
- [Regras específicas por ISO](#regras-específicas-por-iso)
- [Saída obrigatória do agente](#saída-obrigatória-do-agente)
- [Proibições absolutas](#proibições-absolutas)

---

## Prioridade deste documento

As ISOs UBU são normas operacionais do projeto.

Em caso de conflito:

1. instruções explícitas do usuário têm prioridade;
2. regras de segurança e integridade do projeto têm prioridade;
3. `AGENTS.md` do projeto tem prioridade sobre documentos genéricos;
4. documentos `docs/UBU-ISO-*` têm prioridade sobre documentação antiga;
5. documentação antiga deve ser atualizada ou marcada como obsoleta quando contradizer as ISOs.

---

## Leitura obrigatória antes de alterar o projeto

Antes de qualquer patch, leia, nesta ordem:

```text
docs/UBU-ISO-1.0-DADOS-CAMADAS.md
docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md
docs/UBU-ISO-2.1-INSTALACAO-BAT.md
README.md
AGENTS.md
docs/README.md
```

Se algum desses arquivos não existir, o agente deve classificar o projeto como parcialmente não conforme e aplicar a rotina de adoção inicial da ISO correspondente.

---

## Regra de adoção automática

### Projeto sem ISO

Se o projeto não possui documentos `docs/UBU-ISO-*`, o próximo patch deve incluir a adoção inicial das ISOs aplicáveis.

A adoção inicial deve:

1. criar os documentos principais da ISO em `docs/`;
2. criar ou atualizar `AGENTS.md`;
3. criar ou atualizar `README.md` com links para as ISOs;
4. criar ou atualizar `docs/README.md`;
5. criar ou atualizar `docs/releases/` conforme ISO/2.0;
6. criar ou atualizar `install.bat` e `run.bat`, quando aplicável, conforme ISO/2.1;
7. registrar patch notes informando que as ISOs foram adotadas.

### Projeto com ISO já adotada

Se o projeto já possui as ISOs, o agente não deve reescrever tudo.

A rotina correta é:

1. verificar conformidade;
2. atualizar apenas documentos afetados;
3. versionar documentação se houve alteração normativa;
4. registrar patch notes somente das mudanças reais;
5. listar pendências quando não for possível corrigir automaticamente.

---

## Rotina obrigatória em todo patch

Todo patch deve executar esta sequência:

1. **Inventário**: mapear arquivos alterados, módulos afetados e documentação relacionada.
2. **ISO/1.0**: verificar se dados, schemas, fontes, persistência ou camadas lógicas foram afetados.
3. **ISO/2.0**: verificar se README, README local, docs, patch notes ou release notes precisam mudar.
4. **ISO/2.1**: verificar se instalação, execução, dependências, bootstrap ou update foram afetados.
5. **Implementação**: alterar somente o necessário.
6. **Documentação**: atualizar documentação junto do código.
7. **Notas**: registrar patch notes obrigatoriamente.
8. **Validação**: executar testes/checks possíveis ou registrar justificativa de não execução.
9. **Saída**: informar arquivos criados, alterados, pendências e comandos testados.

---

## Regras específicas por ISO

### UBU-ISO/1.0 — Dados por camada lógica

Aplicar quando o patch alterar:

- fontes de dados;
- schemas;
- fixtures;
- adapters;
- loaders;
- serializers;
- exportadores;
- caches;
- persistência;
- seeds;
- migrations;
- contratos de dados;
- formatos JSON/YAML/CSV/SQLite/etc.

Obrigatório:

- declarar camada lógica afetada;
- documentar origem e destino dos dados;
- preservar separação entre engine, dados e instalador quando o projeto usar essa arquitetura;
- atualizar README local de dados/módulo;
- registrar alteração em patch notes.

### UBU-ISO/2.0 — Documentação técnica e releases

Aplicar em todo patch.

Obrigatório:

- patch notes sempre;
- release notes quando consolidar release;
- README local para módulo novo, complexo ou crítico;
- índice em documento com mais de 80 linhas;
- links relativos entre documentos;
- critérios explícitos para `patch > release > nightly > stable`.

### UBU-ISO/2.1 — Instalação `.bat`

Aplicar quando o projeto tiver execução Windows para usuário final ou quando o usuário solicitar instalação simplificada.

Obrigatório:

- `install.bat` deve instalar tudo com um comando;
- após instalar, deve rodar o programa;
- após sucesso, deve criar/atualizar `run.bat`;
- após sucesso, deve apagar ou agendar a remoção do próprio `install.bat`;
- `run.bat` deve procurar atualizações primeiro;
- se não houver atualização, deve inicializar direto;
- se houver atualização, deve atualizar com segurança e então inicializar;
- falhas devem ser claras e não podem apagar dados do usuário.

---

## Saída obrigatória do agente

Ao final de qualquer patch, responder com:

```markdown
## Resultado do patch

### Classificação ISO
- ISO/1.0: conforme | atualizado | pendente | não aplicável
- ISO/2.0: conforme | atualizado | pendente
- ISO/2.1: conforme | atualizado | pendente | não aplicável

### Arquivos criados
- `caminho`

### Arquivos alterados
- `caminho`

### Documentação atualizada
- `caminho`

### Testes/checks executados
```bash
comando
```

### Testes/checks não executados
- motivo

### Pendências
- item

### Observação de versão
- patch notes atualizadas: sim/não
- release notes atualizadas: sim/não/não aplicável
- install/run conforme ISO/2.1: sim/não/não aplicável
```

---

## Proibições absolutas

O agente não pode:

1. declarar teste executado sem ter executado;
2. criar release notes falsas;
3. declarar stable pronta sem validação;
4. apagar documentação útil sem substituição;
5. duplicar documento equivalente sem justificativa;
6. esconder breaking change;
7. alterar contrato de dados sem atualizar ISO/1.0;
8. alterar instalação sem atualizar ISO/2.1;
9. alterar fluxo de branches sem atualizar ISO/2.0;
10. criar `install.bat` destrutivo;
11. criar `run.bat` que atualiza sem fallback ou log mínimo;
12. ignorar patch notes.



## UBU-ISO/3.0 e UBU-ISO/3.1E

Ao fechar qualquer patch/release posterior à `0.1.2`:

1. Atualize `pyproject.toml`, `src/procedural_kernel/__init__.py`, `WorldConfig.world_version`, `KERNEL_VERSION` e o default do CLI `export --world-version`.
2. Atualize `docs/releases/version-chain.json` com a versão alvo, canais de promoção e mensagens de commit.
3. Rode `python scripts/validate_version_chain.py docs/releases/version-chain.json`.
4. Rode `PYTHONPATH=tools/ubu-version-governor/src python -m ubu_version_governor plan --input docs/releases/version-chain.json`.
5. Não execute branch/tag/push real sem flag explícita e sem revisão humana.
6. Mantenha `install.bat`, `run.bat`, `Makefile`, `Dockerfile` e `docker-compose.yml` sincronizados com o boot real do projeto.

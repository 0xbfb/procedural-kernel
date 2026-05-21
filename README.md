# Procedural Kernel

Pacote Python mínimo para geração procedural determinística, persistência de estado e exportação de dados para engines de jogos.

A estratégia central é simples:

```text
estado resolvido = base procedural determinística + patches derivados de eventos persistidos
```

Esta release `0.1.3` mantém o kernel funcional, corrige arquivos faltantes do repositório e sincroniza a suíte UBU ISO mais recente.

## Índice

- [Visão geral](#visão-geral)
- [Instalação](#instalação)
- [Execução](#execução)
- [Testes](#testes)
- [Arquitetura](#arquitetura)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Fluxo de versões](#fluxo-de-versões)
- [Documentação técnica](#documentação-técnica)
- [Contribuição](#contribuição)
- [Documentos relacionados](#documentos-relacionados)

## Visão geral

O pacote entrega:

- seeds derivadas por namespace;
- IDs estáveis e compactos;
- schemas de borda com Pydantic;
- serialização JSON com `orjson`;
- geração determinística de chunks;
- storage SQLite embutido;
- event log append-only;
- patches persistidos como overlay de estado;
- snapshots materiais;
- replay a partir dos eventos;
- scoring/utility AI leve com funções puras;
- fila de eventos futuros ordenada por tick e ID estável;
- simulação determinística com eventos persistidos;
- relatórios JSON e Markdown simples;
- export JSON versionado para consumo pela engine;
- benchmark sintético para 10k/100k entidades;
- CLI com `doctor`, `inspect`, `simulate`, `replay`, `export` e `benchmark`.

## Instalação

### Windows — um comando

Execute:

```bat
install.bat
```

O instalador cria `.venv`, instala o pacote em modo editável com extras de desenvolvimento, cria/atualiza `run.bat`, executa `doctor` e agenda a remoção do próprio `install.bat` após sucesso suficiente.

Depois da primeira instalação, use:

```bat
run.bat
```

O `run.bat` verifica atualizações quando o projeto está em um repositório Git com remote configurado e, em seguida, executa o CLI. Sem argumentos, ele roda `doctor`. Com argumentos, repassa para o CLI:

```bat
run.bat simulate --storage save.sqlite --seed uv --events 100
run.bat inspect --storage save.sqlite
run.bat export --storage save.sqlite --out world_bundle.json --seed uv
```

### Instalação local manual

Linux/macOS:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -e ".[dev]"
```

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

## Execução

```bash
procedural-kernel doctor
procedural-kernel inspect --seed uv --layer city --x 10 --y 3
procedural-kernel simulate --storage save.sqlite --seed uv --events 100
procedural-kernel inspect --storage save.sqlite
procedural-kernel replay --storage save.sqlite
procedural-kernel export --storage save.sqlite --out world_bundle.json --seed uv
procedural-kernel benchmark --entities 10000
```

Sem instalar o console script:

```bash
PYTHONPATH=src python -m procedural_kernel.cli doctor
```

## Testes

```bash
python -m compileall src tests
pytest
procedural-kernel doctor
```

Checks de release usados na `0.1.1`:

```bash
python -m compileall -q src tests
PYTHONPATH=src pytest -q
PYTHONPATH=src python -m procedural_kernel.cli doctor
PYTHONPATH=src python -m procedural_kernel.cli simulate --seed release011 --events 100 --storage /tmp/pk_011.db --report json
PYTHONPATH=src python -m procedural_kernel.cli replay --storage /tmp/pk_011.db --limit 3
PYTHONPATH=src python -m procedural_kernel.cli inspect --storage /tmp/pk_011.db --limit 3
PYTHONPATH=src python -m procedural_kernel.cli export --storage /tmp/pk_011.db --out /tmp/pk_011.json --seed release011
PYTHONPATH=src python -m procedural_kernel.cli benchmark --entities 10000
```

## Arquitetura

O kernel não salva o mundo inteiro por padrão.

```text
base procedural determinística
  + eventos persistidos
  + patches materializados
  + snapshots opcionais
  = estado resolvido
```

A fila futura é deliberadamente em memória. Ela agenda eventos e a simulação persiste apenas os eventos processados, mantendo o storage simples e auditável.

## Estrutura de pastas

```text
src/procedural_kernel/       pacote principal
src/procedural_kernel/exporters/
src/procedural_kernel/reports/
tests/                       testes automatizados
docs/                        documentação técnica e ISOs
docs/releases/               patch/release/nightly/stable notes
examples/                    exemplos pequenos de uso
scripts/install/             cópias de referência dos BATs Windows
logs/                        logs locais de install/run
```

## Fluxo de versões

O projeto segue o fluxo UBU-ISO/2.0:

```text
patch > release > nightly > stable
```

A `0.1.1` é uma release de hardening, sem breaking changes intencionais em relação à `0.1.0`.

## Documentação técnica

- `docs/README.md`
- `docs/ARCHITECTURE.md`
- `docs/CLI.md`
- `docs/SCHEMAS.md`
- `docs/STORAGE.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/RELEASE_AUDIT.md`
- `docs/UBU-ISO-1.0-DADOS-CAMADAS.md`
- `docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md`
- `docs/UBU-ISO-2.1-INSTALACAO-BAT.md`

## Contribuição

Antes de alterar o projeto, leia `AGENTS.md` e os documentos UBU-ISO em `docs/`.

Todo patch deve:

1. preservar determinismo;
2. manter compatibilidade de schemas ou documentar breaking change;
3. atualizar patch notes;
4. executar testes possíveis;
5. registrar pendências reais, sem fingir validação.

## Documentos relacionados

- [AGENTS](./AGENTS.md)
- [Docs](./docs/README.md)
- [Patch notes](./docs/releases/PATCH_NOTES.md)
- [Release notes](./docs/releases/RELEASE_NOTES.md)
- [Arquitetura](./docs/ARCHITECTURE.md)
- [CLI](./docs/CLI.md)
- [Schemas](./docs/SCHEMAS.md)
- [Storage](./docs/STORAGE.md)


## Versionamento UBU ISO/3.1E

A partir da release `0.1.3`, o projeto inclui governança de versão compatível com a cadeia:

```text
patch > release > nightly > stable
```

Arquivos principais:

```text
docs/releases/version-chain.json
schemas/ubu-version-chain.schema.json
scripts/validate_version_chain.py
scripts/version/plan_version_chain.py
tools/ubu-version-governor/
```

Comandos úteis:

```bash
python scripts/validate_version_chain.py docs/releases/version-chain.json
PYTHONPATH=tools/ubu-version-governor/src python -m ubu_version_governor plan --input docs/releases/version-chain.json
```

No Windows, `install.bat` abre um menu para escolher `patch`, `release`, `nightly`, `stable`, branch customizada ou instalação local do ZIP atual.

## Inicializadores UBU ISO/3.0

Também foram adicionados:

```text
Makefile
Dockerfile
docker-compose.yml
.env.example
.dockerignore
scripts/bootstrap_contract_check.py
```

Fluxo rápido:

```bash
make install
make test
make doctor
make validate-version-chain
make version-plan
```

## 0.1.3

Esta versão adiciona `.gitignore`, menu PowerShell auxiliar, contrato final de release, templates/checklists ISO completos e política dev-only para `tools/ubu-version-governor/`.

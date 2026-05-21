# UBU Version Governor

Projeto de referência da **UBU-ISO/3.1 E** para padronizar commit, versionamento, branches, tags e promoção de versões na cadeia:

```text
patch > release > nightly > stable
```

A ferramenta lê um JSON final deixado pelo último prompt/patch e executa, em modo seguro, a cadeia necessária para preparar release, atualizar branches e criar tags.

## O que este projeto resolve

Quando um patch está pronto para virar release, normalmente ainda faltam passos manuais:

- commit final;
- atualização de notas de patch/release;
- criação ou atualização de `release/{version}`;
- promoção para `nightly`;
- promoção para `stable` quando autorizado;
- criação de tag `vX.Y.Z`;
- push de branches e tags.

O `ubu-version-governor` transforma isso em um fluxo reproduzível guiado por JSON.

## Segurança por padrão

- `plan` nunca altera o repositório.
- `apply` roda em dry-run por padrão.
- execução real exige `--apply`.
- push exige `--push` além de `--apply`.
- reset destrutivo de branch não é comportamento padrão.

## Instalação Windows

Execute:

```bat
install.bat
```

O instalador abre um menu perguntando qual versão/canal instalar:

```text
1. Patch
2. Release
3. Nightly
4. Stable
5. Branch customizada
```

Quando o projeto estiver em um clone Git, o menu faz `fetch`, muda para a branch escolhida e instala a ferramenta. Quando estiver rodando a partir de um ZIP sem `.git`, ele instala localmente e informa que troca de branch exige clone Git ou remoto configurado.

## Execução

```bat
run.bat
```

ou:

```bash
python -m ubu_version_governor --help
```

## Fluxo recomendado

1. O último prompt do patch gera `docs/releases/version-chain.json`.
2. Rode o plano:

```bash
python -m ubu_version_governor plan --input docs/releases/version-chain.json
```

3. Aplique localmente:

```bash
python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply
```

4. Aplique com push quando estiver seguro:

```bash
python -m ubu_version_governor apply --input docs/releases/version-chain.json --apply --push
```

## Exemplo rápido

```bash
python -m ubu_version_governor plan --input examples/version-chain.example.json
```

## Estrutura

```text
src/ubu_version_governor/
  cli.py
  contract.py
  git_ops.py
  planner.py
  runner.py
schemas/
  ubu-version-chain.schema.json
examples/
  version-chain.example.json
installer/
  install_menu.ps1
install.bat
run.bat
```

## Conformidade UBU

Este projeto já traz adoção inicial das normas:

- UBU-ISO/2.0 — documentação e release notes;
- UBU-ISO/2.1 — `install.bat` e `run.bat`;
- UBU-ISO/3.0 — bootstrap, Makefile, Dockerfile e compose;
- UBU-ISO/3.1 E — versionamento, branches, tags e promoção.

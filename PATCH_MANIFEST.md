# PATCH_MANIFEST — Atualização para UBU Suite 0.3.1

## Base usada

Projeto antigo antes da padronização UBU Suite 0.3.1.

## Objetivo

Atualizar o projeto para o padrão UBU Suite 0.3.1, incluindo release governor, RepoUrl oficial do kit, ISO 3.1 e estrutura dev-only do versionador.

## Repo oficial do kit

https://github.com/0xbfb/ubu-suite.git

## Arquivos criados

- `release.ps1`
- `patch-legacy.ps1`
- `release.config.json`
- `.env.example`
- `.gitattributes`
- `tools/release/git-release.ps1`
- `tools/release/README.md`
- `tools/patch/update-legacy-project.ps1`
- `dev/versionador/.gitignore`
- `dev/versionador/README.md`
- `docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md`
- `docs/POLITICA_VERSIONADOR_DEV_ONLY.md`
- `docs/POLITICA_ISO_STACK_AWARE.md`
- `docs/UBU-ISO-3.1-RELEASE-GOVERNOR.md`

## Arquivos editados

- `.gitignore`, se já existia.
- documentação existente, se necessário.

## Arquivos removidos

Nenhum.

## Arquivos intencionalmente não alterados

- Código de aplicação.
- Configurações específicas da stack não relacionadas ao release governor.
- Instaladores não utilizados.
- Dockerfile, docker-compose.yml, Makefile, install.bat e run.bat, exceto se já existiam e fazem parte real da stack.

## Validações executadas

- `git status --short`
- `git diff --check`
- `git ls-files dev/versionador`
- busca por `working-tree-encoding`
- conferência de `officialRepoUrl`
- revisão manual dos scripts PowerShell

## Riscos restantes

- Os scripts PowerShell não foram executados neste ambiente Linux sem PowerShell instalado.
- Em projetos com `.gitignore` existente, prefira aplicar via `patch-legacy.ps1`, pois ele preserva regras existentes e apenas adiciona o bloco UBU Suite 0.3.1.

## Observações

O versionador permanece dev-only e não deve ser empacotado em releases.

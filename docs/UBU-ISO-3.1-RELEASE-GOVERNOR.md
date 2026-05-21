# UBU-ISO-3.1 — Release Governor

## Versão alvo

```text
UBU Suite: 0.3.1
Repo oficial: https://github.com/0xbfb/ubu-suite.git
```

## Objetivo

Padronizar a cadeia de versionamento e release:

```text
dev -> release/<versao> -> nightly -> stable -> tag
```

## Arquivos centrais

```text
release.ps1
patch-legacy.ps1
tools/release/git-release.ps1
tools/patch/update-legacy-project.ps1
release.config.json
.env.example
```

## Prioridade de configuração

```text
flags > .env > release.config.json > defaults
```

## Políticas obrigatórias

- `versionadorDevOnly=true`
- `stackAwareIso=true`
- `forbidUnusedInstallers=true`
- `forbidWorkingTreeEncodingBom=true`

## RepoUrl

O `release.config.json` deve registrar o repo oficial do kit:

```text
https://github.com/0xbfb/ubu-suite.git
```

O `project.repoUrl` pode ser informado por:

1. flag `-RepoUrl`;
2. `.env` em `UBU_PROJECT_REPO_URL`;
3. `release.config.json`.

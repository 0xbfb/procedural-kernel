# UBU ISO 3.1 — Release config-first

## Objetivo

A partir da UBU Suite 0.3.3, o fechamento de qualquer patch ou release deve atualizar `release.config.json` antes da publicação.

O objetivo é fazer o `release.ps1` consumir a configuração versionada do projeto, reduzindo a necessidade de passar parâmetros manuais a cada release.

## Regra principal

O comando oficial desejado para projetos padronizados é:

```powershell
.\release.ps1 -DryRun
.\release.ps1
```

Flags continuam permitidas, mas devem ser usadas como override pontual.

## Prioridade de configuração

```text
flags > .env > release.config.json > defaults seguros
```

## Campos obrigatórios

`release.config.json` deve conter:

- `schemaVersion = 3.0`.
- `kit.officialRepoUrl = https://github.com/0xbfb/ubu-suite.git`.
- `kit.version`.
- `project.repoUrl`.
- `currentRelease.version`.
- `currentRelease.kind` com `patch` ou `release`.
- `currentRelease.title`.
- `currentRelease.description`.
- `currentRelease.tag`.
- branches do projeto.
- políticas ativas.

## Fechamento obrigatório do prompt final

O último prompt de implementação deve:

1. Atualizar `release.config.json`.
2. Preencher `currentRelease`.
3. Preencher `project.repoUrl`.
4. Preencher `kit.officialRepoUrl`.
5. Preencher `kit.version`.
6. Declarar se é `patch` ou `release`.
7. Gerar título e descrição.
8. Entregar `.\release.ps1 -DryRun` e `.\release.ps1` como comandos principais, removendo o caractere de escape visual se necessário.

## Proibição

Não gere Dockerfile, docker-compose.yml, Makefile, install.bat ou run.bat apenas por padrão. Inicializadores continuam stack-aware.

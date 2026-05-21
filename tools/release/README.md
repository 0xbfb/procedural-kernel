# Automação de release Git

## Arquivos

- `release.ps1`: disparador curto na raiz do projeto.
- `tools/release/git-release.ps1`: orquestrador completo.
- `.env.example`: modelo de configuração local.
- `release.config.json`: configuração geral versionada com metadados da última release/patch.

## Uso básico

```powershell
Copy-Item .env.example .env
notepad .env
./release.ps1 -Version 0.2.6 -DryRun
./release.ps1 -Version 0.2.6
```

## Uso com flags

```powershell
./release.ps1 `
  -Version 0.2.6 `
  -RepoUrl https://github.com/owner/repo.git `
  -ReleaseKind release `
  -Title "UBU orchestration suite" `
  -Description "Suite com automação de release Git, prompts e templates atualizados"
```

## Patch

```powershell
./release.ps1 `
  -Version 0.2.6 `
  -RepoUrl https://github.com/owner/repo.git `
  -ReleaseKind patch `
  -PatchTitle "Correção do disparador de release" `
  -PatchDescription "Ajusta o script PowerShell e atualiza metadados do pacote"
```

## Configuração geral

A cada execução, salvo com `-SkipConfigUpdate`, o script atualiza `release.config.json` com:

- tipo do lançamento: `release` ou `patch`;
- versão;
- título;
- descrição;
- tag;
- branches usadas;
- remoto;
- mensagem de commit;
- histórico limitado às últimas 50 execuções.

## Cadeia de promoção

O script prepara e publica, salvo com `-NoPush`, a cadeia:

```text
release/<versao> -> nightly -> stable
```

A branch base padrão é `dev`.

## Proteção do versionador

A pasta `dev/versionador` é preservada apenas como estrutura dev-only. O script garante `.gitignore` interno e falha caso arquivos reais do versionador estejam versionados.


## Observacao sobre `--force-with-lease`

A partir da versao 0.2.6, o orquestrador executa `git fetch origin --prune --tags` antes do push para evitar rejeicao por `stale info` quando o remoto ja tem branches que a copia local ainda nao conhece.

Se o remoto tiver historico que nao deve ser sobrescrito, rode primeiro com `-DryRun` e revise `git log --oneline --graph --all --decorate` antes de usar `-Force`.

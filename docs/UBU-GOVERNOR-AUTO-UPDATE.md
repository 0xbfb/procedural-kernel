# UBU Governor Auto-update

O governor deve verificar o repositório oficial do UBU Suite antes de publicar qualquer release ou patch.

Repo oficial:

```text
https://github.com/0xbfb/ubu-suite.git
```

## Fluxo

1. `release.ps1` lê `release.config.json` e `.env`.
2. `release.ps1` chama `tools/governor/update-governor.ps1`.
3. O updater consulta o UBU Suite oficial.
4. Se a versão remota for igual ou menor, nada é alterado.
5. Se a versão remota for maior e compatível, apenas arquivos do governor são atualizados.
6. O fluxo Git continua em `tools/release/git-release.ps1`.

## Política de compatibilidade

A política padrão é:

```json
"autoUpdatePolicy": "compatible_only"
```

Isso permite atualização automática quando o `MAJOR` da versão local e remota é igual.

Para versões com `MAJOR` diferente, o updater exige `-Force` ou deve ser pulado conscientemente com `-SkipKitUpdate`.

## Arquivos proibidos

O updater nunca deve copiar:

- `.git/`
- `.env`
- `node_modules/`
- `vendor/`
- builds, caches ou dumps
- conteúdo real de `dev/versionador`, exceto `.gitignore` e `README.md`
- código de aplicação fora da lista gerenciada

## Comandos

```powershell
.\release.ps1 -DryRun
.\release.ps1
.\release.ps1 -SkipKitUpdate
```


## Regra 0.3.5 — compatibilidade com config remota legada

O auto-update do governor deve tolerar kits remotos antigos que ainda não possuem `kit.version` em `release.config.json`. A ordem de fallback para inferir versão é: `kit.version`, `currentRelease.version`, `lastRelease.version`, `implementationStage.release` e `releaseHistory[].version`. Se nenhum campo existir, o release deve continuar sem aplicar auto-update, registrando aviso claro.

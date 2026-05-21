# Guia — Release Git Automatizado

Este projeto usa o padrão **UBU Suite 0.3.1** para padronizar releases Git sem alterar código de aplicação.

## Repo oficial do kit

```text
https://github.com/0xbfb/ubu-suite.git
```

## Fluxo esperado

```text
dev -> release/<versao> -> nightly -> stable -> tag
```

## 1. Configurar `.env` local

```powershell
Copy-Item .env.example .env
notepad .env
```

Exemplo de `.env` local:

```env
UBU_PROJECT_REPO_URL=https://github.com/owner/project.git
UBU_KIT_REPO_URL=https://github.com/0xbfb/ubu-suite.git
UBU_SOURCE_BRANCH=dev
UBU_RELEASE_BRANCH_PREFIX=release/
UBU_NIGHTLY_BRANCH=nightly
UBU_STABLE_BRANCH=stable
```

## 2. Testar release sem push

```powershell
.\release.ps1 `
  -Version 0.3.1 `
  -RepoUrl https://github.com/owner/project.git `
  -ReleaseKind patch `
  -PatchTitle "Atualizacao para UBU Suite 0.3.1" `
  -PatchDescription "Padroniza release governor, RepoUrl oficial do kit, estrutura dev-only do versionador e ISO 3.1" `
  -DryRun
```

## 3. Rodar release real

```powershell
.\release.ps1 `
  -Version 0.3.1 `
  -RepoUrl https://github.com/owner/project.git `
  -ReleaseKind patch `
  -PatchTitle "Atualizacao para UBU Suite 0.3.1" `
  -PatchDescription "Padroniza release governor, RepoUrl oficial do kit, estrutura dev-only do versionador e ISO 3.1" `
  -Force
```

## 4. Migrar projeto antigo a partir do kit

Rodar a partir da raiz do kit UBU Suite 0.3.1:

```powershell
.\patch-legacy.ps1 `
  -TargetPath "C:\caminho\do\projeto-antigo" `
  -RepoUrl "https://github.com/owner/project.git" `
  -Version 0.3.1 `
  -Title "Atualizacao para UBU Suite 0.3.1" `
  -Description "Adiciona release governor, RepoUrl oficial do kit, ISO 3.1 e estrutura dev-only do versionador" `
  -Force
```

## 5. Validar versionador dev-only

```powershell
git ls-files dev/versionador
```

Resultado esperado:

```text
dev/versionador/.gitignore
dev/versionador/README.md
```

Se aparecer qualquer outro arquivo dentro de `dev/versionador`, remova do tracking:

```powershell
git rm --cached -r dev/versionador
git add dev/versionador/.gitignore dev/versionador/README.md .gitignore
git commit -m "chore: keep versionador as dev-only ignored structure"
```

## 6. Validar ausência de `working-tree-encoding` inválido

```powershell
Select-String -Path .gitattributes -Pattern "working-tree-encoding"
```

Resultado esperado: nenhum resultado.

## 7. Validar scripts principais

```powershell
Select-String -Path .\release.ps1 -Pattern "0.3.1"
Select-String -Path .\tools\release\git-release.ps1 -Pattern "0.3.1"
Select-String -Path .\patch-legacy.ps1 -Pattern "0.3.1"
Select-String -Path .\tools\patch\update-legacy-project.ps1 -Pattern "0.3.1"
```

## 8. Validar status antes do commit

```powershell
git status --short
git diff -- .gitattributes .gitignore release.config.json release.ps1 patch-legacy.ps1
```

# Versionador dev-only

Estrutura local reservada pelo UBU ISO 3.1.

O programa real do versionador, builds, zips, caches, scripts gerados, runtimes e binarios nao devem subir em patches nem releases.

Somente estes arquivos devem ser versionados:

- dev/versionador/.gitignore
- dev/versionador/README.md
"@ -Encoding UTF8
} else {
    Write-Host "[dry-run] garantir dev/versionador/.gitignore e README.md"
}

 = Split-Path -Leaf C:\Users\ti\OneDrive\Documentos\Code\ubu\procedural-kernel
 = (Get-Date).ToString("o")
 = [ordered]@{
    schemaVersion = "3.0"
    updatedAt = 
    kit = [ordered]@{
        name = "UBU Suite"
        version = 0.3.5
        officialRepoUrl = https://github.com/0xbfb/ubu-suite.git
        officialStableBranch = "stable"
        officialReleaseBranchPrefix = "release/"
        autoUpdateGovernor = True
        autoUpdatePolicy = "compatible_only"
        iso = "UBU-ISO-3.1"
    }
    project = [ordered]@{
        name = 
        repoUrl = https://github.com/0xbfb/procedural-kernel.git
        remoteName = "origin"
        sourceBranch = "dev"
        releaseBranchPrefix = "release/"
        nightlyBranch = "nightly"
        stableBranch = "stable"
    }
    currentRelease = [ordered]@{
        version = 0.3.5
        kind = patch
        title = Atualizacao para UBU Governor 0.3.5
        description = Atualiza release governor, modo config-first, release.bat, RepoUrl oficial do kit e protecoes dev-only
        tag = v0.3.5
        baseBranch = "dev"
        targetReleaseBranch = release/0.3.5
        createdAt = 
    }
    releaseDefaults = [ordered]@{
        push = True
        forceWithLease = [bool]True
        dryRun = False
        requireCleanWorkingTree = False
        updateConfigBeforeCommit = True
        syncRemoteBeforePush = True
        checkKitUpdatesBeforeRelease = True
    }
    governorFiles = [ordered]@{
        managed = release.ps1 release.bat patch-legacy.ps1 tools/release/git-release.ps1 tools/patch/update-legacy-project.ps1 tools/governor/update-governor.ps1 tools/release/README.md .env.example docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md docs/POLITICA_VERSIONADOR_DEV_ONLY.md docs/POLITICA_ISO_STACK_AWARE.md docs/UBU_ISO_3_1_RELEASE_GOVERNOR.md docs/UBU-ISO-3.1-RELEASE-CONFIG-FIRST.md docs/UBU-GOVERNOR-AUTO-UPDATE.md docs/UBU-ISO-3.1-RELEASE-AUTO-UPDATE.md
        devOnly = @("dev/versionador/.gitignore", "dev/versionador/README.md")
    }
    policies = [ordered]@{
        versionadorDevOnly = True
        stackAwareIso = True
        forbidUnusedInstallers = True
        forbidWorkingTreeEncodingBom = True
        skipSameSourceAndDestination = True
        validateNonEmptyTargetPath = True
        releaseConfigDriven = True
        checkKitUpdatesBeforeRelease = True
        governorAutoUpdateDoesNotTouchAppCode = True
        legacyPatcherWritesCompleteReleaseConfig = True
        releaseBatRequired = True
        releaseBatDelegatesToReleasePs1 = True
        releaseConfigIsPrimarySource = True
        flagsAreOnlyOverrides = True
    }
    commands = [ordered]@{
        publishPowerShell = ".\\release.ps1"
        publishBatch = ".\\release.bat"
        dryRunPowerShell = ".\\release.ps1 -DryRun"
        dryRunBatch = ".\\release.bat -DryRun"
    }
    lastRelease = [ordered]@{
        version = ""
        kind = ""
        title = ""
        description = ""
        tag = ""
        createdAt = ""
    }
    releaseHistory = @()
    implementationStage = [ordered]@{
        release = "0.3.5"
        prompt = 4
        name = "Legacy patcher config-first"
        behaviorChange = True
        notes = "patch-legacy.ps1 prepara release.config.json completo no projeto alvo para permitir .\\release.ps1 -DryRun e .\\release.ps1 sem flags apos a migracao."
    }
}
To-JsonFile -Path (Join-Path C:\Users\ti\OneDrive\Documentos\Code\ubu\procedural-kernel "release.config.json") -Payload 

 = Join-Path C:\Users\ti\OneDrive\Documentos\Code\ubu\procedural-kernel "docs"
if (-not False) { New-Item -ItemType Directory -Force -Path  | Out-Null }
if (-not False) {
    Set-Content -LiteralPath (Join-Path  "UBU_ISO_3_1_RELEASE_GOVERNOR.md") -Encoding UTF8 -Value @"
# UBU ISO 3.1 - Release Governor aplicado

Este projeto foi atualizado para o formato UBU ISO 3.1 config-first.

## Repositorios

- Projeto: $RepoUrl
- Kit oficial UBU: $ResolvedOfficialKitRepoUrl

## Fluxo apos a migracao

Teste primeiro:

`powershell
.\release.ps1 -DryRun
`

Publique depois:

`powershell
.\release.ps1
`

Ou pelo BAT:

`at
release.bat
`

O elease.ps1 consome elease.config.json por padrao. Flags devem ser usadas apenas como override.

## Protecoes

- dev/versionador permanece dev-only.
- .env real nao deve ser versionado.
- .gitattributes nao deve usar working-tree-encoding=UTF-8-BOM.
- O auto-update do governor pode atualizar somente arquivos gerenciados listados em elease.config.json.
- Nenhum codigo de aplicacao deve ser alterado por este patcher.

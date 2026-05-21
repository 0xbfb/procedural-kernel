[CmdletBinding()]
param(
    [string]$TargetPath = ".",
    [string]$RepoUrl,
    [string]$OfficialKitRepoUrl,
    [string]$Version = "0.3.5",
    [ValidateSet("release", "patch")]
    [string]$ReleaseKind = "patch",
    [string]$Title = "Atualizacao para UBU Suite 0.3.5",
    [string]$Description = "Adiciona release governor config-first, RepoUrl oficial do kit, autoatualizacao do governor e estrutura dev-only do versionador.",
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptVersion = "0.3.5"
$DefaultOfficialKitRepoUrl = "https://github.com/0xbfb/ubu-suite.git"

function Fail([string]$Message) { throw "[legacy-patch:$ScriptVersion] $Message" }
function Is-Blank([AllowNull()][string]$Value) { return [string]::IsNullOrWhiteSpace($Value) }

function Resolve-FullPath([string]$Path) {
    if (Is-Blank $Path) { return $null }
    try {
        $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
        return [System.IO.Path]::GetFullPath($resolved.Path)
    } catch {
        return $null
    }
}

function Get-FullPathNoRequire([string]$Path) {
    if (Is-Blank $Path) { return $null }
    return [System.IO.Path]::GetFullPath($Path)
}

function Test-SamePath([string]$A, [string]$B) {
    if (Is-Blank $A -or Is-Blank $B) { return $false }
    $fullA = Get-FullPathNoRequire $A
    $fullB = Get-FullPathNoRequire $B
    return ($fullA -ieq $fullB)
}

function Read-DotEnvValue([string]$Path, [string[]]$Names) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith('#') -or $trimmed.IndexOf('=') -lt 1) { continue }
        $idx = $trimmed.IndexOf('=')
        $key = $trimmed.Substring(0, $idx).Trim()
        $value = $trimmed.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($Names -contains $key -and -not (Is-Blank $value)) { return $value }
    }
    return $null
}

function Try-Get-OriginUrl([string]$Path) {
    Push-Location $Path
    try {
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) { return $null }
        $url = & git remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0 -and -not (Is-Blank $url)) { return [string]$url }
        return $null
    } finally {
        Pop-Location
    }
}

function Copy-FileFromKit([string]$RelativePath, [string]$DestinationRelativePath) {
    $source = Join-Path $KitRoot $RelativePath
    $destination = Join-Path $ResolvedTargetPath $DestinationRelativePath

    if (-not (Test-Path -LiteralPath $source)) {
        Fail "Arquivo fonte do kit nao encontrado: $source"
    }

    $sourceFull = Resolve-FullPath $source
    $destinationFull = Get-FullPathNoRequire $destination

    if (Test-SamePath $sourceFull $destinationFull) {
        Write-Host "SKIP: origem e destino sao o mesmo arquivo: $DestinationRelativePath"
        return
    }

    if ($DryRun) {
        Write-Host "[dry-run] copiar $RelativePath -> $DestinationRelativePath"
        return
    }

    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    Copy-Item -LiteralPath $source -Destination $destination -Force
}

function Ensure-TextContains([string]$Path, [string]$Block, [string]$MarkerRegex) {
    if ($DryRun) { Write-Host "[dry-run] garantir bloco em $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType File -Path $Path -Force | Out-Null }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ($content -notmatch $MarkerRegex) {
        Set-Content -LiteralPath $Path -Value ($content.TrimEnd() + "`r`n" + $Block.TrimEnd() + "`r`n") -Encoding UTF8
    }
}

function Ensure-GitAttributes([string]$Path) {
    $safeLines = @(
        "* text=auto",
        "*.ps1 text eol=crlf",
        "*.bat text eol=crlf",
        "*.cmd text eol=crlf",
        "*.md text eol=lf",
        "*.json text eol=lf",
        "*.yml text eol=lf",
        "*.yaml text eol=lf",
        "*.html text eol=lf",
        "*.css text eol=lf",
        "*.js text eol=lf",
        "*.ts text eol=lf",
        "*.php text eol=lf",
        "*.py text eol=lf"
    )

    if ($DryRun) { Write-Host "[dry-run] garantir .gitattributes seguro em $Path"; return }

    $content = ""
    if (Test-Path -LiteralPath $Path) { $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 }
    $lines = @()
    foreach ($line in ($content -split "`r?`n")) {
        $trim = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trim)) { continue }
        if ($trim -match 'working-tree-encoding') { continue }
        if ($safeLines -contains $trim) { continue }
        $lines += $line
    }
    foreach ($safe in $safeLines) { if ($lines -notcontains $safe) { $lines += $safe } }
    Set-Content -LiteralPath $Path -Value (($lines -join "`r`n") + "`r`n") -Encoding UTF8
}

function To-JsonFile([string]$Path, [object]$Payload) {
    if ($DryRun) { Write-Host "[dry-run] atualizar $Path"; return }
    $json = $Payload | ConvertTo-Json -Depth 30
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

if (Is-Blank $TargetPath) {
    Fail "TargetPath vazio. Use -TargetPath (Get-Location).Path, -TargetPath . ou informe o caminho absoluto do projeto alvo. Verifique tambem se voce nao digitou `$PDW em vez de `$PWD."
}

$KitRootResolved = Resolve-FullPath (Join-Path $PSScriptRoot "../..")
if (Is-Blank $KitRootResolved) { Fail "Nao foi possivel resolver a raiz do kit a partir de $PSScriptRoot" }
$KitRoot = $KitRootResolved

$ResolvedTargetPathValue = Resolve-FullPath $TargetPath
if (Is-Blank $ResolvedTargetPathValue) { Fail "TargetPath nao encontrado ou invalido: $TargetPath" }
$ResolvedTargetPath = $ResolvedTargetPathValue
$ResolvedOfficialKitRepoUrl = if (Is-Blank $OfficialKitRepoUrl) { $DefaultOfficialKitRepoUrl } else { $OfficialKitRepoUrl }

if (Test-SamePath $KitRoot $ResolvedTargetPath) {
    Write-Host "AVISO: o projeto alvo e a raiz do kit sao o mesmo caminho. Arquivos identicos serao ignorados para evitar Copy-Item sobre ele mesmo."
}

if (Is-Blank $RepoUrl) { $RepoUrl = Read-DotEnvValue -Path (Join-Path $ResolvedTargetPath ".env") -Names @('UBU_PROJECT_REPO_URL', 'UBU_REPO_URL', 'REPO_URL', 'GIT_REMOTE_URL') }
if (Is-Blank $RepoUrl) { $RepoUrl = Try-Get-OriginUrl -Path $ResolvedTargetPath }
if (Is-Blank $RepoUrl) { Fail "Informe -RepoUrl ou configure UBU_PROJECT_REPO_URL no .env do projeto alvo." }

$ResolvedTag = "v$Version"
$ResolvedReleaseBranch = "release/$Version"

Write-Host "==> UBU legacy project patch $ScriptVersion"
Write-Host "Alvo:        $ResolvedTargetPath"
Write-Host "RepoUrl:     $RepoUrl"
Write-Host "Kit oficial: $ResolvedOfficialKitRepoUrl"
Write-Host "Versao:      $Version"
Write-Host "Tipo:        $ReleaseKind"
Write-Host "Dry-run:     $([bool]$DryRun)"
Write-Host "Force:       $([bool]$Force)"

$managedFiles = @(
    "release.ps1",
    "release.bat",
    "patch-legacy.ps1",
    "tools/release/git-release.ps1",
    "tools/patch/update-legacy-project.ps1",
    "tools/governor/update-governor.ps1",
    "tools/release/README.md",
    ".env.example",
    "docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md",
    "docs/POLITICA_VERSIONADOR_DEV_ONLY.md",
    "docs/POLITICA_ISO_STACK_AWARE.md",
    "docs/UBU_ISO_3_1_RELEASE_GOVERNOR.md",
    "docs/UBU-ISO-3.1-RELEASE-CONFIG-FIRST.md",
    "docs/UBU-GOVERNOR-AUTO-UPDATE.md",
    "docs/UBU-ISO-3.1-RELEASE-AUTO-UPDATE.md"
)

foreach ($file in $managedFiles) {
    $source = Join-Path $KitRoot $file
    if (Test-Path -LiteralPath $source) { Copy-FileFromKit -RelativePath $file -DestinationRelativePath $file }
    else { Write-Host "SKIP: arquivo opcional do kit ausente: $file" }
}

Ensure-GitAttributes -Path (Join-Path $ResolvedTargetPath ".gitattributes")

$gitIgnoreBlock = @"

# UBU dev-only versionador
# O programa real do versionador nunca deve subir em patches/releases.
.env
.env.local
.env.*.local
dev/versionador/*
!dev/versionador/.gitignore
!dev/versionador/README.md
"@
Ensure-TextContains -Path (Join-Path $ResolvedTargetPath ".gitignore") -Block $gitIgnoreBlock -MarkerRegex 'dev/versionador/\*'

$versionadorDir = Join-Path $ResolvedTargetPath "dev/versionador"
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $versionadorDir | Out-Null }
if (-not $DryRun) {
    Set-Content -LiteralPath (Join-Path $versionadorDir ".gitignore") -Value "*`r`n!.gitignore`r`n!README.md`r`n" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $versionadorDir "README.md") -Value @"
# Versionador dev-only

Estrutura local reservada pelo UBU ISO 3.1.

O programa real do versionador, builds, zips, caches, scripts gerados, runtimes e binarios nao devem subir em patches nem releases.

Somente estes arquivos devem ser versionados:

- `dev/versionador/.gitignore`
- `dev/versionador/README.md`
"@ -Encoding UTF8
} else {
    Write-Host "[dry-run] garantir dev/versionador/.gitignore e README.md"
}

$projectName = Split-Path -Leaf $ResolvedTargetPath
$now = (Get-Date).ToString("o")
$config = [ordered]@{
    schemaVersion = "3.0"
    updatedAt = $now
    kit = [ordered]@{
        name = "UBU Suite"
        version = $ScriptVersion
        officialRepoUrl = $ResolvedOfficialKitRepoUrl
        officialStableBranch = "stable"
        officialReleaseBranchPrefix = "release/"
        autoUpdateGovernor = $true
        autoUpdatePolicy = "compatible_only"
        iso = "UBU-ISO-3.1"
    }
    project = [ordered]@{
        name = $projectName
        repoUrl = $RepoUrl
        remoteName = "origin"
        sourceBranch = "dev"
        releaseBranchPrefix = "release/"
        nightlyBranch = "nightly"
        stableBranch = "stable"
    }
    currentRelease = [ordered]@{
        version = $Version
        kind = $ReleaseKind
        title = $Title
        description = $Description
        tag = $ResolvedTag
        baseBranch = "dev"
        targetReleaseBranch = $ResolvedReleaseBranch
        createdAt = $now
    }
    releaseDefaults = [ordered]@{
        push = $true
        forceWithLease = [bool]$Force
        dryRun = $false
        requireCleanWorkingTree = $false
        updateConfigBeforeCommit = $true
        syncRemoteBeforePush = $true
        checkKitUpdatesBeforeRelease = $true
    }
    governorFiles = [ordered]@{
        managed = $managedFiles
        devOnly = @("dev/versionador/.gitignore", "dev/versionador/README.md")
    }
    policies = [ordered]@{
        versionadorDevOnly = $true
        stackAwareIso = $true
        forbidUnusedInstallers = $true
        forbidWorkingTreeEncodingBom = $true
        skipSameSourceAndDestination = $true
        validateNonEmptyTargetPath = $true
        releaseConfigDriven = $true
        checkKitUpdatesBeforeRelease = $true
        governorAutoUpdateDoesNotTouchAppCode = $true
        legacyPatcherWritesCompleteReleaseConfig = $true
        releaseBatRequired = $true
        releaseBatDelegatesToReleasePs1 = $true
        releaseConfigIsPrimarySource = $true
        flagsAreOnlyOverrides = $true
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
        behaviorChange = $true
        notes = "patch-legacy.ps1 prepara release.config.json completo no projeto alvo para permitir .\\release.ps1 -DryRun e .\\release.ps1 sem flags apos a migracao."
    }
}
To-JsonFile -Path (Join-Path $ResolvedTargetPath "release.config.json") -Payload $config

$docDir = Join-Path $ResolvedTargetPath "docs"
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $docDir | Out-Null }
if (-not $DryRun) {
    Set-Content -LiteralPath (Join-Path $docDir "UBU_ISO_3_1_RELEASE_GOVERNOR.md") -Encoding UTF8 -Value @"
# UBU ISO 3.1 - Release Governor aplicado

Este projeto foi atualizado para o formato UBU ISO 3.1 config-first.

## Repositorios

- Projeto: `$RepoUrl`
- Kit oficial UBU: `$ResolvedOfficialKitRepoUrl`

## Fluxo apos a migracao

Teste primeiro:

```powershell
.\release.ps1 -DryRun
```

Publique depois:

```powershell
.\release.ps1
```

Ou pelo BAT:

```bat
release.bat
```

O `release.ps1` consome `release.config.json` por padrao. Flags devem ser usadas apenas como override.

## Protecoes

- `dev/versionador` permanece dev-only.
- `.env` real nao deve ser versionado.
- `.gitattributes` nao deve usar `working-tree-encoding=UTF-8-BOM`.
- O auto-update do governor pode atualizar somente arquivos gerenciados listados em `release.config.json`.
- Nenhum codigo de aplicacao deve ser alterado por este patcher.
"@
}

Write-Host "==> Patch legado concluido. Revise git diff antes de commitar."
Write-Host "Comandos sugeridos para validar e publicar dentro do projeto alvo:"
Write-Host ".\\release.ps1 -DryRun"
Write-Host ".\\release.ps1"
Write-Host ".\\release.bat"

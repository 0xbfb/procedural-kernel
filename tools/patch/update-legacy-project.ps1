[CmdletBinding()]
param(
    [string]$TargetPath = '.',
    [string]$RepoUrl,
    [string]$Version = '0.3.1',
    [string]$Title = 'Atualizacao para UBU Suite 0.3.1',
    [string]$Description = 'Adiciona release governor, RepoUrl oficial do kit, ISO 3.1 e estrutura dev-only do versionador',
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$KitVersion = '0.3.1'
$KitOfficialRepoUrl = 'https://github.com/0xbfb/ubu-suite.git'

function Write-Step { param([string]$Message) Write-Host ("==> {0}" -f $Message) }

function Write-TextFile {
    param([string]$Path, [string]$Content)
    if ($DryRun) { Write-Host "[dry-run] escrever $Path"; return }
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $Content | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Add-BlockIfMissing {
    param([string]$Path, [string]$Marker, [string]$Block)
    if ($DryRun) { Write-Host "[dry-run] garantir bloco em $Path"; return }
    if (Test-Path -LiteralPath $Path) {
        $current = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        if ($current -match [regex]::Escape($Marker)) { return }
        ($current.TrimEnd() + "`n`n" + $Block.Trim() + "`n") | Set-Content -LiteralPath $Path -Encoding UTF8
    } else {
        ($Block.Trim() + "`n") | Set-Content -LiteralPath $Path -Encoding UTF8
    }
}

function Set-GitAttributes {
    param([string]$Path)
    $content = @'
* text=auto

*.ps1 text eol=crlf
*.bat text eol=crlf
*.cmd text eol=crlf

*.md text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.html text eol=lf
*.css text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.php text eol=lf
*.py text eol=lf
'@
    if ($DryRun) { Write-Host "[dry-run] normalizar $Path"; return }
    $content | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-ReleaseConfig {
    param([string]$Path)
    $config = [ordered]@{
        schemaVersion = '2.0'
        kit = [ordered]@{
            name = 'UBU Suite'
            version = $KitVersion
            officialRepoUrl = $KitOfficialRepoUrl
        }
        project = [ordered]@{
            repoUrl = $RepoUrl
            sourceBranch = 'dev'
            releaseBranchPrefix = 'release/'
            nightlyBranch = 'nightly'
            stableBranch = 'stable'
        }
        lastRelease = [ordered]@{
            version = ''
            kind = ''
            title = ''
            description = ''
            tag = ''
            createdAt = ''
        }
        policies = [ordered]@{
            versionadorDevOnly = $true
            stackAwareIso = $true
            forbidUnusedInstallers = $true
            forbidWorkingTreeEncodingBom = $true
        }
    }
    if ($DryRun) { Write-Host "[dry-run] escrever $Path"; return }
    ($config | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $Path -Encoding UTF8
}

$target = (Resolve-Path -LiteralPath $TargetPath).Path
Write-Step "Atualizando projeto legado em $target"

$gitignoreBlock = @'
# UBU Suite 0.3.1 — arquivos locais e temporários
.env
.env.local
.env.*.local

# Versionador real permanece dev-only/local.
dev/versionador/*
!dev/versionador/.gitignore
!dev/versionador/README.md

*.tmp
*.temp
*.log
*.cache
.DS_Store
Thumbs.db
'@

$envExample = @'
UBU_PROJECT_REPO_URL=https://github.com/owner/project.git
UBU_KIT_REPO_URL=https://github.com/0xbfb/ubu-suite.git

UBU_SOURCE_BRANCH=dev
UBU_RELEASE_BRANCH_PREFIX=release/
UBU_NIGHTLY_BRANCH=nightly
UBU_STABLE_BRANCH=stable

UBU_RELEASE_TITLE=
UBU_RELEASE_DESCRIPTION=
UBU_PATCH_TITLE=
UBU_PATCH_DESCRIPTION=
'@

$versionadorReadme = @'
# Versionador dev-only

Esta pasta reserva a estrutura local do versionador.

O programa real do versionador, builds, binários, runtimes, caches, zips, scripts gerados e arquivos temporários não devem subir em patches, releases, nightly ou stable.

Somente estes arquivos podem ser versionados:

- `dev/versionador/.gitignore`
- `dev/versionador/README.md`
'@

$versionadorGitignore = @'
*
!.gitignore
!README.md
'@

Write-ReleaseConfig -Path (Join-Path $target 'release.config.json')
Write-TextFile -Path (Join-Path $target '.env.example') -Content $envExample
Set-GitAttributes -Path (Join-Path $target '.gitattributes')
Add-BlockIfMissing -Path (Join-Path $target '.gitignore') -Marker 'UBU Suite 0.3.1' -Block $gitignoreBlock
Write-TextFile -Path (Join-Path $target 'dev/versionador/.gitignore') -Content $versionadorGitignore
Write-TextFile -Path (Join-Path $target 'dev/versionador/README.md') -Content $versionadorReadme

# Copia os arquivos do patch/kit quando eles estiverem disponíveis ao lado deste script.
$sourceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$filesToCopy = @(
    'release.ps1',
    'patch-legacy.ps1',
    'tools/release/git-release.ps1',
    'tools/release/README.md',
    'tools/patch/update-legacy-project.ps1',
    'docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md',
    'docs/POLITICA_VERSIONADOR_DEV_ONLY.md',
    'docs/POLITICA_ISO_STACK_AWARE.md',
    'docs/UBU-ISO-3.1-RELEASE-GOVERNOR.md'
)

foreach ($relative in $filesToCopy) {
    $source = Join-Path $sourceRoot $relative
    $dest = Join-Path $target $relative
    if (Test-Path -LiteralPath $source) {
        if ($DryRun) { Write-Host "[dry-run] copiar $relative" }
        else {
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item -LiteralPath $source -Destination $dest -Force
        }
    }
}

Write-Step 'Patch legado UBU Suite 0.3.1 concluido'
Write-Host 'Revise git status, git diff --check, dev/versionador e .gitattributes antes do commit.'

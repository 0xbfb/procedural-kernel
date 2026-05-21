[CmdletBinding()]
param(
    [string]$EnvPath = ".env",
    [string]$ConfigPath,
    [string]$Version,
    [string]$RepoUrl,
    [string]$OfficialKitRepoUrl,
    [string]$SourceBranch,
    [string]$ReleaseBranch,
    [string]$ReleaseBranchPrefix,
    [string]$NightlyBranch,
    [string]$StableBranch,
    [string]$TagName,
    [string]$TagPrefix,
    [ValidateSet("release", "patch")]
    [string]$ReleaseKind,
    [string]$Title,
    [string]$Description,
    [string]$ReleaseTitle,
    [string]$ReleaseDescription,
    [string]$PatchTitle,
    [string]$PatchDescription,
    [string]$CommitMessage,
    [string]$TagMessage,
    [switch]$NoPush,
    [switch]$DryRun,
    [switch]$Force,
    [switch]$SkipConfigUpdate
)

$ErrorActionPreference = "Stop"
$ScriptVersion = "0.3.1"
$DefaultOfficialKitRepoUrl = "https://github.com/0xbfb/ubu-suite.git"

function Fail([string]$Message) {
    throw "[release:$ScriptVersion] $Message"
}

function Is-Blank([AllowNull()][string]$Value) {
    return [string]::IsNullOrWhiteSpace($Value)
}

function Read-DotEnv([string]$Path) {
    $values = @{}
    if (Is-Blank $Path) { return $values }
    if (-not (Test-Path -LiteralPath $Path)) { return $values }

    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        if ($trimmed.StartsWith('#')) { continue }
        $idx = $trimmed.IndexOf('=')
        if ($idx -lt 1) { continue }
        $key = $trimmed.Substring(0, $idx).Trim()
        $value = $trimmed.Substring($idx + 1).Trim()
        if ($value.Length -ge 2) {
            $first = $value.Substring(0, 1)
            $last = $value.Substring($value.Length - 1, 1)
            if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }
        if (-not [string]::IsNullOrWhiteSpace($key)) { $values[$key] = $value }
    }
    return $values
}

function Pick-Value([AllowNull()][string]$FlagValue, [hashtable]$EnvValues, [string[]]$EnvNames, [AllowNull()][string]$DefaultValue) {
    if (-not (Is-Blank $FlagValue)) { return $FlagValue }
    foreach ($name in $EnvNames) {
        if ($EnvValues.ContainsKey($name) -and -not (Is-Blank $EnvValues[$name])) { return [string]$EnvValues[$name] }
    }
    return $DefaultValue
}

function Format-GitArgs([string[]]$GitArgs) {
    $parts = foreach ($item in $GitArgs) {
        if ($item -match '\s') { '"' + ($item -replace '"', '\"') + '"' } else { $item }
    }
    return ($parts -join ' ')
}

function Invoke-Git {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)

    if ($null -eq $GitArgs -or $GitArgs.Count -eq 0) { Fail "Comando Git sem argumentos. Isso indica bug interno no script." }
    if ($GitArgs.Count -eq 1 -and $GitArgs[0] -match '\s') { Fail "Comando Git recebido como string unica: '$($GitArgs[0])'. Use argumentos separados, ex.: Invoke-Git remote get-url origin." }
    $pretty = "git " + (Format-GitArgs $GitArgs)
    if ($DryRun) { Write-Host "[dry-run] $pretty"; return }
    Write-Host "+ $pretty"
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { Fail "Comando Git falhou: $pretty" }
}

function Test-Git {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)

    if ($null -eq $GitArgs -or $GitArgs.Count -eq 0) { Fail "Teste Git sem argumentos. Isso indica bug interno no script." }
    if ($GitArgs.Count -eq 1 -and $GitArgs[0] -match '\s') { Fail "Teste Git recebido como string unica: '$($GitArgs[0])'. Use argumentos separados." }
    if ($DryRun) { return $false }

    $previousErrorActionPreference = $ErrorActionPreference
    $hadNativePreference = Test-Path Variable:PSNativeCommandUseErrorActionPreference
    if ($hadNativePreference) { $previousNativePreference = $PSNativeCommandUseErrorActionPreference }
    try {
        $ErrorActionPreference = 'Continue'
        if ($hadNativePreference) { Set-Variable -Name PSNativeCommandUseErrorActionPreference -Value $false -Scope Script }
        & git @GitArgs *> $null
        return ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($hadNativePreference) { Set-Variable -Name PSNativeCommandUseErrorActionPreference -Value $previousNativePreference -Scope Script }
    }
}

function Sync-RemoteState {
    if ($NoPush) { Write-Host "==> Sync remoto ignorado por -NoPush"; return }
    if ($DryRun) { Write-Host "[dry-run] git fetch origin --prune --tags"; return }
    Write-Host "==> Sincronizando refs remotas antes de usar --force-with-lease"
    if (Test-Git ls-remote --exit-code origin) {
        Invoke-Git fetch origin --prune --tags
    } else {
        Write-Host "==> Remote origin acessivel sem refs ou ainda nao inicializado; seguindo sem fetch bloqueante."
    }
}

function Push-Branch([string]$BranchName) {
    if (Is-Blank $BranchName) { Fail "Nome de branch vazio para push." }
    if ($Force) { Invoke-Git push -u origin --force-with-lease $BranchName } else { Invoke-Git push -u origin $BranchName }
}

function Ensure-RootGitIgnore {
    $path = ".gitignore"
    if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType File -Path $path -Force | Out-Null }
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $changed = $false
    if ($content -notmatch '(?m)^\.env$') { $content = $content.TrimEnd() + "`r`n.env`r`n"; $changed = $true }
    if ($content -notmatch '(?m)^dev/versionador/\*$') {
        $block = @"

# UBU dev-only versionador
# O programa real do versionador nunca deve subir em patches/releases.
dev/versionador/*
!dev/versionador/.gitignore
!dev/versionador/README.md
"@
        $content = $content.TrimEnd() + $block + "`r`n"
        $changed = $true
    }
    if ($changed -and -not $DryRun) { Set-Content -LiteralPath $path -Value $content -Encoding UTF8 }
}

function Ensure-GitAttributes {
    $path = ".gitattributes"
    $safeLines = @(
        "* text=auto",
        "*.md text eol=lf",
        "*.json text eol=lf",
        "*.html text eol=lf",
        "*.ps1 text eol=crlf",
        "*.bat text eol=crlf"
    )
    $safeBlock = ($safeLines -join "`r`n") + "`r`n"

    if (-not (Test-Path -LiteralPath $path)) {
        if ($DryRun) { Write-Host "[dry-run] criar $path" } else { Set-Content -LiteralPath $path -Value $safeBlock -Encoding UTF8 }
        return
    }

    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $lines = @()
    foreach ($line in ($content -split "`r?`n")) {
        $trim = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trim)) { continue }
        if ($trim -match '^\*\.ps1\s+.*working-tree-encoding') { continue }
        if ($trim -eq '*.ps1 text eol=crlf') { continue }
        $lines += $line
    }
    foreach ($safe in $safeLines) {
        if ($lines -notcontains $safe) { $lines += $safe }
    }
    $newContent = ($lines -join "`r`n") + "`r`n"
    if ($newContent -ne $content) {
        if ($DryRun) { Write-Host "[dry-run] atualizar $path removendo working-tree-encoding de ps1" } else { Set-Content -LiteralPath $path -Value $newContent -Encoding UTF8 }
    }
}

function Ensure-VersionadorGuard {
    $dir = "dev/versionador"
    if (-not (Test-Path -LiteralPath $dir) -and -not $DryRun) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $guardPath = Join-Path $dir ".gitignore"
    $readmePath = Join-Path $dir "README.md"
    $guard = @"
*
!.gitignore
!README.md
"@
    $readme = @"
# Versionador dev-only

Esta pasta reserva a estrutura local do versionador, mas o programa real do versionador nao deve ser distribuido em patches nem releases.

Somente estes arquivos devem ser versionados aqui:

- `.gitignore`
- `README.md`

Binarios, scripts gerados, zips, builds, caches e runtimes devem permanecer locais.
"@
    if (-not $DryRun) {
        Set-Content -LiteralPath $guardPath -Value $guard -Encoding UTF8
        Set-Content -LiteralPath $readmePath -Value $readme -Encoding UTF8
    } else {
        Write-Host "[dry-run] garantir $guardPath e $readmePath"
    }
}

function Assert-VersionadorTrackedFiles {
    if ($DryRun) { return }
    $allowed = @("dev/versionador/.gitignore", "dev/versionador/README.md")
    $tracked = & git ls-files dev/versionador
    if ($LASTEXITCODE -ne 0) { Fail "Nao foi possivel validar arquivos versionados em dev/versionador." }
    $invalid = @()
    foreach ($item in $tracked) { if ($allowed -notcontains $item) { $invalid += $item } }
    if ($invalid.Count -gt 0) {
        Write-Host "Arquivos indevidos do versionador estao versionados:" -ForegroundColor Red
        $invalid | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
        Fail "Remova estes arquivos do indice antes de continuar. O versionador real e dev-only."
    }
}

function Write-ReleaseConfig {
    if ($SkipConfigUpdate) { Write-Host "==> Atualizacao de config geral ignorada por -SkipConfigUpdate"; return }
    $payload = [ordered]@{
        schemaVersion = "2.0"
        updatedAt = (Get-Date).ToString("o")
        version = $ResolvedVersion
        kind = $ResolvedKind
        title = $ResolvedTitle
        description = $ResolvedDescription
        tag = $ResolvedTagName
        project = [ordered]@{
            repoUrl = $ResolvedRepoUrl
            remoteName = "origin"
        }
        kit = [ordered]@{
            officialRepoUrl = $ResolvedOfficialKitRepoUrl
            orchestrationSuiteVersion = $ScriptVersion
            iso = "UBU-ISO-3.1"
        }
        branches = [ordered]@{
            source = $ResolvedSourceBranch
            release = $ResolvedReleaseBranch
            nightly = $ResolvedNightlyBranch
            stable = $ResolvedStableBranch
        }
        messages = [ordered]@{
            commit = $ResolvedCommitMessage
            tag = $ResolvedTagMessage
        }
        script = [ordered]@{
            name = "tools/release/git-release.ps1"
            version = $ScriptVersion
            maintainedByIso = "UBU-ISO-3.1"
        }
        execution = [ordered]@{
            push = (-not [bool]$NoPush)
            force = [bool]$Force
            dryRun = [bool]$DryRun
        }
    }
    $json = $payload | ConvertTo-Json -Depth 10
    if ($DryRun) { Write-Host "[dry-run] atualizar $ResolvedConfigPath"; return }
    Set-Content -LiteralPath $ResolvedConfigPath -Value $json -Encoding UTF8
}

function Ensure-BranchFrom([string]$Name, [string]$StartPoint) {
    if (Is-Blank $Name) { Fail "Nome de branch vazio." }
    if (Is-Blank $StartPoint) { Fail "Start point vazio para branch $Name." }
    if ($Force) { Invoke-Git switch -C $Name $StartPoint; return }
    if (Test-Git show-ref --verify --quiet "refs/heads/$Name") { Fail "A branch '$Name' ja existe. Use -Force para reposiciona-la explicitamente." }
    Invoke-Git switch -c $Name $StartPoint
}

$envValues = Read-DotEnv $EnvPath

$ResolvedVersion = Pick-Value -FlagValue $Version -EnvValues $envValues -EnvNames @('UBU_RELEASE_VERSION', 'RELEASE_VERSION', 'VERSION') -DefaultValue $null
if (Is-Blank $ResolvedVersion) { Fail "Informe -Version ou configure UBU_RELEASE_VERSION no .env." }

$ResolvedKind = Pick-Value -FlagValue $ReleaseKind -EnvValues $envValues -EnvNames @('UBU_RELEASE_KIND', 'RELEASE_KIND') -DefaultValue 'release'
if ($ResolvedKind -notin @('release', 'patch')) { Fail "ReleaseKind invalido: $ResolvedKind. Use release ou patch." }

$ResolvedRepoUrl = Pick-Value -FlagValue $RepoUrl -EnvValues $envValues -EnvNames @('UBU_REPO_URL', 'REPO_URL', 'GIT_REMOTE_URL') -DefaultValue $null
if (Is-Blank $ResolvedRepoUrl) { Fail "Informe -RepoUrl ou configure UBU_REPO_URL no .env." }

$ResolvedOfficialKitRepoUrl = Pick-Value -FlagValue $OfficialKitRepoUrl -EnvValues $envValues -EnvNames @('UBU_OFFICIAL_KIT_REPO_URL', 'OFFICIAL_KIT_REPO_URL') -DefaultValue $DefaultOfficialKitRepoUrl
$ResolvedSourceBranch = Pick-Value -FlagValue $SourceBranch -EnvValues $envValues -EnvNames @('UBU_SOURCE_BRANCH', 'SOURCE_BRANCH') -DefaultValue 'dev'
$ResolvedReleaseBranchPrefix = Pick-Value -FlagValue $ReleaseBranchPrefix -EnvValues $envValues -EnvNames @('UBU_RELEASE_BRANCH_PREFIX', 'RELEASE_BRANCH_PREFIX') -DefaultValue 'release/'
$ResolvedNightlyBranch = Pick-Value -FlagValue $NightlyBranch -EnvValues $envValues -EnvNames @('UBU_NIGHTLY_BRANCH', 'NIGHTLY_BRANCH') -DefaultValue 'nightly'
$ResolvedStableBranch = Pick-Value -FlagValue $StableBranch -EnvValues $envValues -EnvNames @('UBU_STABLE_BRANCH', 'STABLE_BRANCH') -DefaultValue 'stable'
$ResolvedTagPrefix = Pick-Value -FlagValue $TagPrefix -EnvValues $envValues -EnvNames @('UBU_TAG_PREFIX', 'TAG_PREFIX') -DefaultValue 'v'
$ResolvedReleaseBranch = Pick-Value -FlagValue $ReleaseBranch -EnvValues $envValues -EnvNames @('UBU_RELEASE_BRANCH', 'RELEASE_BRANCH') -DefaultValue ($ResolvedReleaseBranchPrefix + $ResolvedVersion)
$ResolvedTagName = Pick-Value -FlagValue $TagName -EnvValues $envValues -EnvNames @('UBU_TAG_NAME', 'TAG_NAME') -DefaultValue ($ResolvedTagPrefix + $ResolvedVersion)
$ResolvedConfigPath = Pick-Value -FlagValue $ConfigPath -EnvValues $envValues -EnvNames @('UBU_RELEASE_CONFIG_PATH', 'RELEASE_CONFIG_PATH') -DefaultValue 'release.config.json'

if ($ResolvedKind -eq 'patch') {
    $fallbackPatchTitle = Pick-Value -FlagValue $PatchTitle -EnvValues $envValues -EnvNames @('UBU_PATCH_TITLE', 'PATCH_TITLE') -DefaultValue ("Patch " + $ResolvedVersion)
    $fallbackPatchDescription = Pick-Value -FlagValue $PatchDescription -EnvValues $envValues -EnvNames @('UBU_PATCH_DESCRIPTION', 'PATCH_DESCRIPTION') -DefaultValue ("Patch " + $ResolvedVersion)
    $ResolvedTitle = Pick-Value -FlagValue $Title -EnvValues $envValues -EnvNames @('UBU_TITLE', 'TITLE') -DefaultValue $fallbackPatchTitle
    $ResolvedDescription = Pick-Value -FlagValue $Description -EnvValues $envValues -EnvNames @('UBU_DESCRIPTION', 'DESCRIPTION') -DefaultValue $fallbackPatchDescription
} else {
    $fallbackReleaseTitle = Pick-Value -FlagValue $ReleaseTitle -EnvValues $envValues -EnvNames @('UBU_RELEASE_TITLE', 'RELEASE_TITLE') -DefaultValue ("Release " + $ResolvedVersion)
    $fallbackReleaseDescription = Pick-Value -FlagValue $ReleaseDescription -EnvValues $envValues -EnvNames @('UBU_RELEASE_DESCRIPTION', 'RELEASE_DESCRIPTION') -DefaultValue ("Release " + $ResolvedVersion)
    $ResolvedTitle = Pick-Value -FlagValue $Title -EnvValues $envValues -EnvNames @('UBU_TITLE', 'TITLE') -DefaultValue $fallbackReleaseTitle
    $ResolvedDescription = Pick-Value -FlagValue $Description -EnvValues $envValues -EnvNames @('UBU_DESCRIPTION', 'DESCRIPTION') -DefaultValue $fallbackReleaseDescription
}

$ResolvedCommitMessage = Pick-Value -FlagValue $CommitMessage -EnvValues $envValues -EnvNames @('UBU_COMMIT_MESSAGE', 'COMMIT_MESSAGE') -DefaultValue ("chore(" + $ResolvedKind + "): " + $ResolvedTitle + " " + $ResolvedVersion)
$ResolvedTagMessage = Pick-Value -FlagValue $TagMessage -EnvValues $envValues -EnvNames @('UBU_TAG_MESSAGE', 'TAG_MESSAGE') -DefaultValue ($ResolvedTitle + " " + $ResolvedVersion + " - " + $ResolvedDescription)

Write-Host "==> UBU git release orchestrator $ScriptVersion"
Write-Host "==> Plano de release"
Write-Host "Tipo:          $ResolvedKind"
Write-Host "Versao:        $ResolvedVersion"
Write-Host "Titulo:        $ResolvedTitle"
Write-Host "Descricao:     $ResolvedDescription"
Write-Host "Config geral:  $ResolvedConfigPath"
Write-Host "Origem:        $ResolvedSourceBranch"
Write-Host "Release:       $ResolvedReleaseBranch"
Write-Host "Nightly:       $ResolvedNightlyBranch"
Write-Host "Stable:        $ResolvedStableBranch"
Write-Host "Tag:           $ResolvedTagName"
Write-Host "Remote:        $ResolvedRepoUrl"
Write-Host "Kit oficial:   $ResolvedOfficialKitRepoUrl"
Write-Host "Push:          $(-not [bool]$NoPush)"
Write-Host "Force:         $([bool]$Force)"
Write-Host "Dry-run:       $([bool]$DryRun)"

Write-Host "==> Validando Git"
if (-not $DryRun) {
    & git --version
    if ($LASTEXITCODE -ne 0) { Fail "Git nao encontrado ou indisponivel no PATH." }
} else { Write-Host "[dry-run] git --version" }

if (Test-Git rev-parse --is-inside-work-tree) { Write-Host "==> Repositorio Git detectado" } else { Write-Host "==> Repositorio Git nao detectado. Inicializando em $ResolvedSourceBranch"; Invoke-Git init -b $ResolvedSourceBranch }

if (Test-Git remote get-url origin) { Invoke-Git remote set-url origin $ResolvedRepoUrl } else { Invoke-Git remote add origin $ResolvedRepoUrl }

Sync-RemoteState

if (Test-Git show-ref --verify --quiet "refs/heads/$ResolvedSourceBranch") { Invoke-Git switch $ResolvedSourceBranch } else { Invoke-Git switch -c $ResolvedSourceBranch }

Ensure-RootGitIgnore
Ensure-GitAttributes
Ensure-VersionadorGuard
Write-ReleaseConfig

Write-Host "==> Preparando commit em $ResolvedSourceBranch"
Invoke-Git add .
Assert-VersionadorTrackedFiles

$hasHead = Test-Git rev-parse --verify HEAD
$hasStagedChanges = -not (Test-Git diff --cached --quiet)

if ($hasStagedChanges) { Invoke-Git commit -m $ResolvedCommitMessage } elseif (-not $hasHead) { Fail "Repositorio sem HEAD e sem alteracoes staged. Nao ha nada para commitar." } else { Write-Host "==> Sem alteracoes staged para commit. Continuando com HEAD atual." }

Write-Host "==> Orquestrando arvore: $ResolvedReleaseBranch -> $ResolvedNightlyBranch -> $ResolvedStableBranch"
Ensure-BranchFrom -Name $ResolvedReleaseBranch -StartPoint $ResolvedSourceBranch
Ensure-BranchFrom -Name $ResolvedNightlyBranch -StartPoint $ResolvedReleaseBranch
Ensure-BranchFrom -Name $ResolvedStableBranch -StartPoint $ResolvedNightlyBranch

Write-Host "==> Criando tag $ResolvedTagName em $ResolvedStableBranch"
if (Test-Git rev-parse -q --verify "refs/tags/$ResolvedTagName") {
    if (-not $Force) { Fail "A tag '$ResolvedTagName' ja existe. Use -Force para recria-la." }
    Invoke-Git tag -d $ResolvedTagName
}
Invoke-Git tag -a $ResolvedTagName -m $ResolvedTagMessage

if ($NoPush) { Write-Host "==> Push ignorado por -NoPush" } else {
    Write-Host "==> Enviando branches e tag"
    Sync-RemoteState
    Push-Branch $ResolvedSourceBranch
    Push-Branch $ResolvedReleaseBranch
    Push-Branch $ResolvedNightlyBranch
    Push-Branch $ResolvedStableBranch
    if ($Force) { Invoke-Git push origin --force $ResolvedTagName } else { Invoke-Git push origin $ResolvedTagName }
}

Write-Host "==> Validacao final"
if (-not $DryRun) {
    Write-Host "Arquivos versionados em dev/versionador:"
    & git ls-files dev/versionador
}
Write-Host ""
Write-Host "Release $ResolvedVersion finalizada."
Write-Host "Ordem aplicada: $ResolvedReleaseBranch -> $ResolvedNightlyBranch -> $ResolvedStableBranch"
Write-Host "Tag: $ResolvedTagName"
Write-Host "Kit oficial: $ResolvedOfficialKitRepoUrl"

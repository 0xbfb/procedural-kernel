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
    [switch]$SkipConfigUpdate,
    [switch]$SkipKitUpdate
)

$ErrorActionPreference = "Stop"
$ScriptVersion = "0.3.5"
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

function Read-JsonConfig([string]$Path) {
    if (Is-Blank $Path) { return $null }
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
        return ($raw | ConvertFrom-Json)
    } catch {
        Fail "Nao foi possivel ler $Path como JSON valido: $($_.Exception.Message)"
    }
}

function Get-ConfigValue([AllowNull()]$Object, [string[]]$Path) {
    $cursor = $Object
    foreach ($segment in $Path) {
        if ($null -eq $cursor) { return $null }
        $prop = $cursor.PSObject.Properties[$segment]
        if ($null -eq $prop) { return $null }
        $cursor = $prop.Value
    }
    if ($null -eq $cursor) { return $null }
    return [string]$cursor
}

function Get-ConfigBool([AllowNull()]$Object, [string[]]$Path, [AllowNull()][bool]$DefaultValue) {
    $cursor = $Object
    foreach ($segment in $Path) {
        if ($null -eq $cursor) { return $DefaultValue }
        $prop = $cursor.PSObject.Properties[$segment]
        if ($null -eq $prop) { return $DefaultValue }
        $cursor = $prop.Value
    }
    if ($null -eq $cursor) { return $DefaultValue }
    if ($cursor -is [bool]) { return [bool]$cursor }
    $text = ([string]$cursor).Trim().ToLowerInvariant()
    if ($text -in @('1', 'true', 'yes', 'sim', 'on')) { return $true }
    if ($text -in @('0', 'false', 'no', 'nao', 'não', 'off')) { return $false }
    return $DefaultValue
}

function Pick-Value(
    [AllowNull()][string]$FlagValue,
    [hashtable]$EnvValues,
    [string[]]$EnvNames,
    [AllowNull()][string]$ConfigValue,
    [AllowNull()][string]$DefaultValue
) {
    if (-not (Is-Blank $FlagValue)) { return $FlagValue }
    foreach ($name in $EnvNames) {
        if ($EnvValues.ContainsKey($name) -and -not (Is-Blank $EnvValues[$name])) { return [string]$EnvValues[$name] }
    }
    if (-not (Is-Blank $ConfigValue)) { return $ConfigValue }
    return $DefaultValue
}

function Pick-BoolFromEnvOrConfig([hashtable]$EnvValues, [string[]]$EnvNames, [AllowNull()][bool]$ConfigValue, [bool]$DefaultValue) {
    foreach ($name in $EnvNames) {
        if ($EnvValues.ContainsKey($name) -and -not (Is-Blank $EnvValues[$name])) {
            $text = ([string]$EnvValues[$name]).Trim().ToLowerInvariant()
            if ($text -in @('1', 'true', 'yes', 'sim', 'on')) { return $true }
            if ($text -in @('0', 'false', 'no', 'nao', 'não', 'off')) { return $false }
            Fail ("Valor booleano invalido em {0}: {1}" -f $name, $EnvValues[$name])
        }
    }
    if ($null -ne $ConfigValue) { return [bool]$ConfigValue }
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
    if ($ResolvedDryRun) { Write-Host "[dry-run] $pretty"; return }
    Write-Host "+ $pretty"
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { Fail "Comando Git falhou: $pretty" }
}

function Test-Git {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)

    if ($null -eq $GitArgs -or $GitArgs.Count -eq 0) { Fail "Teste Git sem argumentos. Isso indica bug interno no script." }
    if ($GitArgs.Count -eq 1 -and $GitArgs[0] -match '\s') { Fail "Teste Git recebido como string unica: '$($GitArgs[0])'. Use argumentos separados." }
    if ($ResolvedDryRun) { return $false }

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
    if ($ResolvedNoPush) { Write-Host "==> Sync remoto ignorado por configuracao de no-push"; return }
    if (-not $ResolvedSyncRemoteBeforePush) { Write-Host "==> Sync remoto ignorado por releaseDefaults.syncRemoteBeforePush=false"; return }
    if ($ResolvedDryRun) { Write-Host "[dry-run] git fetch origin --prune --tags"; return }
    Write-Host "==> Sincronizando refs remotas antes de usar --force-with-lease"
    if (Test-Git ls-remote --exit-code origin) {
        Invoke-Git fetch origin --prune --tags
    } else {
        Write-Host "==> Remote origin acessivel sem refs ou ainda nao inicializado; seguindo sem fetch bloqueante."
    }
}

function Push-Branch([string]$BranchName) {
    if (Is-Blank $BranchName) { Fail "Nome de branch vazio para push." }
    if ($ResolvedForce) { Invoke-Git push -u origin --force-with-lease $BranchName } else { Invoke-Git push -u origin $BranchName }
}

function Ensure-RootGitIgnore {
    $path = ".gitignore"
    if (-not (Test-Path -LiteralPath $path)) { if (-not $ResolvedDryRun) { New-Item -ItemType File -Path $path -Force | Out-Null } }
    $content = ""
    if (Test-Path -LiteralPath $path) { $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8 }
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
    if ($changed) {
        if ($ResolvedDryRun) { Write-Host "[dry-run] atualizar $path com protecoes UBU" } else { Set-Content -LiteralPath $path -Value $content -Encoding UTF8 }
    }
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
        if ($ResolvedDryRun) { Write-Host "[dry-run] criar $path" } else { Set-Content -LiteralPath $path -Value $safeBlock -Encoding UTF8 }
        return
    }

    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $lines = @()
    foreach ($line in ($content -split "`r?`n")) {
        $trim = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trim)) { continue }
        if ($trim -match 'working-tree-encoding') { continue }
        if ($trim -eq '*.ps1 text eol=crlf') { continue }
        $lines += $line
    }
    foreach ($safe in $safeLines) {
        if ($lines -notcontains $safe) { $lines += $safe }
    }
    $newContent = ($lines -join "`r`n") + "`r`n"
    if ($newContent -ne $content) {
        if ($ResolvedDryRun) { Write-Host "[dry-run] atualizar $path removendo working-tree-encoding" } else { Set-Content -LiteralPath $path -Value $newContent -Encoding UTF8 }
    }
}

function Ensure-VersionadorGuard {
    $dir = "dev/versionador"
    if (-not (Test-Path -LiteralPath $dir) -and -not $ResolvedDryRun) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
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
    if (-not $ResolvedDryRun) {
        Set-Content -LiteralPath $guardPath -Value $guard -Encoding UTF8
        Set-Content -LiteralPath $readmePath -Value $readme -Encoding UTF8
    } else {
        Write-Host "[dry-run] garantir $guardPath e $readmePath"
    }
}

function Assert-VersionadorTrackedFiles {
    if ($ResolvedDryRun) { return }
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

function To-StringArray([AllowNull()]$Value, [string[]]$Fallback) {
    if ($null -eq $Value) { return $Fallback }
    $items = @()
    foreach ($item in $Value) {
        if (-not [string]::IsNullOrWhiteSpace([string]$item)) { $items += [string]$item }
    }
    if ($items.Count -eq 0) { return $Fallback }
    return $items
}

function Get-EntryValue([AllowNull()][object]$Object, [string]$Name) {
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Collections.IDictionary] -and $Object.Contains($Name)) { return $Object[$Name] }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -ne $prop) { return $prop.Value }
    return $null
}

function Add-HistoryEntry([System.Collections.ArrayList]$History, [object]$Entry) {
    $entryVersion = Get-EntryValue $Entry 'version'
    $entryTag = Get-EntryValue $Entry 'tag'
    foreach ($existing in $History) {
        if ((Get-EntryValue $existing 'version') -eq $entryVersion -and (Get-EntryValue $existing 'tag') -eq $entryTag) { return }
    }
    [void]$History.Add($Entry)
}

function Write-ReleaseConfig {
    if ($SkipConfigUpdate) { Write-Host "==> Atualizacao de config geral ignorada por -SkipConfigUpdate"; return }

    $entry = [ordered]@{
        version = $ResolvedVersion
        kind = $ResolvedKind
        title = $ResolvedTitle
        description = $ResolvedDescription
        tag = $ResolvedTagName
        targetReleaseBranch = $ResolvedReleaseBranch
        createdAt = (Get-Date).ToString("o")
    }

    $managedFallback = @(
        "release.ps1",
        "release.bat",
        "patch-legacy.ps1",
        "tools/release/git-release.ps1",
        "tools/patch/update-legacy-project.ps1",
        "tools/governor/update-governor.ps1",
        "tools/release/README.md",
        ".gitattributes",
        ".env.example",
        "docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md",
        "docs/POLITICA_VERSIONADOR_DEV_ONLY.md",
        "docs/POLITICA_ISO_STACK_AWARE.md",
        "docs/UBU_ISO_3_1_RELEASE_GOVERNOR.md",
        "docs/UBU-ISO-3.1-RELEASE-CONFIG-FIRST.md",
        "docs/UBU-GOVERNOR-AUTO-UPDATE.md"
    )
    $devOnlyFallback = @("dev/versionador/.gitignore", "dev/versionador/README.md")

    $managed = To-StringArray -Value $ConfigRoot.governorFiles.managed -Fallback $managedFallback
    $devOnly = To-StringArray -Value $ConfigRoot.governorFiles.devOnly -Fallback $devOnlyFallback

    $history = [System.Collections.ArrayList]::new()
    if ($null -ne $ConfigRoot.releaseHistory) {
        foreach ($item in $ConfigRoot.releaseHistory) { [void]$history.Add($item) }
    }
    Add-HistoryEntry -History $history -Entry $entry

    $projectName = Get-ConfigValue $ConfigRoot @('project','name')
    if (Is-Blank $projectName) { $projectName = Split-Path -Leaf (Get-Location).Path }

    $payload = [ordered]@{
        schemaVersion = "3.0"
        updatedAt = (Get-Date).ToString("o")
        kit = [ordered]@{
            name = "UBU Suite"
            version = $ScriptVersion
            officialRepoUrl = $ResolvedOfficialKitRepoUrl
            officialStableBranch = Pick-Value -FlagValue $null -EnvValues $envValues -EnvNames @('UBU_KIT_STABLE_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','officialStableBranch')) -DefaultValue 'stable'
            officialReleaseBranchPrefix = Pick-Value -FlagValue $null -EnvValues $envValues -EnvNames @('UBU_KIT_RELEASE_BRANCH_PREFIX') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','officialReleaseBranchPrefix')) -DefaultValue 'release/'
            autoUpdateGovernor = Get-ConfigBool $ConfigRoot @('kit','autoUpdateGovernor') $true
            autoUpdatePolicy = Pick-Value -FlagValue $null -EnvValues $envValues -EnvNames @('UBU_AUTO_UPDATE_POLICY') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','autoUpdatePolicy')) -DefaultValue 'compatible_only'
            iso = "UBU-ISO-3.1"
        }
        project = [ordered]@{
            name = $projectName
            repoUrl = $ResolvedRepoUrl
            remoteName = "origin"
            sourceBranch = $ResolvedSourceBranch
            releaseBranchPrefix = $ResolvedReleaseBranchPrefix
            nightlyBranch = $ResolvedNightlyBranch
            stableBranch = $ResolvedStableBranch
        }
        currentRelease = [ordered]@{
            version = $ResolvedVersion
            kind = $ResolvedKind
            title = $ResolvedTitle
            description = $ResolvedDescription
            tag = $ResolvedTagName
            baseBranch = $ResolvedSourceBranch
            targetReleaseBranch = $ResolvedReleaseBranch
            createdAt = $entry.createdAt
        }
        releaseDefaults = [ordered]@{
            push = (-not [bool]$ResolvedNoPush)
            forceWithLease = [bool]$ResolvedForce
            dryRun = [bool]$ResolvedDryRun
            requireCleanWorkingTree = Get-ConfigBool $ConfigRoot @('releaseDefaults','requireCleanWorkingTree') $false
            updateConfigBeforeCommit = $true
            syncRemoteBeforePush = [bool]$ResolvedSyncRemoteBeforePush
            checkKitUpdatesBeforeRelease = Get-ConfigBool $ConfigRoot @('releaseDefaults','checkKitUpdatesBeforeRelease') $true
        }
        governorFiles = [ordered]@{
            managed = $managed
            devOnly = $devOnly
        }
        commands = [ordered]@{
            publishPowerShell = ".\\release.ps1"
            publishBatch = ".\\release.bat"
            dryRunPowerShell = ".\\release.ps1 -DryRun"
            dryRunBatch = ".\\release.bat -DryRun"
            emergencySkipKitUpdate = ".\\release.ps1 -SkipKitUpdate"
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
            releaseBatRequired = $true
            releaseBatDelegatesToReleasePs1 = $true
            releaseConfigIsPrimarySource = $true
            flagsAreOnlyOverrides = $true
        }
        lastRelease = $entry
        releaseHistory = $history.ToArray()
        implementationStage = [ordered]@{
            release = "0.3.5"
            prompt = 5
            name = "Auditoria, estabilizacao e release final"
            behaviorChange = $true
            notes = "Release 0.3.5: git-release.ps1 evita interpolação inválida do tipo `$name:` e mantém config-first."
        }
    }

    $json = $payload | ConvertTo-Json -Depth 20
    if ($ResolvedDryRun) { Write-Host "[dry-run] atualizar $ResolvedConfigPath com currentRelease/lastRelease"; return }
    Set-Content -LiteralPath $ResolvedConfigPath -Value $json -Encoding UTF8
}

function Ensure-BranchFrom([string]$Name, [string]$StartPoint) {
    if (Is-Blank $Name) { Fail "Nome de branch vazio." }
    if (Is-Blank $StartPoint) { Fail "Start point vazio para branch $Name." }
    if ($ResolvedForce) { Invoke-Git switch -C $Name $StartPoint; return }
    if (Test-Git show-ref --verify --quiet "refs/heads/$Name") { Fail "A branch '$Name' ja existe. Configure releaseDefaults.forceWithLease=true ou use -Force para reposiciona-la explicitamente." }
    Invoke-Git switch -c $Name $StartPoint
}

$envValues = Read-DotEnv $EnvPath
$ResolvedConfigPath = Pick-Value -FlagValue $ConfigPath -EnvValues $envValues -EnvNames @('UBU_RELEASE_CONFIG_PATH', 'RELEASE_CONFIG_PATH') -ConfigValue $null -DefaultValue 'release.config.json'
$ConfigRoot = Read-JsonConfig $ResolvedConfigPath

$ResolvedVersion = Pick-Value -FlagValue $Version -EnvValues $envValues -EnvNames @('UBU_RELEASE_VERSION', 'RELEASE_VERSION', 'VERSION') -ConfigValue (Get-ConfigValue $ConfigRoot @('currentRelease','version')) -DefaultValue $null
if (Is-Blank $ResolvedVersion) { Fail "Versao nao informada. Defina currentRelease.version em $ResolvedConfigPath ou use -Version." }

$ResolvedKind = Pick-Value -FlagValue $ReleaseKind -EnvValues $envValues -EnvNames @('UBU_RELEASE_KIND', 'RELEASE_KIND') -ConfigValue (Get-ConfigValue $ConfigRoot @('currentRelease','kind')) -DefaultValue 'release'
if ($ResolvedKind -notin @('release', 'patch')) { Fail "ReleaseKind invalido: $ResolvedKind. Use release ou patch." }

$ResolvedRepoUrl = Pick-Value -FlagValue $RepoUrl -EnvValues $envValues -EnvNames @('UBU_PROJECT_REPO_URL', 'UBU_REPO_URL', 'REPO_URL', 'GIT_REMOTE_URL') -ConfigValue (Get-ConfigValue $ConfigRoot @('project','repoUrl')) -DefaultValue $null
if (Is-Blank $ResolvedRepoUrl) { Fail "RepoUrl nao informado. Defina project.repoUrl em $ResolvedConfigPath, UBU_PROJECT_REPO_URL no .env ou use -RepoUrl." }

$ResolvedOfficialKitRepoUrl = Pick-Value -FlagValue $OfficialKitRepoUrl -EnvValues $envValues -EnvNames @('UBU_KIT_REPO_URL', 'UBU_OFFICIAL_KIT_REPO_URL', 'OFFICIAL_KIT_REPO_URL') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','officialRepoUrl')) -DefaultValue $DefaultOfficialKitRepoUrl
$ResolvedSourceBranch = Pick-Value -FlagValue $SourceBranch -EnvValues $envValues -EnvNames @('UBU_SOURCE_BRANCH', 'SOURCE_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('project','sourceBranch')) -DefaultValue 'dev'
$ResolvedReleaseBranchPrefix = Pick-Value -FlagValue $ReleaseBranchPrefix -EnvValues $envValues -EnvNames @('UBU_RELEASE_BRANCH_PREFIX', 'RELEASE_BRANCH_PREFIX') -ConfigValue (Get-ConfigValue $ConfigRoot @('project','releaseBranchPrefix')) -DefaultValue 'release/'
$ResolvedNightlyBranch = Pick-Value -FlagValue $NightlyBranch -EnvValues $envValues -EnvNames @('UBU_NIGHTLY_BRANCH', 'NIGHTLY_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('project','nightlyBranch')) -DefaultValue 'nightly'
$ResolvedStableBranch = Pick-Value -FlagValue $StableBranch -EnvValues $envValues -EnvNames @('UBU_STABLE_BRANCH', 'STABLE_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('project','stableBranch')) -DefaultValue 'stable'
$ResolvedTagPrefix = Pick-Value -FlagValue $TagPrefix -EnvValues $envValues -EnvNames @('UBU_TAG_PREFIX', 'TAG_PREFIX') -ConfigValue $null -DefaultValue 'v'
$ResolvedReleaseBranch = Pick-Value -FlagValue $ReleaseBranch -EnvValues $envValues -EnvNames @('UBU_RELEASE_BRANCH', 'RELEASE_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('currentRelease','targetReleaseBranch')) -DefaultValue ($ResolvedReleaseBranchPrefix + $ResolvedVersion)
$ResolvedTagName = Pick-Value -FlagValue $TagName -EnvValues $envValues -EnvNames @('UBU_TAG_NAME', 'TAG_NAME') -ConfigValue (Get-ConfigValue $ConfigRoot @('currentRelease','tag')) -DefaultValue ($ResolvedTagPrefix + $ResolvedVersion)

$configTitle = Get-ConfigValue $ConfigRoot @('currentRelease','title')
$configDescription = Get-ConfigValue $ConfigRoot @('currentRelease','description')

if ($ResolvedKind -eq 'patch') {
    $fallbackPatchTitle = Pick-Value -FlagValue $PatchTitle -EnvValues $envValues -EnvNames @('UBU_PATCH_TITLE', 'PATCH_TITLE') -ConfigValue $configTitle -DefaultValue ("Patch " + $ResolvedVersion)
    $fallbackPatchDescription = Pick-Value -FlagValue $PatchDescription -EnvValues $envValues -EnvNames @('UBU_PATCH_DESCRIPTION', 'PATCH_DESCRIPTION') -ConfigValue $configDescription -DefaultValue ("Patch " + $ResolvedVersion)
    $ResolvedTitle = Pick-Value -FlagValue $Title -EnvValues $envValues -EnvNames @('UBU_TITLE', 'TITLE') -ConfigValue $configTitle -DefaultValue $fallbackPatchTitle
    $ResolvedDescription = Pick-Value -FlagValue $Description -EnvValues $envValues -EnvNames @('UBU_DESCRIPTION', 'DESCRIPTION') -ConfigValue $configDescription -DefaultValue $fallbackPatchDescription
} else {
    $fallbackReleaseTitle = Pick-Value -FlagValue $ReleaseTitle -EnvValues $envValues -EnvNames @('UBU_RELEASE_TITLE', 'RELEASE_TITLE') -ConfigValue $configTitle -DefaultValue ("Release " + $ResolvedVersion)
    $fallbackReleaseDescription = Pick-Value -FlagValue $ReleaseDescription -EnvValues $envValues -EnvNames @('UBU_RELEASE_DESCRIPTION', 'RELEASE_DESCRIPTION') -ConfigValue $configDescription -DefaultValue ("Release " + $ResolvedVersion)
    $ResolvedTitle = Pick-Value -FlagValue $Title -EnvValues $envValues -EnvNames @('UBU_TITLE', 'TITLE') -ConfigValue $configTitle -DefaultValue $fallbackReleaseTitle
    $ResolvedDescription = Pick-Value -FlagValue $Description -EnvValues $envValues -EnvNames @('UBU_DESCRIPTION', 'DESCRIPTION') -ConfigValue $configDescription -DefaultValue $fallbackReleaseDescription
}

if (Is-Blank $ResolvedTitle) { Fail "Titulo da release vazio. Preencha currentRelease.title em $ResolvedConfigPath ou informe -Title." }
if (Is-Blank $ResolvedDescription) { Fail "Descricao da release vazia. Preencha currentRelease.description em $ResolvedConfigPath ou informe -Description." }

$ResolvedCommitMessage = Pick-Value -FlagValue $CommitMessage -EnvValues $envValues -EnvNames @('UBU_COMMIT_MESSAGE', 'COMMIT_MESSAGE') -ConfigValue $null -DefaultValue ("chore(" + $ResolvedKind + "): " + $ResolvedTitle + " " + $ResolvedVersion)
$ResolvedTagMessage = Pick-Value -FlagValue $TagMessage -EnvValues $envValues -EnvNames @('UBU_TAG_MESSAGE', 'TAG_MESSAGE') -ConfigValue $null -DefaultValue ($ResolvedTitle + " " + $ResolvedVersion + " - " + $ResolvedDescription)

$ResolvedDryRun = if ($DryRun) { $true } else { Pick-BoolFromEnvOrConfig -EnvValues $envValues -EnvNames @('UBU_DRY_RUN', 'DRY_RUN') -ConfigValue (Get-ConfigBool $ConfigRoot @('releaseDefaults','dryRun') $false) -DefaultValue $false }
$ResolvedPush = Pick-BoolFromEnvOrConfig -EnvValues $envValues -EnvNames @('UBU_PUSH', 'PUSH') -ConfigValue (Get-ConfigBool $ConfigRoot @('releaseDefaults','push') $true) -DefaultValue $true
$ResolvedNoPush = if ($NoPush) { $true } else { -not $ResolvedPush }
$ResolvedForce = if ($Force) { $true } else { Pick-BoolFromEnvOrConfig -EnvValues $envValues -EnvNames @('UBU_FORCE', 'UBU_FORCE_WITH_LEASE', 'FORCE') -ConfigValue (Get-ConfigBool $ConfigRoot @('releaseDefaults','forceWithLease') $false) -DefaultValue $false }
$ResolvedSyncRemoteBeforePush = Pick-BoolFromEnvOrConfig -EnvValues $envValues -EnvNames @('UBU_SYNC_REMOTE_BEFORE_PUSH', 'SYNC_REMOTE_BEFORE_PUSH') -ConfigValue (Get-ConfigBool $ConfigRoot @('releaseDefaults','syncRemoteBeforePush') $true) -DefaultValue $true

Write-Host "==> UBU git release orchestrator $ScriptVersion"
Write-Host "==> Plano de release"
Write-Host "Fonte config:   $ResolvedConfigPath"
Write-Host "Tipo:          $ResolvedKind"
Write-Host "Versao:        $ResolvedVersion"
Write-Host "Titulo:        $ResolvedTitle"
Write-Host "Descricao:     $ResolvedDescription"
Write-Host "Origem:        $ResolvedSourceBranch"
Write-Host "Release:       $ResolvedReleaseBranch"
Write-Host "Nightly:       $ResolvedNightlyBranch"
Write-Host "Stable:        $ResolvedStableBranch"
Write-Host "Tag:           $ResolvedTagName"
Write-Host "Remote:        $ResolvedRepoUrl"
Write-Host "Kit oficial:   $ResolvedOfficialKitRepoUrl"
Write-Host "Push:          $(-not [bool]$ResolvedNoPush)"
Write-Host "Force:         $([bool]$ResolvedForce)"
Write-Host "Dry-run:       $([bool]$ResolvedDryRun)"
if ($SkipKitUpdate) { Write-Host "Kit update:     ignorado por -SkipKitUpdate" } else { Write-Host "Kit update:     verificado antes deste orquestrador pelo release.ps1" }

Write-Host "==> Validando Git"
if (-not $ResolvedDryRun) {
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
    if (-not $ResolvedForce) { Fail "A tag '$ResolvedTagName' ja existe. Configure releaseDefaults.forceWithLease=true ou use -Force para recria-la." }
    Invoke-Git tag -d $ResolvedTagName
}
Invoke-Git tag -a $ResolvedTagName -m $ResolvedTagMessage

if ($ResolvedNoPush) { Write-Host "==> Push ignorado por configuracao" } else {
    Write-Host "==> Enviando branches e tag"
    Sync-RemoteState
    Push-Branch $ResolvedSourceBranch
    Push-Branch $ResolvedReleaseBranch
    Push-Branch $ResolvedNightlyBranch
    Push-Branch $ResolvedStableBranch
    if ($ResolvedForce) { Invoke-Git push origin --force $ResolvedTagName } else { Invoke-Git push origin $ResolvedTagName }
}

Write-Host "==> Validacao final"
if (-not $ResolvedDryRun) {
    Write-Host "Arquivos versionados em dev/versionador:"
    & git ls-files dev/versionador
}
Write-Host ""
Write-Host "Release $ResolvedVersion finalizada."
Write-Host "Ordem aplicada: $ResolvedReleaseBranch -> $ResolvedNightlyBranch -> $ResolvedStableBranch"
Write-Host "Tag: $ResolvedTagName"
Write-Host "Kit oficial: $ResolvedOfficialKitRepoUrl"

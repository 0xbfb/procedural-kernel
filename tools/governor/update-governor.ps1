[CmdletBinding()]
param(
    [string]$EnvPath = ".env",
    [string]$ConfigPath,
    [string]$OfficialRepoUrl,
    [string]$CurrentKitVersion,
    [string]$TargetPath,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptVersion = "0.3.5"
$DefaultOfficialRepoUrl = "https://github.com/0xbfb/ubu-suite.git"

function Fail([string]$Message) {
    throw "[governor:$ScriptVersion] $Message"
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

function Resolve-KitVersionFromConfig([AllowNull()]$Object, [string]$SourceName) {
    if ($null -eq $Object) { return $null }

    $candidates = @(
        @{ Path = @('kit','version'); Label = 'kit.version' },
        @{ Path = @('currentRelease','version'); Label = 'currentRelease.version' },
        @{ Path = @('lastRelease','version'); Label = 'lastRelease.version' },
        @{ Path = @('implementationStage','release'); Label = 'implementationStage.release' }
    )

    foreach ($candidate in $candidates) {
        $value = Get-ConfigValue $Object $candidate.Path
        if (-not (Is-Blank $value)) {
            if ($candidate.Label -ne 'kit.version') {
                Write-Host "Aviso: $SourceName sem kit.version; usando fallback $($candidate.Label)=$value para compatibilidade com configs antigas."
            }
            return $value
        }
    }

    $historyProp = $Object.PSObject.Properties['releaseHistory']
    if ($null -ne $historyProp -and $null -ne $historyProp.Value) {
        foreach ($entry in $historyProp.Value) {
            $value = Get-ConfigValue $entry @('version')
            if (-not (Is-Blank $value)) {
                Write-Host "Aviso: $SourceName sem kit.version; usando fallback releaseHistory[].version=$value para compatibilidade com configs antigas."
                return $value
            }
        }
    }

    return $null
}

function Get-ConfigBool([AllowNull()]$Object, [string[]]$Path, [bool]$DefaultValue) {
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

function To-StringArray([AllowNull()]$Value, [string[]]$Fallback) {
    if ($null -eq $Value) { return $Fallback }
    $items = @()
    foreach ($item in $Value) {
        if (-not [string]::IsNullOrWhiteSpace([string]$item)) { $items += [string]$item }
    }
    if ($items.Count -eq 0) { return $Fallback }
    return $items
}

function Parse-SemVer([string]$Version) {
    if ($Version -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
        Fail "Versao invalida para comparacao semver simples: '$Version'. Use MAJOR.MINOR.PATCH."
    }
    return [pscustomobject]@{
        Major = [int]$Matches[1]
        Minor = [int]$Matches[2]
        Patch = [int]$Matches[3]
        Text = $Version
    }
}

function Compare-SemVer([string]$Left, [string]$Right) {
    $a = Parse-SemVer $Left
    $b = Parse-SemVer $Right
    foreach ($part in @('Major', 'Minor', 'Patch')) {
        if ($a.$part -gt $b.$part) { return 1 }
        if ($a.$part -lt $b.$part) { return -1 }
    }
    return 0
}

function Assert-CompatibleUpdate([string]$LocalVersion, [string]$RemoteVersion, [string]$Policy, [bool]$ForceEnabled) {
    $local = Parse-SemVer $LocalVersion
    $remote = Parse-SemVer $RemoteVersion
    if ($Policy -eq 'none' -or $Policy -eq 'disabled') { return $false }
    if ($Policy -eq 'always') { return $true }
    if ($Policy -eq 'compatible_only') {
        if ($local.Major -eq $remote.Major) { return $true }
        if ($ForceEnabled) { return $true }
        Fail "Kit remoto $RemoteVersion tem MAJOR diferente do kit local $LocalVersion. Use -Force para permitir ou -SkipKitUpdate em emergencia."
    }
    Fail "Politica de auto-update desconhecida: $Policy"
}

function Normalize-RelativePath([string]$PathValue) {
    if (Is-Blank $PathValue) { return $null }
    $p = $PathValue.Replace('\\', '/')
    while ($p.StartsWith('/')) { $p = $p.Substring(1) }
    if ($p -match '(^|/)\.\.(/|$)') { Fail "Caminho gerenciado invalido com '..': $PathValue" }
    if ($p -match '^([A-Za-z]:|~)') { Fail "Caminho gerenciado deve ser relativo: $PathValue" }
    return $p
}

function Copy-ManagedFile([string]$RelativePath, [string]$RemoteRoot, [string]$ProjectRoot, [bool]$DryRunEnabled) {
    $normalized = Normalize-RelativePath $RelativePath
    if (Is-Blank $normalized) { return }

    if ($normalized -eq '.env' -or $normalized -like '.git/*' -or $normalized -like 'node_modules/*' -or $normalized -like 'vendor/*') {
        Fail "Arquivo proibido na lista de governorFiles.managed: $normalized"
    }
    if ($normalized -like 'dev/versionador/*' -and $normalized -notin @('dev/versionador/.gitignore', 'dev/versionador/README.md')) {
        Fail "Arquivo proibido do versionador dev-only na lista gerenciada: $normalized"
    }

    $source = Join-Path $RemoteRoot $normalized
    $dest = Join-Path $ProjectRoot $normalized
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "SKIP: arquivo gerenciado nao encontrado no kit remoto: $normalized"
        return
    }

    $sourceFull = [System.IO.Path]::GetFullPath($source)
    $destFull = [System.IO.Path]::GetFullPath($dest)
    if ($sourceFull -ieq $destFull) {
        Write-Host "SKIP: origem e destino sao o mesmo arquivo: $normalized"
        return
    }

    if ($DryRunEnabled) {
        Write-Host "[dry-run] atualizar governor: $normalized"
        return
    }

    $destDir = Split-Path -Parent $destFull
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    Copy-Item -LiteralPath $sourceFull -Destination $destFull -Force
    Write-Host "OK: governor atualizado: $normalized"
}

function Invoke-GitChecked([string[]]$GitArgs, [string]$WorkingDirectory) {
    if ($GitArgs.Count -eq 0) { Fail "Comando Git interno sem argumentos." }
    $pretty = 'git ' + ($GitArgs -join ' ')
    Write-Host "+ $pretty"
    Push-Location $WorkingDirectory
    try {
        & git @GitArgs
        if ($LASTEXITCODE -ne 0) { Fail "Comando Git falhou: $pretty" }
    } finally {
        Pop-Location
    }
}

$envValues = Read-DotEnv $EnvPath
$ResolvedTargetPath = Pick-Value -FlagValue $TargetPath -EnvValues $envValues -EnvNames @('UBU_TARGET_PATH') -ConfigValue $null -DefaultValue (Get-Location).Path
if (Is-Blank $ResolvedTargetPath) { Fail "TargetPath vazio. Use -TargetPath (Get-Location).Path ou execute a partir da raiz do projeto." }
if (-not (Test-Path -LiteralPath $ResolvedTargetPath)) { Fail "TargetPath nao encontrado: $ResolvedTargetPath" }
$ResolvedTargetPath = [System.IO.Path]::GetFullPath($ResolvedTargetPath)

$ResolvedConfigPath = Pick-Value -FlagValue $ConfigPath -EnvValues $envValues -EnvNames @('UBU_RELEASE_CONFIG_PATH', 'RELEASE_CONFIG_PATH') -ConfigValue $null -DefaultValue 'release.config.json'
if (-not [System.IO.Path]::IsPathRooted($ResolvedConfigPath)) { $ResolvedConfigPath = Join-Path $ResolvedTargetPath $ResolvedConfigPath }
$ConfigRoot = Read-JsonConfig $ResolvedConfigPath

$ResolvedOfficialRepoUrl = Pick-Value -FlagValue $OfficialRepoUrl -EnvValues $envValues -EnvNames @('UBU_KIT_REPO_URL', 'UBU_OFFICIAL_KIT_REPO_URL', 'OFFICIAL_KIT_REPO_URL') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','officialRepoUrl')) -DefaultValue $DefaultOfficialRepoUrl
$ResolvedCurrentKitVersion = Pick-Value -FlagValue $CurrentKitVersion -EnvValues $envValues -EnvNames @('UBU_KIT_VERSION') -ConfigValue (Resolve-KitVersionFromConfig $ConfigRoot 'config local') -DefaultValue $ScriptVersion
$ResolvedStableBranch = Pick-Value -FlagValue $null -EnvValues $envValues -EnvNames @('UBU_KIT_STABLE_BRANCH') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','officialStableBranch')) -DefaultValue 'stable'
$Policy = Pick-Value -FlagValue $null -EnvValues $envValues -EnvNames @('UBU_AUTO_UPDATE_POLICY') -ConfigValue (Get-ConfigValue $ConfigRoot @('kit','autoUpdatePolicy')) -DefaultValue 'compatible_only'
$AutoUpdateEnabled = Get-ConfigBool $ConfigRoot @('kit','autoUpdateGovernor') $true

Write-Host "==> UBU governor updater $ScriptVersion"
Write-Host "Kit local:    $ResolvedCurrentKitVersion"
Write-Host "Kit repo:     $ResolvedOfficialRepoUrl"
Write-Host "Kit branch:   $ResolvedStableBranch"
Write-Host "Projeto alvo: $ResolvedTargetPath"
Write-Host "Politica:     $Policy"
Write-Host "Dry-run:      $([bool]$DryRun)"

if (-not $AutoUpdateEnabled) {
    Write-Host "==> Auto-update do governor desabilitado por release.config.json"
    return
}

if (Is-Blank $ResolvedOfficialRepoUrl) { Fail "Repo oficial do kit vazio. Defina kit.officialRepoUrl ou UBU_KIT_REPO_URL." }
if (Is-Blank $ResolvedCurrentKitVersion) { Fail "Versao local do kit vazia. Defina kit.version ou CurrentKitVersion." }

if ($DryRun) {
    Write-Host "[dry-run] verificando atualizacoes reais do UBU Suite sem aplicar arquivos"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ubu-governor-update-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
$remoteRoot = Join-Path $tempRoot "ubu-suite"

try {
    Write-Host "==> Clonando kit oficial para verificacao"
    try {
        Invoke-GitChecked -WorkingDirectory $tempRoot -GitArgs @('clone', '--depth', '1', '--branch', $ResolvedStableBranch, $ResolvedOfficialRepoUrl, $remoteRoot)
    } catch {
        Write-Host "Aviso: clone da branch '$ResolvedStableBranch' falhou. Tentando clone padrao."
        if (Test-Path -LiteralPath $remoteRoot) { Remove-Item -Recurse -Force $remoteRoot }
        Invoke-GitChecked -WorkingDirectory $tempRoot -GitArgs @('clone', '--depth', '1', $ResolvedOfficialRepoUrl, $remoteRoot)
    }

    $remoteConfigPath = Join-Path $remoteRoot "release.config.json"
    $RemoteConfig = Read-JsonConfig $remoteConfigPath
    $RemoteKitVersion = Resolve-KitVersionFromConfig $RemoteConfig 'kit remoto'
    if (Is-Blank $RemoteKitVersion) {
        Write-Host "Aviso: kit remoto nao informa kit.version nem campos de fallback em release.config.json."
        Write-Host "==> Tratando kit remoto como legado/incomparavel e continuando release do projeto atual sem auto-update."
        return
    }

    Write-Host "Kit remoto:   $RemoteKitVersion"
    $comparison = Compare-SemVer $RemoteKitVersion $ResolvedCurrentKitVersion
    if ($comparison -le 0) {
        Write-Host "==> Governor ja esta atualizado. Continuando release do projeto atual."
        return
    }

    [void](Assert-CompatibleUpdate -LocalVersion $ResolvedCurrentKitVersion -RemoteVersion $RemoteKitVersion -Policy $Policy -ForceEnabled ([bool]$Force))

    Write-Host "==> Kit remoto mais novo encontrado. Atualizando governor..."
    $managedFallback = @(
        'release.ps1',
        'release.bat',
        'patch-legacy.ps1',
        'tools/release/git-release.ps1',
        'tools/patch/update-legacy-project.ps1',
        'tools/governor/update-governor.ps1',
        'tools/release/README.md',
        '.gitattributes',
        '.env.example',
        'docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md',
        'docs/POLITICA_VERSIONADOR_DEV_ONLY.md',
        'docs/POLITICA_ISO_STACK_AWARE.md',
        'docs/UBU_ISO_3_1_RELEASE_GOVERNOR.md',
        'docs/UBU-ISO-3.1-RELEASE-CONFIG-FIRST.md',
        'docs/UBU-GOVERNOR-AUTO-UPDATE.md'
    )
    $devOnlyFallback = @('dev/versionador/.gitignore', 'dev/versionador/README.md')
    $managed = To-StringArray -Value $RemoteConfig.governorFiles.managed -Fallback $managedFallback
    $devOnly = To-StringArray -Value $RemoteConfig.governorFiles.devOnly -Fallback $devOnlyFallback

    foreach ($file in $managed) { Copy-ManagedFile -RelativePath $file -RemoteRoot $remoteRoot -ProjectRoot $ResolvedTargetPath -DryRunEnabled:$DryRun }
    foreach ($file in $devOnly) { Copy-ManagedFile -RelativePath $file -RemoteRoot $remoteRoot -ProjectRoot $ResolvedTargetPath -DryRunEnabled:$DryRun }

    if ($DryRun) {
        Write-Host "==> Dry-run concluido: governor remoto comparado, nenhum arquivo aplicado."
    } else {
        Write-Host "==> Governor atualizado com sucesso. Recarregando release.config.json no fluxo principal."
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue }
}

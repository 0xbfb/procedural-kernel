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
$WrapperVersion = "0.3.5"
$GovernorUpdatePath = Join-Path $PSScriptRoot "tools/governor/update-governor.ps1"
$ReleaseScriptPath = Join-Path $PSScriptRoot "tools/release/git-release.ps1"

Write-Host "==> UBU release wrapper $WrapperVersion"
Write-Host "==> Modo config-first: use release.config.json como fonte principal; flags sao overrides"

if (-not (Test-Path -LiteralPath $ReleaseScriptPath)) {
    throw "Script de release nao encontrado em: $ReleaseScriptPath"
}

if ($SkipKitUpdate) {
    Write-Host "==> Verificacao de atualizacao do UBU Suite ignorada por -SkipKitUpdate"
} elseif (Test-Path -LiteralPath $GovernorUpdatePath) {
    Write-Host "==> Verificando atualizacoes do UBU Suite antes do release"
    & $GovernorUpdatePath `
        -EnvPath $EnvPath `
        -ConfigPath $ConfigPath `
        -OfficialRepoUrl $OfficialKitRepoUrl `
        -CurrentKitVersion $WrapperVersion `
        -TargetPath $PSScriptRoot `
        -DryRun:$DryRun `
        -Force:$Force

    if (-not $?) {
        throw "Atualizacao/verificacao do governor falhou. Corrija o erro ou use -SkipKitUpdate em emergencia."
    }
} else {
    throw "Script de autoatualizacao do governor nao encontrado em: $GovernorUpdatePath. Use -SkipKitUpdate apenas em emergencia."
}

# O update-governor pode substituir o orquestrador. Resolva o caminho novamente antes de continuar.
$ReleaseScriptPath = Join-Path $PSScriptRoot "tools/release/git-release.ps1"
if (-not (Test-Path -LiteralPath $ReleaseScriptPath)) {
    throw "Script de release nao encontrado apos verificacao do governor em: $ReleaseScriptPath"
}

Write-Host "==> Continuando release do projeto atual"
& $ReleaseScriptPath @PSBoundParameters
exit $LASTEXITCODE

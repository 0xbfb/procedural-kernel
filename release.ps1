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
$WrapperVersion = "0.3.1"
$ScriptPath = Join-Path $PSScriptRoot "tools/release/git-release.ps1"

Write-Host "==> UBU release wrapper $WrapperVersion"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Script de release nao encontrado em: $ScriptPath"
}

& $ScriptPath @PSBoundParameters
exit $LASTEXITCODE

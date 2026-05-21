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
$WrapperVersion = "0.3.5"
$ScriptPath = Join-Path $PSScriptRoot "tools/patch/update-legacy-project.ps1"

Write-Host "==> UBU legacy patch wrapper $WrapperVersion"

if ([string]::IsNullOrWhiteSpace($TargetPath)) {
    throw "TargetPath vazio. Use -TargetPath (Get-Location).Path, -TargetPath . ou informe o caminho absoluto do projeto alvo. Verifique tambem se voce nao digitou `$PDW em vez de `$PWD."
}

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Script de patch legado nao encontrado em: $ScriptPath"
}

& $ScriptPath @PSBoundParameters
exit $LASTEXITCODE

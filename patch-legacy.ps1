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
$scriptPath = Join-Path $PSScriptRoot 'tools/patch/update-legacy-project.ps1'

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Script de patch legado nao encontrado: $scriptPath"
}

& $scriptPath @PSBoundParameters
exit $LASTEXITCODE

param(
  [string]$Remote = $env:UBU_GIT_REMOTE
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "UBU Version Governor - Instalação ISO/3.1 E"
Write-Host "1. Patch"
Write-Host "2. Release"
Write-Host "3. Nightly"
Write-Host "4. Stable"
Write-Host "5. Branch customizada"
Write-Host "0. Sair"
$choice = Read-Host "Opção"

switch ($choice) {
  "0" { exit 0 }
  "1" { $branch = Read-Host "Branch patch, ex: patch/0.1.1" }
  "2" { $branch = Read-Host "Branch release, ex: release/0.1.0" }
  "3" { $branch = "nightly" }
  "4" { $branch = "stable" }
  "5" { $branch = Read-Host "Branch customizada" }
  default { throw "Opção inválida" }
}

if (Test-Path ".git") {
  git fetch --all --tags
  git checkout $branch
  git pull --ff-only
} elseif ($Remote) {
  $target = Join-Path $HOME "ubu-version-governor"
  if (!(Test-Path $target)) {
    git clone --branch $branch $Remote $target
  }
  Set-Location $target
} else {
  Write-Host "Sem .git e sem UBU_GIT_REMOTE. Instalação local seguirá sem troca de branch."
}

if (!(Test-Path ".venv")) {
  python -m venv .venv
}
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e .
python -m ubu_version_governor doctor

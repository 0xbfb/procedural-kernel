param(
  [string]$DefaultBranch = "release/0.1.3"
)

$ErrorActionPreference = "Stop"

Write-Host "==============================================="
Write-Host "Procedural Kernel - seletor de instalacao"
Write-Host "==============================================="
Write-Host ""
Write-Host "1. Patch"
Write-Host "2. Release"
Write-Host "3. Nightly"
Write-Host "4. Stable"
Write-Host "5. Branch customizada"
Write-Host "6. Diretorio atual / ZIP local"
Write-Host "0. Sair"
Write-Host ""

$choice = Read-Host "Opcao"
$branch = ""

switch ($choice) {
  "0" { exit 0 }
  "1" { $branch = Read-Host "Branch patch, ex: patch/0.1.3" }
  "2" { $branch = Read-Host "Branch release, ex: release/0.1.3" }
  "3" { $branch = "nightly" }
  "4" { $branch = "stable" }
  "5" { $branch = Read-Host "Branch customizada" }
  "6" { $branch = "" }
  default { $branch = $DefaultBranch }
}

if ($branch -and (Test-Path ".git")) {
  git fetch --all --tags
  git checkout $branch
  git pull --ff-only
} elseif ($branch) {
  Write-Host "Diretorio sem .git. Continuando com instalacao local."
}

if (Test-Path ".\install.bat") {
  & ".\install.bat"
} else {
  Write-Error "install.bat nao encontrado."
}

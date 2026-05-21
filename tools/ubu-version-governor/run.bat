@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ======================================================
echo UBU Version Governor - Run
echo ======================================================

where git >nul 2>nul
if not errorlevel 1 if exist .git (
  echo Verificando atualizacoes...
  git fetch --all --tags
  git pull --ff-only || echo Aviso: nao foi possivel aplicar pull automatico.
)

if exist .venv\Scripts\activate.bat (
  call .venv\Scripts\activate.bat
)

python -m ubu_version_governor doctor
if exist examples\version-chain.example.json (
  echo.
  echo Exemplo de plano:
  python -m ubu_version_governor plan --input examples\version-chain.example.json
)

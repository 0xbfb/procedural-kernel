@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
cd /d "%ROOT%"

if not exist "logs" mkdir "logs"
set "LOG=logs\run.log"

echo [%date% %time%] Inicio da execucao >> "%LOG%"
echo ===============================================
echo Procedural Kernel - run.bat
echo ===============================================
echo.

call :check_updates
if errorlevel 1 (
  echo Nao foi possivel verificar/aplicar atualizacoes. Prosseguindo com execucao local.
  echo [%date% %time%] AVISO: update falhou >> "%LOG%"
)

call :boot %*
exit /b %ERRORLEVEL%

:check_updates
if exist ".git" (
  where git >nul 2>nul
  if errorlevel 1 (
    echo Git nao encontrado. Pulando update.
    echo [%date% %time%] Git nao encontrado; update pulado >> "%LOG%"
    exit /b 0
  )

  git remote -v >nul 2>nul
  if errorlevel 1 (
    echo Repositorio sem remote. Pulando update.
    echo [%date% %time%] Sem remote; update pulado >> "%LOG%"
    exit /b 0
  )

  git fetch --all --prune --tags >> "%LOG%" 2>&1
  if errorlevel 1 exit /b 1

  git pull --ff-only >> "%LOG%" 2>&1
  if errorlevel 1 exit /b 1

  echo Verificacao de update concluida.
) else (
  echo Nenhum repositorio Git detectado. Pulando update.
  echo [%date% %time%] Sem .git; update pulado >> "%LOG%"
)
exit /b 0

:boot
if not exist ".venv\Scripts\activate.bat" (
  echo Ambiente .venv nao encontrado. Execute install.bat novamente.
  echo [%date% %time%] ERRO: .venv ausente >> "%LOG%"
  pause
  exit /b 1
)

call ".venv\Scripts\activate.bat"
if errorlevel 1 exit /b 1

if "%~1"=="version-plan" (
  python scripts\version\plan_version_chain.py
  exit /b %ERRORLEVEL%
)

if "%~1"=="version-validate" (
  python scripts\validate_version_chain.py docs\releases\version-chain.json
  exit /b %ERRORLEVEL%
)

if "%~1"=="" (
  python -m procedural_kernel.cli doctor
) else (
  python -m procedural_kernel.cli %*
)
exit /b %ERRORLEVEL%

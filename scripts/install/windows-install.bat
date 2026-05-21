@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
cd /d "%ROOT%"

if not exist "logs" mkdir "logs"
set "LOG=logs\install.log"

echo [%date% %time%] Inicio da instalacao > "%LOG%"
echo ===============================================
echo Procedural Kernel - install.bat ISO/3.1E
echo ===============================================
echo.

echo Escolha o canal/branch para instalar antes de preparar o ambiente:
echo 1. Patch
echo 2. Release
echo 3. Nightly
echo 4. Stable
echo 5. Branch customizada
echo 6. Instalar este ZIP/diretorio atual sem trocar branch
echo 0. Sair
echo.
set /p UBU_CHOICE="Opcao: "

if "%UBU_CHOICE%"=="0" exit /b 0
if "%UBU_CHOICE%"=="1" set /p UBU_BRANCH="Branch patch, ex: patch/0.1.3: "
if "%UBU_CHOICE%"=="2" set /p UBU_BRANCH="Branch release, ex: release/0.1.3: "
if "%UBU_CHOICE%"=="3" set "UBU_BRANCH=nightly"
if "%UBU_CHOICE%"=="4" set "UBU_BRANCH=stable"
if "%UBU_CHOICE%"=="5" set /p UBU_BRANCH="Branch customizada: "
if "%UBU_CHOICE%"=="6" set "UBU_BRANCH="

if not "%UBU_BRANCH%"=="" (
  if not exist ".git" (
    echo Este diretorio nao possui .git. A troca de branch exige clone Git.
    echo Prosseguindo com instalacao local deste ZIP/diretorio.
    echo [%date% %time%] Sem .git; menu de branch ignorado >> "%LOG%"
  ) else (
    where git >nul 2>nul
    if errorlevel 1 (
      echo Git nao encontrado. Nao foi possivel trocar branch.
      echo [%date% %time%] Git nao encontrado >> "%LOG%"
      pause
      exit /b 1
    )
    echo Atualizando repositorio e mudando para !UBU_BRANCH!...
    git fetch --all --tags >> "%LOG%" 2>&1
    if errorlevel 1 goto :install_error
    git checkout "!UBU_BRANCH!" >> "%LOG%" 2>&1
    if errorlevel 1 goto :install_error
    git pull --ff-only >> "%LOG%" 2>&1
    if errorlevel 1 goto :install_error
  )
)

where python >nul 2>nul
if errorlevel 1 (
  echo Python nao encontrado. Instale Python 3.12+ e tente novamente.
  echo [%date% %time%] ERRO: Python nao encontrado >> "%LOG%"
  pause
  exit /b 1
)

python -c "import sys; raise SystemExit(0 if sys.version_info >= (3,12) else 1)" >nul 2>nul
if errorlevel 1 (
  echo Python 3.12+ e necessario.
  echo [%date% %time%] ERRO: Python menor que 3.12 >> "%LOG%"
  pause
  exit /b 1
)

if not exist ".venv" (
  echo Criando ambiente virtual .venv...
  echo [%date% %time%] Criando venv >> "%LOG%"
  python -m venv .venv
  if errorlevel 1 goto :install_error
)

call ".venv\Scripts\activate.bat"
if errorlevel 1 goto :install_error

echo Atualizando pip...
python -m pip install --upgrade pip >> "%LOG%" 2>&1
if errorlevel 1 goto :install_error

echo Instalando pacote em modo editavel...
python -m pip install -e ".[dev]" >> "%LOG%" 2>&1
if errorlevel 1 goto :install_error


if exist "scripts\install\windows-run.bat" (
  copy /Y "scripts\install\windows-run.bat" "run.bat" >nul
) else (
  echo Template scripts\install\windows-run.bat nao encontrado.
  echo [%date% %time%] ERRO: template run.bat ausente >> "%LOG%"
  pause
  exit /b 1
)

echo Executando doctor...
call "%ROOT%run.bat" doctor
set "RUN_EXIT=%ERRORLEVEL%"

if not "%RUN_EXIT%"=="0" (
  echo Doctor retornou erro %RUN_EXIT%.
  echo [%date% %time%] ERRO: doctor retornou %RUN_EXIT% >> "%LOG%"
  pause
  exit /b %RUN_EXIT%
)

echo.
echo Instalacao concluida. Use run.bat nos proximos usos.
echo [%date% %time%] Instalacao concluida >> "%LOG%"
start "" cmd /c "timeout /t 2 >nul & del /f /q ""%~f0"""
exit /b 0

:install_error
echo.
echo Falha na instalacao. Veja logs\install.log.
echo [%date% %time%] ERRO: falha na instalacao >> "%LOG%"
pause
exit /b 1

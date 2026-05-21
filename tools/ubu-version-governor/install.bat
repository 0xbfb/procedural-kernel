@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

echo ======================================================
echo UBU Version Governor - Instalador ISO/3.1 E
echo ======================================================
echo.
echo Escolha o canal/versao a instalar:
echo.
echo   1. Patch     ^(ex: patch/0.1.1^)
echo   2. Release   ^(ex: release/0.1.0^)
echo   3. Nightly   ^(branch nightly^)
echo   4. Stable    ^(branch stable^)
echo   5. Branch customizada
echo   0. Sair
echo.
set /p UBU_CHOICE="Opcao: "

if "%UBU_CHOICE%"=="0" exit /b 0
if "%UBU_CHOICE%"=="1" set /p UBU_BRANCH="Informe a branch patch: "
if "%UBU_CHOICE%"=="2" set /p UBU_BRANCH="Informe a branch release: "
if "%UBU_CHOICE%"=="3" set UBU_BRANCH=nightly
if "%UBU_CHOICE%"=="4" set UBU_BRANCH=stable
if "%UBU_CHOICE%"=="5" set /p UBU_BRANCH="Informe a branch customizada: "

if not defined UBU_BRANCH (
  echo Opcao invalida.
  exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
  echo Git nao encontrado. A instalacao local continuara sem troca de branch.
  goto install_python
)

if exist .git (
  echo.
  echo Atualizando repositorio e redirecionando para: %UBU_BRANCH%
  git fetch --all --tags || exit /b 1
  git checkout "%UBU_BRANCH%" || exit /b 1
  git pull --ff-only || echo Aviso: pull fast-forward nao aplicado. Verifique o remoto.
) else (
  echo.
  echo Este diretorio veio sem .git. Para redirecionar branch automaticamente, execute em um clone Git.
  if defined UBU_GIT_REMOTE (
    echo UBU_GIT_REMOTE encontrado. Clonando branch %UBU_BRANCH%...
    cd /d "%USERPROFILE%"
    if not exist "ubu-version-governor" git clone --branch "%UBU_BRANCH%" "%UBU_GIT_REMOTE%" "ubu-version-governor" || exit /b 1
    cd /d "%USERPROFILE%\ubu-version-governor" || exit /b 1
  )
)

:install_python
where python >nul 2>nul
if errorlevel 1 (
  echo Python nao encontrado no PATH.
  exit /b 1
)

if not exist .venv (
  python -m venv .venv || exit /b 1
)

call .venv\Scripts\activate.bat || exit /b 1
python -m pip install --upgrade pip
python -m pip install -e .

echo.
echo Instalacao concluida.
echo Para iniciar, execute run.bat
echo.
call run.bat

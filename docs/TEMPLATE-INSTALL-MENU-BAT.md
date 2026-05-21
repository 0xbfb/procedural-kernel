# Template — menu de instalação por canal/branch

```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo ================================================
echo Instalação UBU compatível com ISO/3.1 E
echo ================================================
echo 1. Patch
echo 2. Release
echo 3. Nightly
echo 4. Stable
echo 5. Branch customizada
echo 0. Sair
set /p UBU_CHOICE="Escolha a versão/canal: "

if "%UBU_CHOICE%"=="1" set /p UBU_BRANCH="Branch patch, ex: patch/0.2.1: "
if "%UBU_CHOICE%"=="2" set /p UBU_BRANCH="Branch release, ex: release/0.2.0: "
if "%UBU_CHOICE%"=="3" set UBU_BRANCH=nightly
if "%UBU_CHOICE%"=="4" set UBU_BRANCH=stable
if "%UBU_CHOICE%"=="5" set /p UBU_BRANCH="Branch customizada: "
if "%UBU_CHOICE%"=="0" exit /b 0

if not exist .git (
  echo Este diretório não possui .git. Configure um remoto ou instale a partir de um clone.
  exit /b 1
)

git fetch --all --tags || exit /b 1
git checkout "%UBU_BRANCH%" || exit /b 1
git pull --ff-only || exit /b 1
call run.bat
```

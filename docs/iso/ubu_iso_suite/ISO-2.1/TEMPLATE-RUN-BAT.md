# Template — run.bat conforme UBU-ISO/2.1

> Este template deve ser adaptado ao projeto real. O update e o boot não devem ser inventados.

```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
cd /d "%ROOT%"

if not exist "logs" mkdir "logs"
set "LOG=logs\run.log"

echo [%date% %time%] Inicio da execucao >> "%LOG%"
echo ===============================================
echo Inicializando projeto
echo ===============================================
echo.

call :check_updates
if errorlevel 1 (
  echo Nao foi possivel verificar/aplicar atualizacoes.
  echo Prosseguindo somente se a execucao local for segura.
  echo [%date% %time%] AVISO: update falhou >> "%LOG%"
)

call :boot
exit /b %ERRORLEVEL%

:check_updates
REM Estrategia Git, quando aplicavel:
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

  git fetch --all --prune
  if errorlevel 1 exit /b 1

  REM Projeto deve definir branch/upstream real.
  REM Exemplo conservador:
  git status -uno
  echo Verificacao de update concluida.
  exit /b 0
)

REM Estrategia alternativa ZIP/API deve ser implementada pelo projeto.
echo Nenhum mecanismo automatico de update configurado.
echo [%date% %time%] Nenhum update configurado >> "%LOG%"
exit /b 0

:boot
REM Insira aqui o comando real do projeto.
REM Python exemplo:
REM call .venv\Scripts\activate.bat
REM python -m nome_do_modulo

REM Node exemplo:
REM pnpm start

REM PHP exemplo:
REM php artisan serve

echo Comando de boot ainda nao configurado.
echo Atualize run.bat conforme README do projeto.
pause
exit /b 1
```

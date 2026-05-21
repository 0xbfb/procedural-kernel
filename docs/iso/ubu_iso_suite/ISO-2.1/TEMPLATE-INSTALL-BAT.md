# Template — install.bat conforme UBU-ISO/2.1

> Este é um template genérico. O agente deve adaptar ao stack real do projeto. Não use comandos fictícios como se fossem reais.

```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
cd /d "%ROOT%"

if not exist "logs" mkdir "logs"
set "LOG=logs\install.log"

echo [%date% %time%] Inicio da instalacao > "%LOG%"
echo ===============================================
echo Instalador do projeto
echo ===============================================
echo.

REM 1. Detectar runtime
REM Exemplo Python:
REM where python >nul 2>nul
REM if errorlevel 1 (
REM   echo Python nao encontrado.
REM   echo [%date% %time%] ERRO: Python nao encontrado >> "%LOG%"
REM   pause
REM   exit /b 1
REM )

REM 2. Instalar dependencias
REM Adaptar conforme stack real.
REM Python:
REM if not exist ".venv" python -m venv .venv
REM call .venv\Scripts\activate.bat
REM python -m pip install --upgrade pip
REM if exist "requirements.txt" pip install -r requirements.txt

REM Node:
REM if exist "pnpm-lock.yaml" pnpm install
REM if exist "package-lock.json" npm install

REM PHP:
REM if exist "composer.json" composer install

REM 3. Criar run.bat
call :write_run_bat
if errorlevel 1 (
  echo Falha ao criar run.bat.
  echo [%date% %time%] ERRO: falha ao criar run.bat >> "%LOG%"
  pause
  exit /b 1
)

REM 4. Rodar programa
call "%ROOT%run.bat"
set "RUN_EXIT=%ERRORLEVEL%"

if not "%RUN_EXIT%"=="0" (
  echo O programa retornou erro %RUN_EXIT%.
  echo [%date% %time%] AVISO: run.bat retornou %RUN_EXIT% >> "%LOG%"
)

REM 5. Agendar remocao do install.bat apos sucesso suficiente
echo Instalacao concluida. O install.bat sera removido.
start "" cmd /c "timeout /t 2 >nul & del /f /q "%~f0""
exit /b %RUN_EXIT%

:write_run_bat
> "%ROOT%run.bat" echo @echo off
>> "%ROOT%run.bat" echo setlocal EnableExtensions EnableDelayedExpansion
>> "%ROOT%run.bat" echo set "ROOT=%%~dp0"
>> "%ROOT%run.bat" echo cd /d "%%ROOT%%"
>> "%ROOT%run.bat" echo if not exist "logs" mkdir "logs"
>> "%ROOT%run.bat" echo echo [%%date%% %%time%%] Inicio da execucao ^>^> "logs\run.log"
>> "%ROOT%run.bat" echo REM TODO: inserir verificacao de update conforme projeto
>> "%ROOT%run.bat" echo REM TODO: inserir comando real de boot
>> "%ROOT%run.bat" echo echo Configure o comando de boot em run.bat
>> "%ROOT%run.bat" echo pause
>> "%ROOT%run.bat" echo exit /b 0
exit /b 0
```

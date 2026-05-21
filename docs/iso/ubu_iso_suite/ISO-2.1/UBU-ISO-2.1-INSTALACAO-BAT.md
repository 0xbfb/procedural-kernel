# UBU-ISO/2.1 — Instalação Windows por `install.bat`, Atualização e `run.bat`

> Norma interna UBU para padronização de instalação de projetos por um único `.bat`, criação de `run.bat`, boot automático e verificação de atualizações antes da execução.

---

## Índice

- [Identidade da norma](#identidade-da-norma)
- [Objetivo](#objetivo)
- [Regra central](#regra-central)
- [Escopo](#escopo)
- [Arquivos obrigatórios](#arquivos-obrigatórios)
- [Comportamento obrigatório do install.bat](#comportamento-obrigatório-do-installbat)
- [Comportamento obrigatório do run.bat](#comportamento-obrigatório-do-runbat)
- [Política de atualização](#política-de-atualização)
- [Política de segurança](#política-de-segurança)
- [Logs e diagnóstico](#logs-e-diagnóstico)
- [Compatibilidade por stack](#compatibilidade-por-stack)
- [Rotina de adoção inicial](#rotina-de-adoção-inicial)
- [Rotina de verificação de conformidade](#rotina-de-verificação-de-conformidade)
- [Critérios de aceite](#critérios-de-aceite)
- [Documentos relacionados](#documentos-relacionados)

---

## Identidade da norma

```text
Nome: UBU-ISO/2.1
Tema: Instalação Windows por install.bat, autoupdate e run.bat
Versão da norma: 2.1
Status: obrigatório para projetos UBU compatíveis com execução Windows simplificada
Escopo: install.bat, run.bat, bootstrap, atualização, execução, logs, UX de terminal e documentação de instalação
```

---

## Objetivo

A UBU-ISO/2.1 define um padrão para instalar e executar projetos com o mínimo de atrito para usuário final no Windows.

O objetivo é que o usuário consiga:

1. baixar o projeto;
2. executar um único `install.bat`;
3. ter dependências instaladas;
4. iniciar o programa automaticamente;
5. passar a usar `run.bat` nos próximos usos;
6. receber atualização automática antes do boot;
7. não precisar entender stack, venv, npm, composer, git ou comandos internos.

---

## Regra central

Todo projeto compatível com UBU-ISO/2.1 deve seguir este fluxo:

```text
install.bat
  > detecta ambiente
  > instala dependências
  > prepara configuração local
  > cria ou atualiza run.bat
  > executa o programa
  > remove ou agenda remoção do install.bat após sucesso

run.bat
  > verifica atualizações
  > se houver atualização segura, atualiza
  > se não houver atualização, inicia direto
  > se update falhar, informa erro claro e oferece execução local quando seguro
```

---

## Escopo

A ISO/2.1 se aplica quando qualquer condição for verdadeira:

1. o projeto é distribuído para usuário final Windows;
2. o usuário pediu instalação com um comando;
3. existe API local, CLI, jogo, app desktop ou serviço local;
4. o projeto exige setup de dependências;
5. o projeto possui atualização frequente por ZIP, Git ou pacote;
6. o projeto tem arquitetura com instalador separado.

Pode ser marcada como não aplicável quando:

1. o projeto é biblioteca sem execução direta;
2. o projeto é exclusivamente web hospedado;
3. o projeto não tem alvo Windows;
4. existe instalador nativo mais apropriado, documentado e mantido.

A não aplicabilidade deve ser justificada no README ou patch notes.

---

## Arquivos obrigatórios

Quando aplicável, o projeto deve conter:

```text
install.bat
run.bat
```

Recomendado:

```text
scripts/
  install/
    windows-install.bat
    windows-run.bat
    update-check.bat
logs/
  .gitkeep
```

Quando houver instalador como repositório separado:

```text
installer/
  README.md
  install.bat
  run.bat
  config/
    sources.json
```

---

## Comportamento obrigatório do install.bat

O `install.bat` deve:

1. iniciar com `@echo off`;
2. definir diretório base pelo próprio arquivo;
3. validar runtime necessário;
4. instalar dependências;
5. criar ambiente local quando aplicável;
6. não exigir edição manual para caminho comum;
7. criar ou atualizar `run.bat`;
8. registrar log mínimo;
9. informar erro com mensagem clara;
10. executar o programa após instalação bem-sucedida;
11. remover ou agendar remoção do próprio `install.bat` após sucesso;
12. não apagar dados do usuário;
13. não sobrescrever `.env`, saves ou configs locais sem backup;
14. ser idempotente até o ponto de sucesso.

### Remoção do install.bat

No Windows, um `.bat` não deve tentar se apagar antes de terminar.

Fluxo recomendado:

```bat
start "" cmd /c "timeout /t 2 >nul & del /f /q "%~f0""
```

A remoção só pode acontecer após:

1. dependências instaladas;
2. `run.bat` criado;
3. boot inicial iniciado ou concluído com sucesso suficiente;
4. erro crítico ausente.

Se a remoção falhar, não deve quebrar o projeto. Deve apenas informar:

```text
Instalação concluída. Não foi possível remover install.bat automaticamente; pode apagá-lo manualmente.
```

---

## Comportamento obrigatório do run.bat

O `run.bat` deve:

1. iniciar com `@echo off`;
2. localizar diretório do projeto;
3. verificar atualizações antes do boot;
4. não bloquear execução por falha não crítica de update;
5. executar o programa com comando claro;
6. exibir logs mínimos;
7. preservar dados locais;
8. retornar erro legível quando falhar;
9. ser o ponto padrão de entrada após a instalação.

Fluxo obrigatório:

```text
abrir run.bat
  > verificar update
  > se sem update: boot direto
  > se com update: aplicar update seguro
  > validar pós-update
  > boot
```

---

## Política de atualização

O projeto deve declarar o mecanismo de update.

Opções aceitas:

| Tipo | Uso recomendado |
|---|---|
| Git pull | projetos distribuídos como repositório Git |
| Release ZIP | projetos distribuídos por pacote versionado |
| Instalador separado | arquitetura engine/dados/installer |
| Package manager | npm, pnpm, pip, composer, cargo etc. |
| Manual documentado | quando update automático não é seguro ainda |

### Update por Git

Permitido quando o projeto possui `.git` e remote configurado.

Regras:

1. checar se `git` existe;
2. checar se há remote;
3. executar `git fetch`;
4. comparar branch local com upstream;
5. aplicar update apenas se não houver conflito local crítico;
6. registrar erro se houver conflito;
7. não apagar alterações locais sem consentimento.

### Update por ZIP

Permitido quando houver URL oficial de release.

Regras:

1. baixar para pasta temporária;
2. validar download;
3. preservar configs, saves e dados locais;
4. substituir apenas arquivos de aplicação;
5. manter rollback ou backup quando possível.

### Update por instalador separado

Quando houver repositório `installer`, ele deve ser o intermediário para:

1. listar engines disponíveis;
2. listar fontes de dados disponíveis;
3. atualizar engine;
4. atualizar dados;
5. iniciar jogo/app;
6. exibir splash opcional;
7. expor menu de testes, checks e simulações quando aplicável.

---

## Política de segurança

`install.bat` e `run.bat` não podem:

1. apagar dados do usuário;
2. executar comando remoto sem validação mínima;
3. baixar script e executar silenciosamente sem fonte declarada;
4. sobrescrever `.env` sem backup;
5. sobrescrever saves;
6. esconder erro;
7. exigir privilégio de administrador sem necessidade;
8. alterar PATH global sem consentimento;
9. instalar software global quando instalação local basta;
10. deixar token, segredo ou URL sensível hardcoded.

---

## Logs e diagnóstico

O projeto deve registrar logs simples em local previsível.

Recomendado:

```text
logs/install.log
logs/run.log
```

Se o projeto não versiona `logs/`, use:

```text
logs/.gitkeep
```

O log deve conter:

1. data/hora;
2. etapa;
3. comando principal;
4. sucesso/falha;
5. mensagem de erro;
6. orientação para usuário.

---

## Compatibilidade por stack

O agente deve detectar a stack pelo projeto real.

### Python

Sinais:

```text
pyproject.toml
requirements.txt
setup.py
src/
```

Comandos comuns:

```bat
python -m venv .venv
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
python -m pacote_ou_modulo
```

### Node

Sinais:

```text
package.json
pnpm-lock.yaml
package-lock.json
yarn.lock
```

Comandos comuns:

```bat
pnpm install
pnpm start
npm install
npm run start
```

### PHP/Laravel

Sinais:

```text
composer.json
artisan
```

Comandos comuns:

```bat
composer install
php artisan config:clear
php artisan serve
```

### Projetos mistos

Quando houver múltiplas stacks, `install.bat` deve separar etapas e falhar com mensagem clara indicando qual runtime faltou.

---

## Rotina de adoção inicial

Se o projeto nunca usou UBU-ISO/2.1 e a ISO for aplicável:

1. criar `docs/UBU-ISO-2.1-INSTALACAO-BAT.md`;
2. detectar stack do projeto;
3. criar `install.bat` na raiz ou justificar impossibilidade;
4. criar `run.bat` ou template inicial;
5. documentar comando de boot no README;
6. documentar update no README;
7. criar logs ou caminho de logs;
8. atualizar `AGENTS.md`;
9. registrar adoção em patch notes.

Se não for possível implementar com segurança:

1. criar ISO;
2. criar checklist;
3. registrar pendências;
4. não fingir conformidade.

---

## Rotina de verificação de conformidade

Se o projeto já usa UBU-ISO/2.1:

1. verificar se `install.bat` ainda instala tudo;
2. verificar se `install.bat` cria/atualiza `run.bat`;
3. verificar se `install.bat` remove ou agenda remoção de si mesmo;
4. verificar se `run.bat` checa atualização antes do boot;
5. verificar se update preserva dados locais;
6. verificar se comandos documentados ainda existem;
7. atualizar documentação apenas se houver mudança real;
8. versionar documentação se a norma mudou;
9. registrar patch notes.

---

## Critérios de aceite

```markdown
- [ ] ISO/2.1 existe em docs/
- [ ] README explica instalação por install.bat
- [ ] README explica execução por run.bat
- [ ] AGENTS.md instrui agentes a manter ISO/2.1
- [ ] install.bat instala dependências ou pendência justificada
- [ ] install.bat roda o programa após instalação
- [ ] install.bat cria/atualiza run.bat
- [ ] install.bat remove ou agenda remoção de si mesmo após sucesso
- [ ] run.bat verifica atualizações antes do boot
- [ ] run.bat inicia direto quando não há update
- [ ] run.bat preserva dados locais
- [ ] logs mínimos existem ou são documentados
- [ ] patch notes atualizadas
```

---

## Documentos relacionados

- [UBU-ISO/1.0 — Dados](./UBU-ISO-1.0-DADOS-CAMADAS.md)
- [UBU-ISO/2.0 — Documentação Técnica](./UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md)
- [Patch notes](./releases/PATCH_NOTES.md)
- [Release notes](./releases/RELEASE_NOTES.md)

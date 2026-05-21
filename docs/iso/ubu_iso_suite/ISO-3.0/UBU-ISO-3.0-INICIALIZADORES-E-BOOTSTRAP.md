# UBU-ISO/3.0 — Inicializadores, Bootstrap, Containers e Execução Padronizada

> Norma interna UBU para padronização de inicializadores obrigatórios, instalação por stack, execução local, containers, comandos canônicos, Makefile, Dockerfile, `docker-compose.yml` e validações obrigatórias em todo patch.

---

## Índice

- [1. Identidade da norma](#1-identidade-da-norma)
- [2. Objetivo](#2-objetivo)
- [3. Escopo obrigatório](#3-escopo-obrigatório)
- [4. Relação com outras ISOs UBU](#4-relação-com-outras-isos-ubu)
- [5. Princípios obrigatórios](#5-princípios-obrigatórios)
- [6. Arquivos obrigatórios](#6-arquivos-obrigatórios)
- [7. Classificação automática do projeto](#7-classificação-automática-do-projeto)
- [8. Contrato de bootstrap por stack](#8-contrato-de-bootstrap-por-stack)
- [9. Contrato de Docker](#9-contrato-de-docker)
- [10. Contrato de docker-compose](#10-contrato-de-docker-compose)
- [11. Contrato de Makefile](#11-contrato-de-makefile)
- [12. Contrato de scripts auxiliares](#12-contrato-de-scripts-auxiliares)
- [13. Contrato de testes de instalação e inicialização](#13-contrato-de-testes-de-instalação-e-inicialização)
- [14. Rotina obrigatória em todo patch](#14-rotina-obrigatória-em-todo-patch)
- [15. Rotina de adoção inicial](#15-rotina-de-adoção-inicial)
- [16. Rotina de verificação de conformidade](#16-rotina-de-verificação-de-conformidade)
- [17. Política de exceções](#17-política-de-exceções)
- [18. Regras para agentes de IA](#18-regras-para-agentes-de-ia)
- [19. Critérios de aceite](#19-critérios-de-aceite)
- [20. Documentos relacionados](#20-documentos-relacionados)

---

## 1. Identidade da norma

```text
Nome: UBU-ISO/3.0
Tema: Inicializadores, bootstrap, containers e execução padronizada
Versão da norma: 3.0
Status: obrigatório para projetos UBU compatíveis
Escopo: projetos novos, projetos existentes, agentes de IA, mantenedores humanos, patches e releases versionadas
```

---

## 2. Objetivo

A UBU-ISO/3.0 define como um projeto deve ser instalado, inicializado, testado e executado de forma padronizada após cada patch.

A norma existe para garantir que qualquer projeto UBU tenha, no mínimo:

1. um caminho canônico de instalação;
2. um caminho canônico de execução;
3. um caminho canônico de testes;
4. arquivos de bootstrap atualizados;
5. Dockerfile e `docker-compose.yml` funcionais ou exceção formal documentada;
6. Makefile com comandos padronizados;
7. scripts auxiliares mantidos após cada patch;
8. validação automatizada de instalação e boot;
9. documentação clara para humanos e agentes;
10. integração com `install.bat` e `run.bat` quando aplicável à UBU-ISO/2.1.

---

## 3. Escopo obrigatório

A ISO se aplica a qualquer projeto UBU que possua pelo menos uma das características abaixo:

1. aplicação executável;
2. biblioteca instalável;
3. CLI;
4. jogo;
5. API;
6. serviço web;
7. worker;
8. pacote npm, pip, composer, apt, pacman ou equivalente;
9. monorepo;
10. módulo que precise de instalação própria.

Mesmo projetos puramente documentais devem declarar exceção formal se não possuírem bootstrap executável.

---

## 4. Relação com outras ISOs UBU

A UBU-ISO/3.0 depende das normas anteriores:

- **UBU-ISO/1.0** define organização de dados, consumo e armazenamento por camada lógica.
- **UBU-ISO/2.0** define documentação técnica, patch notes, release notes e fluxo `patch > release > nightly > stable`.
- **UBU-ISO/2.1** define instalação Windows por `install.bat`, criação de `run.bat`, update e boot automático.
- **UBU-ISO/3.0** define inicializadores, containers, Makefile, comandos por stack e validações de bootstrap.

A aplicação da ISO/3.0 nunca substitui as anteriores. Ela aumenta o nível de exigência operacional.

---

## 5. Princípios obrigatórios

Todo projeto compatível com UBU-ISO/3.0 deve seguir estes princípios:

1. instalar deve ser previsível;
2. executar deve ser previsível;
3. testar deve ser previsível;
4. atualizar bootstrap é parte obrigatória de todo patch;
5. Dockerfile, `docker-compose.yml` e Makefile não são decorativos;
6. se um comando documentado não funciona, o patch está incompleto;
7. se a stack mudou, os inicializadores devem mudar junto;
8. se o projeto é Node, deve ser instalável pelo gerenciador npm declarado;
9. se o projeto é Python, deve ser instalável via pip ou ferramenta declarada sobre pip;
10. se o projeto é PHP/Laravel, deve declarar Composer e comandos Artisan necessários;
11. se depende de pacotes do sistema, deve declarar Debian/Ubuntu `apt` e/ou Arch `pacman` quando aplicável;
12. nenhum agente pode declarar teste de instalação executado sem executar ou justificar formalmente a ausência.

---

## 6. Arquivos obrigatórios

Todo projeto UBU compatível com ISO/3.0 deve possuir na raiz:

```text
Dockerfile
docker-compose.yml
Makefile
README.md
AGENTS.md
```

Quando aplicável, também deve possuir:

```text
install.bat
run.bat
.env.example
.dockerignore
.gitignore
scripts/
  bootstrap.sh
  bootstrap.bat
  doctor.sh
  doctor.bat
  test-bootstrap.sh
  test-bootstrap.bat
```

A ausência de qualquer arquivo obrigatório exige entrada em:

```text
docs/ISO_EXCEPTIONS.md
```

A exceção deve informar:

1. arquivo ausente;
2. motivo técnico;
3. risco;
4. alternativa adotada;
5. data;
6. responsável/agente;
7. critério para remover a exceção.

---

## 7. Classificação automática do projeto

Antes de aplicar qualquer patch, o agente deve classificar a stack principal.

### 7.1 Sinais de Node

Considere Node se existir:

```text
package.json
package-lock.json
pnpm-lock.yaml
yarn.lock
vite.config.*
next.config.*
tsconfig.json
```

Gerenciador padrão:

1. `package-lock.json` → `npm`;
2. `pnpm-lock.yaml` → `pnpm`, mas ainda deve existir caminho documentado via npm se o projeto exigir compatibilidade UBU;
3. `yarn.lock` → `yarn`, com exceção documentada se npm não for suportado;
4. sem lockfile → `npm` por padrão.

### 7.2 Sinais de Python

Considere Python se existir:

```text
pyproject.toml
setup.py
requirements.txt
Pipfile
poetry.lock
uv.lock
```

Gerenciador padrão:

1. `pyproject.toml` → `python -m pip install -e .` como contrato mínimo;
2. `requirements.txt` → `python -m pip install -r requirements.txt`;
3. `poetry.lock` → Poetry permitido, mas deve existir fallback documentado ou exceção;
4. `uv.lock` → uv permitido, mas deve existir fallback documentado ou exceção.

### 7.3 Sinais de PHP/Laravel

Considere PHP se existir:

```text
composer.json
artisan
public/index.php
```

Contrato mínimo:

```bash
composer install
php artisan key:generate --ansi
php artisan migrate --pretend
php artisan test
```

Quando `artisan` não existir, tratar como PHP genérico e usar Composer como base.

### 7.4 Sinais de Debian/Ubuntu

Considere dependência Debian/Ubuntu quando houver:

```text
aptfile
packages.apt
Dockerfile com apt-get
README com apt install
```

Contrato mínimo:

```bash
sudo apt-get update
sudo apt-get install -y <pacotes>
```

Em Dockerfile, nunca usar `sudo`.

### 7.5 Sinais de Arch Linux

Considere dependência Arch quando houver:

```text
PKGBUILD
packages.pacman
README com pacman -S
```

Contrato mínimo:

```bash
sudo pacman -Sy --needed <pacotes>
```

### 7.6 Monorepo

Considere monorepo quando houver:

```text
packages/
apps/
services/
workspaces
pnpm-workspace.yaml
lerna.json
nx.json
```

Monorepos devem ter:

1. Makefile raiz;
2. README raiz;
3. README por pacote relevante;
4. comando de bootstrap raiz;
5. comando de teste raiz;
6. comando de build raiz;
7. documentação de quais pacotes são instaláveis isoladamente.

---

## 8. Contrato de bootstrap por stack

Todo projeto deve declarar comandos canônicos no README e no Makefile.

### 8.1 Node via npm

Obrigatório quando Node for detectado e não houver exceção:

```bash
npm install
npm test
npm run build
npm start
```

Preferência para CI:

```bash
npm ci
npm test
npm run build
```

O `package.json` deve conter scripts equivalentes:

```json
{
  "scripts": {
    "start": "...",
    "test": "...",
    "build": "...",
    "doctor": "..."
  }
}
```

Se algum script não se aplicar, deve existir script placeholder seguro que explique a ausência sem falhar indevidamente, ou exceção formal.

### 8.2 Python via pip

Obrigatório quando Python for detectado e não houver exceção:

```bash
python -m venv .venv
python -m pip install --upgrade pip
python -m pip install -e .
python -m pytest
python -m compileall .
```

Se o projeto usar `requirements.txt`:

```bash
python -m pip install -r requirements.txt
```

Se for CLI, validar também:

```bash
python -m <pacote> --help
```

### 8.3 PHP/Laravel via Composer e Artisan

Obrigatório quando Laravel for detectado e não houver exceção:

```bash
composer install
php artisan config:clear
php artisan route:list
php artisan migrate --pretend
php artisan test
```

Se houver frontend Laravel/Vite:

```bash
npm install
npm run build
```

### 8.4 Debian/Ubuntu via apt

Quando pacotes de sistema forem necessários, declarar em:

```text
docs/system-packages.md
```

Formato obrigatório:

```markdown
# Pacotes de sistema

## Debian/Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y pacote1 pacote2
```

## Motivo dos pacotes

| Pacote | Motivo | Obrigatório? |
|---|---|---|
| pacote1 | motivo | sim |
```
```

### 8.5 Arch Linux via pacman

Quando houver suporte Arch, declarar em:

```markdown
## Arch Linux

```bash
sudo pacman -Sy --needed pacote1 pacote2
```
```

Se Arch não for suportado, declarar explicitamente:

```text
Arch Linux: não suportado oficialmente neste projeto.
```

### 8.6 Projetos híbridos

Projetos híbridos devem declarar ordem de instalação.

Exemplo:

```text
1. apt/pacman: pacotes do sistema
2. composer: dependências PHP
3. npm: assets frontend
4. artisan: configuração Laravel
5. docker compose: serviços locais
6. testes
```

---

## 9. Contrato de Docker

Todo projeto deve ter `Dockerfile` funcional ou exceção formal.

O Dockerfile deve:

1. usar imagem base explícita;
2. instalar dependências de sistema necessárias;
3. copiar apenas arquivos necessários primeiro quando isso melhorar cache;
4. instalar dependências da stack;
5. expor porta quando aplicável;
6. declarar `CMD` ou `ENTRYPOINT`;
7. evitar segredos embutidos;
8. usar `.dockerignore`;
9. ser documentado no README.

É proibido:

1. copiar `.env` real;
2. embutir tokens;
3. depender de caminho absoluto local do desenvolvedor;
4. declarar comandos que não existem;
5. deixar Dockerfile desatualizado após patch.

---

## 10. Contrato de docker-compose

Todo projeto deve ter `docker-compose.yml` funcional ou exceção formal.

O compose deve:

1. declarar serviço principal;
2. declarar serviços auxiliares quando necessários;
3. mapear portas de forma clara;
4. usar volumes previsíveis;
5. usar `.env.example` como referência;
6. ter nomes de serviços compreensíveis;
7. permitir `docker compose up --build`;
8. ser documentado no README.

Comando canônico:

```bash
docker compose up --build
```

Comando de parada:

```bash
docker compose down
```

Quando o projeto precisar de banco, cache, fila ou storage, o compose deve documentar serviços e credenciais de desenvolvimento.

---

## 11. Contrato de Makefile

Todo projeto deve ter `Makefile` funcional ou exceção formal.

Targets obrigatórios:

```makefile
help
install
update
run
test
build
doctor
clean
```

Quando Docker for suportado, adicionar:

```makefile
docker-build
docker-up
docker-down
docker-logs
```

Quando ISO/2.1 for suportada, adicionar:

```makefile
install-bat
run-bat
```

O target `help` deve listar os comandos principais.

O target `doctor` deve verificar:

1. linguagem principal instalada;
2. gerenciador de pacotes;
3. arquivos obrigatórios;
4. dependências mínimas;
5. scripts esperados;
6. Docker disponível, se aplicável;
7. variáveis obrigatórias ausentes.

---

## 12. Contrato de scripts auxiliares

Quando houver pasta `scripts/`, os scripts devem ser simples, documentados e chamados pelo Makefile quando possível.

Scripts recomendados:

```text
scripts/bootstrap.sh
scripts/bootstrap.bat
scripts/doctor.sh
scripts/doctor.bat
scripts/test-bootstrap.sh
scripts/test-bootstrap.bat
scripts/update.sh
scripts/update.bat
```

Regras:

1. scripts não devem duplicar lógica complexa sem necessidade;
2. Makefile deve ser a entrada canônica em Linux/macOS;
3. `install.bat` e `run.bat` devem ser entradas canônicas em Windows quando ISO/2.1 se aplicar;
4. scripts devem falhar com mensagem clara;
5. scripts devem evitar apagar dados sem confirmação;
6. scripts devem não depender de paths absolutos do autor.

---

## 13. Contrato de testes de instalação e inicialização

Todo patch deve validar que o projeto continua instalável e inicializável.

### 13.1 Teste mínimo obrigatório

Em todo patch, executar pelo menos:

```bash
make doctor
make install
make test
```

Se Makefile ainda estiver sendo criado no patch de adoção inicial, executar comandos equivalentes e registrar no patch notes.

### 13.2 Validação por stack

Node:

```bash
npm install
npm test
npm run build
```

Python:

```bash
python -m pip install -e .
python -m pytest
python -m compileall .
```

PHP/Laravel:

```bash
composer install
php artisan config:clear
php artisan route:list
php artisan test
```

Docker:

```bash
docker compose config
docker compose build
```

Windows batch:

```bat
install.bat
run.bat
```

### 13.3 Testes unitários ou automatizados de contrato

Quando o projeto possuir suíte de testes, deve existir teste automatizado para validar o contrato de bootstrap, por exemplo:

```text
tests/bootstrap/
tests/unit/test_bootstrap_contract.*
tests/Feature/BootstrapContractTest.*
```

Esse teste deve verificar, no mínimo:

1. arquivos obrigatórios existem;
2. comandos canônicos estão documentados;
3. scripts esperados existem no manifesto da stack;
4. `package.json` tem scripts obrigatórios quando Node;
5. `pyproject.toml` ou `requirements.txt` existe quando Python;
6. `composer.json` existe quando PHP;
7. `Dockerfile`, `docker-compose.yml` e `Makefile` existem ou exceção formal existe;
8. README menciona instalação, execução e testes.

O teste não precisa executar uma instalação pesada dentro de unit test, mas deve validar a presença e coerência do contrato. A instalação real deve ser validada por comando de patch, CI, smoke test ou `make install`.

---

## 14. Rotina obrigatória em todo patch

Todo patch deve executar a rotina ISO/3.0:

1. identificar stack principal;
2. identificar stacks secundárias;
3. verificar `Dockerfile`;
4. verificar `docker-compose.yml`;
5. verificar `Makefile`;
6. verificar scripts de instalação;
7. verificar scripts de execução;
8. verificar scripts de teste;
9. verificar `install.bat` e `run.bat` quando ISO/2.1 se aplicar;
10. verificar README com comandos atualizados;
11. verificar AGENTS com instruções ISO/3.0;
12. executar comandos mínimos possíveis;
13. registrar comandos executados em `PATCH_NOTES.md`;
14. registrar comandos não executados com justificativa;
15. atualizar documentação se o patch alterou instalação, execução, stack, dependência ou boot.

Nenhum patch deve ser considerado completo se a rotina acima não foi executada ou justificada.

---

## 15. Rotina de adoção inicial

Se o projeto ainda não possuir UBU-ISO/3.0, o próximo patch deve:

1. criar `docs/UBU-ISO-3.0-INICIALIZADORES-E-BOOTSTRAP.md`;
2. criar ou atualizar `Dockerfile`;
3. criar ou atualizar `docker-compose.yml`;
4. criar ou atualizar `Makefile`;
5. criar ou atualizar `.dockerignore`;
6. criar ou atualizar `.env.example` quando aplicável;
7. criar scripts auxiliares mínimos quando aplicável;
8. criar teste de contrato de bootstrap quando houver suíte de testes;
9. atualizar README com seção de instalação, execução, Docker, Makefile e testes;
10. atualizar AGENTS com instruções ISO/3.0;
11. atualizar patch notes;
12. criar `docs/ISO_EXCEPTIONS.md` se alguma exigência não puder ser cumprida.

Mensagem obrigatória ao final do patch:

```text
UBU-ISO/3.0 foi adicionada pela primeira vez.
```

---

## 16. Rotina de verificação de conformidade

Se o projeto já possuir UBU-ISO/3.0, o patch deve:

1. ler a ISO existente;
2. verificar se inicializadores continuam coerentes;
3. verificar se nova alteração afetou instalação;
4. verificar se nova alteração afetou execução;
5. verificar se nova alteração afetou Docker;
6. verificar se nova alteração afetou Makefile;
7. verificar se nova alteração afetou testes;
8. atualizar apenas o necessário;
9. versionar documentação apenas se houver alteração real;
10. registrar resultado no patch notes.

Mensagem obrigatória ao final do patch:

```text
UBU-ISO/3.0 já existia; foi executada verificação de conformidade.
```

---

## 17. Política de exceções

Exceções são permitidas, mas devem ser raras e documentadas.

Arquivo obrigatório:

```text
docs/ISO_EXCEPTIONS.md
```

Template:

```markdown
## Exceção ISO/3.0 — YYYY-MM-DD

### Exigência não cumprida
- Dockerfile | docker-compose.yml | Makefile | script | teste | outro

### Motivo
Explique por que a exigência não pode ser cumprida agora.

### Risco
Explique impacto para instalação, execução, teste ou manutenção.

### Alternativa temporária
Explique como executar enquanto a exceção existir.

### Critério de remoção
Explique o que precisa acontecer para remover a exceção.

### Responsável/agente
Nome ou identificador.
```

Exceções não podem ser usadas para esconder negligência documental.

---

## 18. Regras para agentes de IA

Agentes devem seguir estas regras:

1. nunca aplicar patch sem verificar bootstrap;
2. nunca criar Dockerfile fictício sem testar ou declarar pendência;
3. nunca criar Makefile com targets que chamam comandos inexistentes;
4. nunca declarar `npm install`, `pip install`, `composer install` ou `docker compose build` como executados sem execução real;
5. se o ambiente não permitir execução, registrar como `não executado` com justificativa;
6. sempre atualizar README quando comandos mudarem;
7. sempre atualizar AGENTS quando norma ou rotina de patch mudar;
8. sempre criar exceção formal quando uma exigência obrigatória não puder ser cumprida;
9. preferir comandos simples e previsíveis;
10. evitar automação mágica que esconda erros.

---

## 19. Critérios de aceite

Um patch compatível com UBU-ISO/3.0 só é aceito se:

```text
- stack principal foi identificada;
- comandos canônicos foram verificados;
- Dockerfile existe ou exceção formal existe;
- docker-compose.yml existe ou exceção formal existe;
- Makefile existe ou exceção formal existe;
- README documenta instalação, execução e testes;
- AGENTS instrui agentes a validar bootstrap em todo patch;
- patch notes registram comandos executados;
- testes não executados têm justificativa;
- scripts de boot não ficaram quebrados após alteração;
- mudanças de dependências atualizaram inicializadores;
- projetos Node continuam instaláveis via npm ou exceção formal;
- projetos Python continuam instaláveis via pip ou exceção formal;
- projetos PHP continuam instaláveis via Composer/Artisan ou exceção formal;
- dependências apt/pacman estão documentadas quando aplicável.
```

---

## 20. Documentos relacionados

- [UBU-ISO/1.0 — Dados e Camadas](../ISO-1.0/UBU-ISO-1.0-DADOS-CAMADAS.md)
- [UBU-ISO/2.0 — Documentação Técnica](../ISO-2.0/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md)
- [UBU-ISO/2.1 — Instalação BAT](../ISO-2.1/UBU-ISO-2.1-INSTALACAO-BAT.md)
- [Checklist ISO/3.0](CHECKLIST-ISO-3.0.md)
- [Template de Makefile](TEMPLATE-MAKEFILE.md)
- [Template de Dockerfile](TEMPLATE-DOCKERFILE.md)
- [Template de docker-compose.yml](TEMPLATE-DOCKER-COMPOSE.md)
- [Prompt mestre de aplicação](../PROMPT_MESTRE_APLICAR_UBU_ISOS.md)
- [Instruções para agentes](../AGENTS_UBU_ISO_PADRAO.md)

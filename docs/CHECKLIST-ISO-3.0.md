# Checklist — UBU-ISO/3.0

Use em todo patch que altere código, dependências, instalação, execução, build, Docker, testes ou documentação operacional.

---

## 1. Classificação de stack

- [ ] Stack principal identificada
- [ ] Stacks secundárias identificadas
- [ ] Monorepo identificado, se aplicável
- [ ] Gerenciador de pacotes confirmado
- [ ] Dependências de sistema identificadas

---

## 2. Arquivos obrigatórios

- [ ] `Dockerfile` existe ou exceção formal existe
- [ ] `docker-compose.yml` existe ou exceção formal existe
- [ ] `Makefile` existe ou exceção formal existe
- [ ] `.dockerignore` existe quando Docker é usado
- [ ] `.env.example` existe quando variáveis de ambiente são usadas
- [ ] `README.md` documenta instalação, execução e testes
- [ ] `AGENTS.md` instrui agentes a aplicar ISO/3.0

---

## 3. Comandos canônicos

- [ ] `make help`
- [ ] `make install`
- [ ] `make update`
- [ ] `make run`
- [ ] `make test`
- [ ] `make build`
- [ ] `make doctor`
- [ ] `make clean`

---

## 4. Validação por stack

### Node

- [ ] `npm install` ou `npm ci`
- [ ] `npm test`
- [ ] `npm run build`
- [ ] `npm start` ou equivalente documentado

### Python

- [ ] `python -m pip install -e .` ou `python -m pip install -r requirements.txt`
- [ ] `python -m pytest`
- [ ] `python -m compileall .`
- [ ] CLI validada com `--help`, se aplicável

### PHP/Laravel

- [ ] `composer install`
- [ ] `php artisan config:clear`
- [ ] `php artisan route:list`
- [ ] `php artisan test`
- [ ] `npm run build`, se houver frontend

### Docker

- [ ] `docker compose config`
- [ ] `docker compose build`
- [ ] `docker compose up --build` documentado

### Windows BAT

- [ ] `install.bat` conforme ISO/2.1, se aplicável
- [ ] `run.bat` conforme ISO/2.1, se aplicável

---

## 5. Teste de contrato de bootstrap

- [ ] Existe teste automatizado de contrato ou pendência justificada
- [ ] Teste verifica arquivos obrigatórios
- [ ] Teste verifica comandos documentados
- [ ] Teste verifica scripts por stack
- [ ] Teste verifica README operacional

---

## 6. Patch notes

- [ ] Comandos executados registrados
- [ ] Comandos não executados justificados
- [ ] Mudanças em inicializadores listadas
- [ ] Riscos de instalação/boot documentados
- [ ] Exceções ISO registradas em `docs/ISO_EXCEPTIONS.md`, se existirem

---

## 7. Critério final

- [ ] Instalação continua reproduzível
- [ ] Execução continua reproduzível
- [ ] Testes continuam reproduzíveis
- [ ] Docker/Makefile/scripts não ficaram obsoletos
- [ ] Documentação operacional acompanha o patch

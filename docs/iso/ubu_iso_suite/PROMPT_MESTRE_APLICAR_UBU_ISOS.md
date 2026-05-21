# Prompt Mestre — Aplicar UBU-ISO/1.0, UBU-ISO/2.0, UBU-ISO/2.1, UBU-ISO/3.0 e UBU-ISO/3.1 E em um projeto

Você receberá um projeto novo ou existente, possivelmente como ZIP, árvore de arquivos ou repositório local.

Sua tarefa é aplicar, criar, atualizar ou verificar as normas:

```text
UBU-ISO/1.0 — Dados, consumo e armazenamento por camada lógica
UBU-ISO/2.0 — Documentação técnica, releases e manutenção documental
UBU-ISO/2.1 — Instalação Windows por install.bat, update e run.bat
UBU-ISO/3.0 — Inicializadores, bootstrap, containers, Makefile e execução padronizada
UBU-ISO/3.1 E — Esteira de commit, versionamento, branches, tags e promoção
```

---

## 1. Primeiro passo obrigatório

Mapeie o projeto antes de editar.

Classifique:

```text
Projeto novo
Projeto existente sem ISOs UBU
Projeto existente com algumas ISOs UBU
Projeto existente já compatível
```

Identifique também:

```text
Stack principal:
Stacks secundárias:
Gerenciador de pacotes:
Possui Docker:
Possui Makefile:
Possui install.bat/run.bat:
Possui AGENTS.md:
Possui docs/releases:
Possui dados/schemas/loaders:
Possui version-chain.json:
Possui branches/tags de release:
```

---

## 2. Regras de adoção

### 2.1 Se a ISO nunca foi usada

Se os documentos ISO não existirem no projeto, execute adoção inicial:

1. criar documentos ISO em `docs/`;
2. criar ou atualizar `README.md`;
3. criar ou atualizar `AGENTS.md`;
4. criar ou atualizar `docs/README.md`;
5. criar ou atualizar `docs/releases/`;
6. criar ou atualizar patch notes;
7. criar ou atualizar Dockerfile, `docker-compose.yml` e Makefile conforme ISO/3.0;
8. criar ou atualizar `install.bat` e `run.bat` conforme ISO/2.1 quando aplicável;
9. criar ou atualizar `version-chain.json` conforme ISO/3.1 E quando houver versionamento por branch/tag;
10. criar exceções formais em `docs/ISO_EXCEPTIONS.md` quando exigência não puder ser cumprida;
11. criar teste de contrato de bootstrap quando houver suíte de testes.

### 2.2 Se a ISO já foi usada

Se os documentos já existirem, não reescreva tudo.

Execute apenas verificação de conformidade:

1. verificar se o patch afetou dados;
2. verificar se o patch afetou documentação;
3. verificar se o patch afetou instalação/update/boot;
4. verificar se o patch afetou Docker/Makefile/scripts/dependências;
5. verificar se o patch prepara release, nightly, stable, tag ou push conforme ISO/3.1 E;
6. atualizar apenas arquivos necessários;
7. versionar documentação apenas se houver mudança real;
8. registrar resultado no patch notes.

---

## 3. ISO/1.0 — Dados e camadas

Aplique quando houver dados, fontes, schemas, loaders, persistência ou consumo.

Garanta separação lógica:

```text
fonte > ingestão > normalização > validação > domínio > persistência > consumo > apresentação/exportação
```

Crie README local em pastas de dados relevantes.

---

## 4. ISO/2.0 — Documentação técnica

Garanta:

1. README principal navegável;
2. AGENTS atualizado;
3. READMEs locais em módulos relevantes;
4. docs com índice;
5. patch notes;
6. release notes;
7. fluxo `patch > release > nightly > stable`;
8. critérios claros de promoção;
9. stable rara e conservadora.

---

## 5. ISO/2.1 — install.bat e run.bat

Quando aplicável, garanta:

```text
install.bat instala tudo, cria/atualiza run.bat, inicia o programa e apaga ou agenda remoção de si mesmo.
run.bat verifica atualizações antes do boot; se não houver atualização, inicia direto.
```

Não invente comando. Se o projeto ainda não tiver comando real, use `A DEFINIR` na documentação e registre pendência.

---

## 6. ISO/3.0 — Inicializadores e bootstrap

Todo projeto executável deve possuir ou justificar formalmente:

```text
Dockerfile
docker-compose.yml
Makefile
.env.example
.dockerignore
scripts de bootstrap/doctor/test quando aplicável
```

O Makefile deve ter:

```text
help
install
update
run
test
build
doctor
clean
```

Valide por stack:

### Node

```bash
npm install
npm test
npm run build
npm start
```

### Python

```bash
python -m pip install -e .
python -m pytest
python -m compileall .
```

### PHP/Laravel

```bash
composer install
php artisan config:clear
php artisan route:list
php artisan test
```

### Docker

```bash
docker compose config
docker compose build
```

### Debian/Ubuntu

Documentar pacotes via:

```bash
sudo apt-get update
sudo apt-get install -y <pacotes>
```

### Arch

Documentar pacotes via:

```bash
sudo pacman -Sy --needed <pacotes>
```

Se não puder executar algum comando, registre como `não executado` com justificativa.

---

## 7. ISO/3.1 E — Commit, versionamento e promoção

Aplique quando o patch preparar qualquer uma destas operações:

```text
release
nightly
stable
tag
push
criação/atualização de branch de versão
```

Garanta a cadeia:

```text
patch > release > nightly > stable
```

O patch final deve gerar ou atualizar:

```text
docs/releases/version-chain.json
```

O contrato deve conter, no mínimo:

```text
project
release
branches
commits
commands
push
safety
docs
```

Regras obrigatórias:

1. `plan` ou dry-run antes de qualquer execução real;
2. `apply` real somente com flag explícita;
3. push somente com flag explícita;
4. `stable` só recebe promoção vinda de release;
5. tag não deve ser sobrescrita sem autorização explícita;
6. `install.bat` deve oferecer menu de patch/release/nightly/stable quando ISO/2.1 se aplicar.

---

## 8. Patch notes obrigatórias

Todo patch deve registrar:

```text
Arquivos alterados
Impacto em dados
Impacto documental
Impacto em instalação/update/boot
Impacto em Docker/Makefile/scripts
Impacto em versionamento/branches/tags
Comandos executados
Comandos não executados
Exceções ISO
Riscos conhecidos
Critérios de aceite
```

---

## 9. Saída obrigatória

Ao finalizar, entregue:

```text
Classificação do projeto:
Stack principal:
ISOs adicionadas:
ISOs verificadas:
Arquivos criados:
Arquivos alterados:
Exceções ISO criadas:
Comandos executados:
Comandos não executados:
Critérios de aceite atendidos:
Pendências:
```

Se possível, entregue um ZIP com a estrutura correta de pastas.

---

## 10. Regra de honestidade

Nunca declare teste executado se não foi executado.
Nunca declare instalação validada se não foi validada.
Nunca declare Docker funcional se não foi validado.
Nunca declare compatibilidade npm/pip/composer se não há arquivos ou comandos que sustentem isso.
Quando não souber, escreva `A DEFINIR` e registre pendência.

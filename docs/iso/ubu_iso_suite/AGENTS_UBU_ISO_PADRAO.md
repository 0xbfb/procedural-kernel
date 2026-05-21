# AGENTS — Padrão obrigatório para projetos UBU compatíveis com ISO/1.0, ISO/2.0, ISO/2.1, ISO/3.0 e ISO/3.1 E

> Este documento deve ser copiado ou incorporado ao `AGENTS.md` de cada projeto UBU. Ele define como agentes humanos ou de IA devem aplicar as normas em todo patch.

---

## Índice

- [1. Leitura obrigatória](#1-leitura-obrigatória)
- [2. Regra geral](#2-regra-geral)
- [3. Rotina obrigatória em todo patch](#3-rotina-obrigatória-em-todo-patch)
- [4. ISO/1.0 — Dados e camadas](#4-iso10--dados-e-camadas)
- [5. ISO/2.0 — Documentação técnica](#5-iso20--documentação-técnica)
- [6. ISO/2.1 — Instalação BAT](#6-iso21--instalação-bat)
- [7. ISO/3.0 — Inicializadores e bootstrap](#7-iso30--inicializadores-e-bootstrap)
- [8. ISO/3.1 E — Versionamento e promoção](#8-iso31-e--versionamento-e-promoção)
- [9. Patch notes obrigatórias](#9-patch-notes-obrigatórias)
- [10. Proibições](#10-proibições)
- [11. Saída obrigatória do agente](#11-saída-obrigatória-do-agente)

---

## 1. Leitura obrigatória

Antes de alterar qualquer projeto UBU, leia:

```text
docs/UBU-ISO-1.0-DADOS-CAMADAS.md
docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md
docs/UBU-ISO-2.1-INSTALACAO-BAT.md
docs/UBU-ISO-3.0-INICIALIZADORES-E-BOOTSTRAP.md
docs/UBU-ISO-3.1E-COMMIT-VERSIONAMENTO.md
```

Se os documentos ainda não existirem no projeto, aplique a rotina de adoção inicial correspondente.

---

## 2. Regra geral

Todo patch deve ser tratado como alteração de produto, documentação e operação.

O agente deve sempre perguntar internamente:

1. alterei dados, schemas, loaders ou persistência?
2. alterei documentação, README, release notes ou patch notes?
3. alterei instalação, update, `install.bat` ou `run.bat`?
4. alterei bootstrap, Docker, Makefile, scripts, comandos ou dependências?
5. estou preparando release, nightly, stable, tag ou push?
6. preciso criar ou atualizar exceção ISO?

Se a resposta for sim, aplique a ISO correspondente.

---

## 3. Rotina obrigatória em todo patch

1. Identificar stack principal e secundária.
2. Verificar se ISOs estão presentes.
3. Se alguma ISO obrigatória não existir, aplicar adoção inicial.
4. Verificar impacto em dados conforme ISO/1.0.
5. Verificar impacto documental conforme ISO/2.0.
6. Verificar instalação Windows conforme ISO/2.1, quando aplicável.
7. Verificar inicializadores conforme ISO/3.0.
8. Verificar versionamento/branches/tags conforme ISO/3.1 E quando houver promoção de versão.
9. Executar testes possíveis.
10. Registrar testes executados e não executados.
11. Atualizar patch notes.
12. Atualizar README/AGENTS se comandos ou regras mudarem.
13. Gerar resumo final do patch.

---

## 4. ISO/1.0 — Dados e camadas

Aplique quando o patch alterar:

- dados;
- schemas;
- seeds;
- fixtures;
- loaders;
- exports;
- persistência;
- contratos entre camadas;
- fontes externas.

O agente deve preservar separação entre:

```text
fonte > ingestão > normalização > validação > domínio > persistência > consumo > apresentação/exportação
```

---

## 5. ISO/2.0 — Documentação técnica

Aplique em todo patch.

O agente deve garantir:

- README principal coerente;
- READMEs locais quando necessário;
- índices em documentos longos;
- patch notes em toda alteração;
- release notes quando consolidar release;
- fluxo `patch > release > nightly > stable` respeitado;
- stable alterada raramente e apenas com justificativa.

---

## 6. ISO/2.1 — Instalação BAT

Aplique quando o projeto suportar Windows, usuário final não técnico, CLI, jogo, app local ou instalação simplificada.

Contrato:

```text
install.bat instala tudo, cria/atualiza run.bat, inicia o programa e remove ou agenda remoção do install.bat.
run.bat verifica atualizações primeiro; se não houver atualização, inicia direto.
```

Se não for aplicável, registrar exceção ou justificativa documental.

---

## 7. ISO/3.0 — Inicializadores e bootstrap

Aplique em todo patch que altere código, dependências, execução, build, testes, Docker, scripts ou documentação operacional.

Arquivos obrigatórios na raiz, salvo exceção formal:

```text
Dockerfile
docker-compose.yml
Makefile
README.md
AGENTS.md
```

Arquivos recomendados quando aplicável:

```text
install.bat
run.bat
.env.example
.dockerignore
scripts/bootstrap.sh
scripts/bootstrap.bat
scripts/doctor.sh
scripts/doctor.bat
scripts/test-bootstrap.sh
scripts/test-bootstrap.bat
```

Targets obrigatórios do Makefile:

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

O agente deve validar a stack:

- Node: `npm install`, `npm test`, `npm run build`, `npm start`.
- Python: `python -m pip install -e .`, `python -m pytest`, `python -m compileall .`.
- PHP/Laravel: `composer install`, `php artisan config:clear`, `php artisan route:list`, `php artisan test`.
- Docker: `docker compose config`, `docker compose build`.
- Debian/Ubuntu: pacotes documentados via `apt`.
- Arch: pacotes documentados via `pacman`.

Se não puder executar, registrar no patch notes como não executado com justificativa.

---

## 8. ISO/3.1 E — Versionamento e promoção

Aplique quando o patch preparar release, nightly, stable, tag, push ou atualização de branch versionada.

O agente deve garantir:

- cadeia `patch > release > nightly > stable`;
- `docs/releases/version-chain.json` quando fechar versão;
- `plan` ou dry-run antes de execução real;
- push somente com autorização explícita;
- tag previsível no formato `v{version}` por padrão;
- `stable` não recebendo patch direto;
- instalador com menu de canal/branch quando ISO/2.1 se aplicar.

## 9. Patch notes obrigatórias

Toda alteração deve registrar em `docs/releases/PATCH_NOTES.md`:

- versão do patch;
- data;
- tipo;
- resumo;
- arquivos alterados;
- impacto técnico;
- impacto documental;
- impacto em instalação/execução;
- comandos executados;
- comandos não executados e motivo;
- riscos conhecidos;
- critérios de aceite.

---

## 10. Proibições

É proibido:

1. inventar teste executado;
2. criar README que prometa comando inexistente;
3. criar Dockerfile quebrado sem exceção;
4. criar Makefile com targets falsos;
5. esconder breaking change;
6. promover release sem notas;
7. alterar stable como se fosse branch de trabalho;
8. ignorar `install.bat`/`run.bat` quando ISO/2.1 se aplicar;
9. ignorar Dockerfile/compose/Makefile quando ISO/3.0 se aplicar;
10. promover release/nightly/stable sem `version-chain.json` quando ISO/3.1 E se aplicar;
11. remover documentação útil sem substituir por equivalente melhor.

---

## 11. Saída obrigatória do agente

Ao final de cada patch, informe:

```text
Classificação do projeto:
ISOs aplicadas:
Arquivos criados:
Arquivos alterados:
Comandos executados:
Comandos não executados:
Exceções ISO:
Impacto em versionamento/branches/tags:
Riscos conhecidos:
Critérios de aceite:
Próximo passo recomendado:
```

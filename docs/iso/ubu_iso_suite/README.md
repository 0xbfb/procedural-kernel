# UBU ISO Suite — ISO/1.0, ISO/2.0, ISO/2.1, ISO/3.0 e ISO/3.1 E

> Pacote de normas internas UBU para padronização de dados, documentação técnica, releases, instalação Windows por `.bat`, inicializadores, Docker, Makefile e bootstrap por stack.

---

## Índice

- [1. Conteúdo do pacote](#1-conteúdo-do-pacote)
- [2. Resumo das ISOs](#2-resumo-das-isos)
- [3. Como aplicar em um projeto](#3-como-aplicar-em-um-projeto)
- [4. Regra de adoção](#4-regra-de-adoção)
- [5. Arquivos principais](#5-arquivos-principais)

---

## 1. Conteúdo do pacote

```text
ISO-1.0/
  UBU-ISO-1.0-DADOS-CAMADAS.md
  CHECKLIST-ISO-1.0.md
  TEMPLATE-README-DADOS.md

ISO-2.0/
  UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md
  CHECKLIST-ISO-2.0.md
  TEMPLATE-PATCH-NOTES.md
  TEMPLATE-RELEASE-NOTES.md

ISO-2.1/
  UBU-ISO-2.1-INSTALACAO-BAT.md
  CHECKLIST-ISO-2.1.md
  TEMPLATE-INSTALL-BAT.md
  TEMPLATE-RUN-BAT.md

ISO-3.0/
  UBU-ISO-3.0-INICIALIZADORES-E-BOOTSTRAP.md
  CHECKLIST-ISO-3.0.md
  MATRIZ-COMANDOS-POR-STACK.md
  TEMPLATE-MAKEFILE.md
  TEMPLATE-DOCKERFILE.md
  TEMPLATE-DOCKER-COMPOSE.md
  TEMPLATE-BOOTSTRAP-CONTRACT-TEST.md
  TEMPLATE-ISO-EXCEPTIONS.md

ISO-3.1E/
  UBU-ISO-3.1E-COMMIT-VERSIONAMENTO.md
  CHECKLIST-ISO-3.1E.md
  TEMPLATE-VERSION-CHAIN-JSON.md
  TEMPLATE-INSTALL-MENU-BAT.md
  MATRIZ-BRANCHES-TAGS.md
  PROMPT_FINAL_PATCH_VERSION_CHAIN.md

AGENTS_UBU_ISO_PADRAO.md
PROMPT_MESTRE_APLICAR_UBU_ISOS.md
ESTRUTURA_RECOMENDADA_NO_PROJETO.md
```

---

## 2. Resumo das ISOs

| ISO | Tema | Uso obrigatório |
|---|---|---|
| UBU-ISO/1.0 | Dados, consumo e armazenamento por camada lógica | Quando houver dados, schemas, loaders, persistência ou consumo |
| UBU-ISO/2.0 | Documentação técnica, patch notes, release notes e fluxo de versões | Em todo projeto e todo patch |
| UBU-ISO/2.1 | `install.bat`, `run.bat`, update e boot automático no Windows | Quando o projeto precisa instalação simples para usuário final/Windows |
| UBU-ISO/3.0 | Dockerfile, docker-compose, Makefile, bootstrap, comandos por stack e validação operacional | Em todo projeto executável ou instalável |
| UBU-ISO/3.1 E | Esteira de commit, versionamento, branches, tags e promoção `patch > release > nightly > stable` | Quando o projeto publica versões por branch/tag |

---

## 3. Como aplicar em um projeto

Use o arquivo:

```text
PROMPT_MESTRE_APLICAR_UBU_ISOS.md
```

Ele instrui o agente a:

1. classificar o projeto;
2. detectar stack;
3. aplicar adoção inicial se a ISO nunca foi usada;
4. verificar conformidade se a ISO já existe;
5. criar ou atualizar documentação;
6. criar ou atualizar inicializadores;
7. registrar patch notes;
8. declarar exceções formais quando necessário.

---

## 4. Regra de adoção

Se o projeto nunca usou as ISOs, o próximo patch deve criar a estrutura documental e operacional mínima.

Se o projeto já usou, o patch deve apenas verificar conformidade e atualizar o que foi afetado.

---

## 5. Arquivos principais

Para orientar agentes, copie ou incorpore:

```text
AGENTS_UBU_ISO_PADRAO.md
```

Para entender a estrutura esperada, leia:

```text
ESTRUTURA_RECOMENDADA_NO_PROJETO.md
```

Para aplicar tudo em um projeto, use:

```text
PROMPT_MESTRE_APLICAR_UBU_ISOS.md
```

---

## 6. Projeto de referência ISO/3.1 E

O kit inclui o projeto:

```text
projetos/ubu-version-governor/
```

Ele implementa a cadeia `patch > release > nightly > stable` consumindo `version-chain.json`, com `plan`, `validate`, `doctor` e `apply`. O instalador `install.bat` possui menu para escolher patch, release, nightly, stable ou branch customizada e redirecionar para a branch correspondente quando o diretório for um clone Git.

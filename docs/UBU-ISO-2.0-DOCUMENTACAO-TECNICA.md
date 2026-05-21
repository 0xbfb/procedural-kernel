# UBU-ISO/2.0 — Documentação Técnica, Releases e Manutenção Documental

> Norma interna UBU para padronização de documentação técnica, READMEs, patch notes, release notes, fluxo de branches e critérios de promoção de versão.

---

## Índice

- [Identidade da norma](#identidade-da-norma)
- [Objetivo](#objetivo)
- [Regras absolutas](#regras-absolutas)
- [Hierarquia documental obrigatória](#hierarquia-documental-obrigatória)
- [README principal](#readme-principal)
- [README local](#readme-local)
- [Índices remissivos](#índices-remissivos)
- [Fluxo de branches](#fluxo-de-branches)
- [Critérios de promoção](#critérios-de-promoção)
- [Patch notes](#patch-notes)
- [Release notes](#release-notes)
- [Nightly notes](#nightly-notes)
- [Stable notes](#stable-notes)
- [Regra de raridade da stable](#regra-de-raridade-da-stable)
- [Rotina de adoção inicial](#rotina-de-adoção-inicial)
- [Rotina de verificação de conformidade](#rotina-de-verificação-de-conformidade)
- [Checklist de aceite](#checklist-de-aceite)
- [Documentos relacionados](#documentos-relacionados)

---

## Identidade da norma

```text
Nome: UBU-ISO/2.0
Tema: Documentação técnica, releases e manutenção documental
Versão da norma: 2.0
Status: obrigatório para projetos UBU compatíveis
Escopo: README, AGENTS, docs, patch notes, release notes, branch flow, tags e documentação de módulos
```

---

## Objetivo

A UBU-ISO/2.0 torna documentação parte obrigatória do produto.

Todo projeto compatível deve permitir que um mantenedor entenda:

1. o que o projeto faz;
2. como instalar;
3. como executar;
4. como testar;
5. onde ficam os módulos;
6. como os módulos conversam;
7. como versionar mudanças;
8. como promover patch para release;
9. como promover release para nightly;
10. como promover nightly para stable;
11. quais riscos existem;
12. quais documentos devem ser lidos antes de alterar cada parte.

---

## Regras absolutas

1. Patch sem patch notes é incompleto.
2. Release sem release notes é incompleta.
3. Stable deve mudar raramente.
4. Nightly não é stable.
5. README principal deve orientar entrada no projeto.
6. README local deve orientar manutenção de módulo.
7. Documento técnico com mais de 80 linhas deve ter índice.
8. Documentação não pode prometer funcionalidade inexistente.
9. Teste não executado deve ser marcado como não executado.
10. Breaking change deve ser explícita.
11. Agentes devem atualizar documentação junto do código.
12. Documentação antiga contraditória deve ser atualizada ou marcada como obsoleta.

---

## Hierarquia documental obrigatória

Estrutura mínima:

```text
README.md
AGENTS.md
docs/
  README.md
  UBU-ISO-1.0-DADOS-CAMADAS.md
  UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md
  UBU-ISO-2.1-INSTALACAO-BAT.md
  releases/
    README.md
    PATCH_NOTES.md
    RELEASE_NOTES.md
    NIGHTLY_NOTES.md
    STABLE_NOTES.md
```

Módulos relevantes devem ter README local.

Exemplos:

```text
src/engine/README.md
src/data/README.md
src/installer/README.md
app/Services/AutoPix/README.md
packages/renderer/README.md
```

---

## README principal

O `README.md` raiz deve conter:

```markdown
## Índice
## Visão geral
## Instalação
## Execução
## Testes
## Arquitetura
## Estrutura de pastas
## Fluxo de versões
## Documentação técnica
## Contribuição
## Documentos relacionados
```

Deve responder:

1. o que é o projeto;
2. qual problema resolve;
3. como instalar;
4. como rodar;
5. como testar;
6. como gerar build;
7. qual arquitetura usa;
8. quais módulos principais existem;
9. onde ficam docs detalhadas;
10. qual fluxo de branch segue;
11. como aplicar patch sem quebrar documentação.

---

## README local

Um README local é obrigatório quando a pasta:

1. possui mais de 8 arquivos de código;
2. possui regra de negócio relevante;
3. possui integração externa;
4. possui dados ou schemas;
5. possui comandos de instalação/build/teste;
6. é consumida por mais de um módulo;
7. representa engine, dados ou instalador;
8. contém lógica difícil de inferir só pelo código.

Template mínimo:

```markdown
## Índice
## Responsabilidade
## Estrutura
## Fluxos principais
## Integrações
## Testes
## Riscos de manutenção
## Documentos relacionados
```

---

## Índices remissivos

Todo documento técnico com mais de 80 linhas deve conter índice com links internos.

Quando aplicável, também deve conter links para:

1. documento superior;
2. documentos irmãos;
3. docs de release;
4. ISOs;
5. projetos paralelos.

Exemplo:

```markdown
## Documentos relacionados

- [README principal](../README.md)
- [Docs](./README.md)
- [UBU-ISO/1.0](./UBU-ISO-1.0-DADOS-CAMADAS.md)
- [UBU-ISO/2.0](./UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md)
- [UBU-ISO/2.1](./UBU-ISO-2.1-INSTALACAO-BAT.md)
- [Patch notes](./releases/PATCH_NOTES.md)
```

---

## Fluxo de branches

Todo projeto UBU compatível deve seguir o fluxo:

```text
patch > release > nightly > stable
```

### patch

Branch de alterações pontuais.

Pode conter:

- bugfix;
- docs;
- refactor localizada;
- teste;
- ajuste de build;
- melhoria pequena;
- preparação de release.

Não pode conter mudança sem patch notes.

### release

Branch de conjunto coerente de patches.

Critério padrão:

```text
mínimo recomendado: 3 patches relevantes
ideal comum: 3 a 7 patches
exceção: 1 patch crítico pode gerar release emergencial
```

### nightly

Branch de bundle de releases para validação ampla.

Critério padrão:

```text
mínimo recomendado: 2 releases bem-sucedidas
ideal comum: 2 a 4 releases
exceção: release crítica amplamente testada pode subir sozinha
```

### stable

Branch de versão confiável recomendada.

Critério padrão:

```text
mínimo recomendado: 2 nightlies validadas
ideal comum: 2 a 3 nightlies sem regressão crítica
exceção: correção crítica de segurança, dados ou execução
```

---

## Critérios de promoção

### patch para release

Exige:

- patch notes completas;
- escopo coerente;
- testes ou justificativa;
- documentação atualizada;
- riscos conhecidos documentados.

### release para nightly

Exige:

- release notes completas;
- releases suficientes ou exceção justificada;
- testes integrados;
- instalação validada quando aplicável;
- documentação navegável.

### nightly para stable

Exige:

- stable notes completas;
- ausência de regressão crítica conhecida;
- execução limpa;
- build validada;
- docs finais revisadas;
- tag semântica preparada;
- rollback ou mitigação documentada quando aplicável.

---

## Patch notes

Todo patch deve atualizar:

```text
docs/releases/PATCH_NOTES.md
```

Formato obrigatório resumido:

```markdown
## Patch X.Y.Z — YYYY-MM-DD

### Tipo
bugfix | docs | refactor | feature-small | test | build | chore | security | data | installer

### Resumo

### Arquivos alterados

### Mudanças realizadas

### Impacto técnico

### Impacto para usuário

### Testes/checks executados

### Testes/checks não executados

### Riscos conhecidos

### Documentação atualizada

### Critério de aceite
```

---

## Release notes

Toda release deve atualizar:

```text
docs/releases/RELEASE_NOTES.md
```

Deve conter:

- status;
- objetivo;
- patches incluídos;
- novidades;
- correções;
- alterações técnicas;
- alterações documentais;
- breaking changes;
- guia de atualização;
- testes;
- riscos;
- critérios para nightly.

---

## Nightly notes

Toda promoção para nightly deve atualizar:

```text
docs/releases/NIGHTLY_NOTES.md
```

Deve conter:

- releases incluídas;
- objetivo da nightly;
- validações obrigatórias;
- riscos monitorados;
- resultado;
- critérios para stable.

---

## Stable notes

Toda promoção para stable deve atualizar:

```text
docs/releases/STABLE_NOTES.md
```

Deve conter:

- nightly de origem;
- releases incluídas;
- patches incluídos;
- tag stable;
- principais mudanças desde a stable anterior;
- validações finais;
- riscos aceitos;
- instruções de instalação;
- instruções de atualização;
- observações para mantenedores.

---

## Regra de raridade da stable

Stable não é branch de trabalho.

Stable não é release candidate.

Stable não é nightly.

Stable é a versão confiável recomendada.

Stable só deve mudar quando:

1. há acúmulo real de valor;
2. nightly validou o bundle;
3. testes e execução foram verificados;
4. documentação está completa;
5. riscos estão aceitos e registrados.

---

## Rotina de adoção inicial

Se o projeto nunca usou UBU-ISO/2.0:

1. criar `docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md`;
2. criar ou atualizar `README.md`;
3. criar ou atualizar `AGENTS.md`;
4. criar `docs/README.md`;
5. criar `docs/releases/`;
6. criar arquivos de notes;
7. identificar READMEs locais necessários;
8. registrar adoção em patch notes.

---

## Rotina de verificação de conformidade

Se o projeto já usa UBU-ISO/2.0:

1. verificar documentação existente;
2. checar READMEs locais;
3. checar patch notes;
4. checar release notes;
5. checar links internos;
6. atualizar apenas divergências reais;
7. registrar patch notes.

---

## Checklist de aceite

```markdown
- [ ] docs/UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md existe
- [ ] README.md aponta para docs
- [ ] AGENTS.md instrui agentes
- [ ] docs/README.md existe ou equivalente justificado
- [ ] docs/releases existe
- [ ] PATCH_NOTES.md existe
- [ ] RELEASE_NOTES.md existe
- [ ] NIGHTLY_NOTES.md existe
- [ ] STABLE_NOTES.md existe
- [ ] fluxo patch > release > nightly > stable documentado
- [ ] stable definida como rara
- [ ] READMEs locais avaliados
- [ ] patch notes atualizadas
```

---

## Documentos relacionados

- [UBU-ISO/1.0 — Dados](./UBU-ISO-1.0-DADOS-CAMADAS.md)
- [UBU-ISO/2.1 — Instalação BAT](./UBU-ISO-2.1-INSTALACAO-BAT.md)
- [Patch notes](./releases/PATCH_NOTES.md)
- [Release notes](./releases/RELEASE_NOTES.md)

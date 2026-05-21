# UBU-ISO/1.0 — Estrutura de Dados, Consumo e Armazenamento por Camada Lógica

> Norma interna UBU para organização de dados, contratos, loaders, persistência, consumo e armazenamento em projetos modulares.

---

## Índice

- [Identidade da norma](#identidade-da-norma)
- [Objetivo](#objetivo)
- [Princípios obrigatórios](#princípios-obrigatórios)
- [Camadas lógicas padronizadas](#camadas-lógicas-padronizadas)
- [Separação engine, dados e instalador](#separação-engine-dados-e-instalador)
- [Contrato mínimo de dados](#contrato-mínimo-de-dados)
- [Regras de consumo](#regras-de-consumo)
- [Regras de armazenamento](#regras-de-armazenamento)
- [Versionamento de dados](#versionamento-de-dados)
- [Documentação obrigatória](#documentação-obrigatória)
- [Rotina de adoção inicial](#rotina-de-adoção-inicial)
- [Rotina de verificação de conformidade](#rotina-de-verificação-de-conformidade)
- [Checklist de aceite](#checklist-de-aceite)
- [Documentos relacionados](#documentos-relacionados)

---

## Identidade da norma

```text
Nome: UBU-ISO/1.0
Tema: Estrutura de dados, consumo e armazenamento por camada lógica
Versão da norma: 1.0
Status: obrigatório para projetos UBU compatíveis
Escopo: dados estáticos, dados dinâmicos, schemas, loaders, adapters, persistência, exports, caches, fixtures e contratos de dados
```

---

## Objetivo

A UBU-ISO/1.0 define como um projeto deve declarar, consumir, transformar, persistir e documentar dados.

O objetivo é evitar que dados fiquem espalhados, implícitos, acoplados à engine ou difíceis de atualizar.

Todo projeto compatível deve deixar claro:

1. de onde o dado vem;
2. em qual formato ele entra;
3. qual camada valida o dado;
4. qual camada transforma o dado;
5. qual camada consome o dado;
6. onde o dado é persistido;
7. como o dado é versionado;
8. como o dado é auditado;
9. como outro módulo pode consumir esse dado sem quebrar isolamento.

---

## Princípios obrigatórios

1. Dados não devem depender de UI.
2. Dados não devem depender diretamente da engine, salvo contratos públicos documentados.
3. Engine consome contratos, não arquivos soltos.
4. Instalador instala, atualiza e localiza fontes de dados, mas não deve conter regra de domínio da engine.
5. Toda fonte de dados deve ter dono lógico.
6. Todo schema deve ser versionado.
7. Toda transformação deve ser rastreável.
8. Todo cache deve poder ser recriado.
9. Dados gerados devem declarar origem e versão.
10. Dados sensíveis ou locais não devem ser enviados para release por acidente.
11. Mudança de contrato de dados deve ser documentada em patch notes.
12. Quebra de compatibilidade de dados deve ser tratada como mudança de versão relevante.

---

## Camadas lógicas padronizadas

A norma define as seguintes camadas.

| Camada | Nome | Responsabilidade |
|---|---|---|
| L0 | Fonte | Arquivo, API, planilha, dump, input manual ou repositório externo original |
| L1 | Entrada bruta | Preservação do dado como recebido, com mínima alteração |
| L2 | Validação | Checagem de schema, tipos, campos obrigatórios e integridade |
| L3 | Normalização | Conversão para formato previsível do projeto |
| L4 | Domínio | Objetos ou estruturas canônicas consumidas pela lógica principal |
| L5 | Runtime | Dados carregados em memória, cache temporário ou estado de execução |
| L6 | Persistência | Banco, save, arquivo local, storage, índice ou cache persistente |
| L7 | Exportação | JSON, CSV, relatório, save exportado, pacote de dados ou build final |
| L8 | Auditoria | Logs, manifests, checksums, relatórios de validação e histórico |

Nenhuma camada deve pular responsabilidades críticas sem justificativa documentada.

---

## Separação engine, dados e instalador

Quando o projeto possuir arquitetura separada, a divisão deve ser explícita:

```text
engine/     lógica de execução, simulação, rendering, regras e runtime
data/       fontes, schemas, fixtures, conteúdo, manifests e pacotes de dados
installer/  instalação, atualização, bootstrap, seleção de fontes e launch
```

### Engine

A engine deve:

1. consumir dados por contratos estáveis;
2. não conhecer detalhes internos do instalador;
3. não editar fonte bruta diretamente;
4. validar compatibilidade de versão de dados antes de executar.

### Dados

O repositório ou pasta de dados deve:

1. declarar schemas;
2. declarar manifests;
3. declarar origem das fontes;
4. declarar status de implementação;
5. declarar versionamento;
6. conter README local;
7. conter validações automatizadas quando possível.

### Instalador

O instalador deve:

1. conhecer fontes disponíveis de dados;
2. conhecer engines disponíveis;
3. baixar ou atualizar pacotes;
4. preparar ambiente;
5. chamar a engine;
6. não implementar regra de domínio;
7. registrar logs de instalação e update.

---

## Contrato mínimo de dados

Todo conjunto de dados relevante deve possuir um manifesto ou documentação equivalente contendo:

```yaml
id: exemplo
name: Nome legível
version: 0.1.0
schema_version: 1
owner_layer: data
status: planned | draft | playable | active | deprecated | archived
source:
  type: local | api | generated | external | manual
  path_or_url: caminho ou URL
compatibility:
  engine_min: 0.1.0
  engine_max: null
validation:
  command: comando de validação ou A DEFINIR
exports:
  - formato
notes: observações
```

Se não houver manifesto formal, o README local deve conter essas informações.

---

## Regras de consumo

1. Nenhum módulo deve ler dados brutos diretamente se existir camada normalizada.
2. A engine deve preferir loaders/adapters documentados.
3. UI não deve acessar fonte bruta sem passar por camada de domínio ou API interna.
4. Testes podem usar fixtures, mas fixtures devem ser identificáveis.
5. Scripts temporários devem declarar que são temporários e não podem virar dependência silenciosa.
6. Consumo de dados externos deve ter fallback ou erro claro.
7. Mudança de fonte externa deve atualizar documentação.

---

## Regras de armazenamento

1. Dados persistidos devem ter localização documentada.
2. Saves, caches e bancos locais devem ser separados de dados versionados.
3. Cache deve ser recriável.
4. Dados de usuário não devem ser apagados por update sem consentimento ou backup.
5. Migrações de dados devem ter instrução de rollback ou mitigação.
6. Arquivos gerados não devem ser confundidos com fontes canônicas.
7. Dados locais do usuário devem ser ignorados pelo versionamento quando aplicável.

---

## Versionamento de dados

Use versionamento semântico sempre que o dado tiver contrato público:

```text
MAJOR.MINOR.PATCH
```

- `PATCH`: correção compatível de dados.
- `MINOR`: novo conteúdo ou novo campo compatível.
- `MAJOR`: quebra de schema, remoção de campo ou mudança incompatível.

Toda quebra de compatibilidade deve ser documentada em:

```text
docs/releases/PATCH_NOTES.md
docs/releases/RELEASE_NOTES.md
```

---

## Documentação obrigatória

Toda pasta de dados relevante deve ter README local se cumprir qualquer condição:

1. contém schemas;
2. contém fontes canônicas;
3. contém loaders/adapters;
4. contém fixtures relevantes;
5. contém exports;
6. contém scripts de migração;
7. é consumida por mais de um módulo;
8. pode ser atualizada por instalador.

O README deve conter:

```markdown
## Índice
## Responsabilidade
## Camadas de dados
## Fontes
## Schemas
## Consumo
## Persistência
## Validação
## Versionamento
## Riscos
## Documentos relacionados
```

---

## Rotina de adoção inicial

Se o projeto nunca usou UBU-ISO/1.0:

1. criar `docs/UBU-ISO-1.0-DADOS-CAMADAS.md`;
2. mapear pastas de dados reais;
3. identificar fontes, schemas e loaders;
4. criar README local para dados críticos;
5. declarar pendências como `A DEFINIR` quando não houver evidência;
6. atualizar `README.md` com link para a ISO;
7. atualizar `AGENTS.md` com obrigação de seguir a ISO;
8. registrar adoção em patch notes.

---

## Rotina de verificação de conformidade

Se o projeto já usa UBU-ISO/1.0:

1. verificar se novos dados têm camada declarada;
2. verificar se schemas novos têm versão;
3. verificar se loaders novos estão documentados;
4. verificar se persistência nova está documentada;
5. verificar se mudanças incompatíveis foram registradas;
6. atualizar somente o necessário;
7. registrar patch notes.

---

## Checklist de aceite

```markdown
- [ ] fontes de dados principais identificadas
- [ ] camadas lógicas declaradas
- [ ] schemas versionados ou pendência registrada
- [ ] loaders/adapters documentados
- [ ] persistência documentada
- [ ] exports documentados
- [ ] caches recriáveis ou risco registrado
- [ ] README local criado para dados críticos
- [ ] README principal aponta para a ISO
- [ ] AGENTS.md instrui agentes a seguir a ISO
- [ ] patch notes atualizadas
```

---

## Documentos relacionados

- [UBU-ISO/2.0 — Documentação Técnica](./UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md)
- [UBU-ISO/2.1 — Instalação BAT](./UBU-ISO-2.1-INSTALACAO-BAT.md)
- [Patch notes](./releases/PATCH_NOTES.md)
- [Release notes](./releases/RELEASE_NOTES.md)

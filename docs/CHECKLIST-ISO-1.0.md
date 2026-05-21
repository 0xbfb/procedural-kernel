# Checklist — UBU-ISO/1.0

Use este checklist em todo patch que altere dados, fontes, schemas, persistência ou consumo.

## Classificação

- [ ] O patch altera dados?
- [ ] O patch altera schema?
- [ ] O patch altera fonte externa?
- [ ] O patch altera loader/adapter?
- [ ] O patch altera save/cache/persistência?
- [ ] O patch altera exportação?

## Camadas

- [ ] L0 Fonte documentada
- [ ] L1 Entrada bruta preservada ou justificativa registrada
- [ ] L2 Validação definida
- [ ] L3 Normalização definida
- [ ] L4 Domínio/contrato definido
- [ ] L5 Runtime/cache definido
- [ ] L6 Persistência definida
- [ ] L7 Exportação definida
- [ ] L8 Auditoria definida

## Documentação

- [ ] README local atualizado
- [ ] Manifest/schema versionado
- [ ] README principal aponta para dados relevantes, se aplicável
- [ ] AGENTS.md não contradiz a ISO
- [ ] Patch notes atualizadas

## Riscos

- [ ] Breaking change documentada
- [ ] Migração necessária documentada
- [ ] Rollback ou mitigação documentada
- [ ] Dados locais do usuário preservados

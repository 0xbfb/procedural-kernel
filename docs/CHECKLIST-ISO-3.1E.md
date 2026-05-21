# Checklist — UBU-ISO/3.1 E

Use esta lista antes de fechar uma versão.

## Contrato JSON

- [ ] Existe `version-chain.json` no projeto.
- [ ] `schemaVersion` foi preenchido.
- [ ] `project.name` foi preenchido.
- [ ] `project.version` bate com a versão pretendida.
- [ ] `release.targetVersion` bate com a versão pretendida.
- [ ] `release.promoteTo` contém apenas `release`, `nightly` e/ou `stable`.
- [ ] `branches` define `patch`, `release`, `nightly` e `stable`.
- [ ] `push.remote` foi definido.
- [ ] `safety` está compatível com o risco da operação.

## Documentação

- [ ] Patch notes atualizadas.
- [ ] Release notes criadas ou atualizadas.
- [ ] README menciona o canal recomendado de instalação.
- [ ] AGENTS.md orienta agentes a gerar o JSON final.

## Branches e tags

- [ ] Branch atual esperada foi conferida.
- [ ] Working tree está limpa ou exceção foi justificada.
- [ ] Tag pretendida não existe ou sua atualização foi autorizada.
- [ ] `stable` só será promovida a partir de release.

## Instalação

- [ ] `install.bat` oferece menu de canal/branch.
- [ ] `run.bat` busca atualização antes de iniciar.
- [ ] O instalador lida com ZIP sem `.git` de forma compreensível.

## Validação

- [ ] `plan` ou dry-run foi executado.
- [ ] Testes do projeto foram executados quando existirem.
- [ ] Comandos de validação do JSON foram executados.
- [ ] Push real só será feito com flag explícita.

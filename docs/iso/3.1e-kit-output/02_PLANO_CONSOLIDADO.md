# Plano consolidado — UBU-ISO/3.1 E e UBU Version Governor

## Objetivo

Criar um projeto separado para padronizar commit e versionamento usando a cadeia:

```text
patch > release > nightly > stable
```

O projeto deve consumir um JSON final deixado pelo último prompt de patch e executar a cadeia de commits, branches, tags e pushs necessários para manter releases, nightlies, stable e documentação sincronizadas.

## Entregáveis

1. Norma `UBU-ISO/3.1 E` incorporada ao kit.
2. Projeto separado `projetos/ubu-version-governor`.
3. CLI em Python para validar, planejar e aplicar o contrato.
4. Schema JSON do contrato.
5. Exemplo de `version-chain.json`.
6. `install.bat` com menu de versão/canal.
7. `run.bat` que busca atualização antes de iniciar.
8. Makefile, Dockerfile e docker-compose conforme ISO/3.0.
9. Documentação e release notes conforme ISO/2.0.

## Fluxo operacional

1. O patch final gera `docs/releases/version-chain.json`.
2. O mantenedor roda `plan` para revisar.
3. O mantenedor roda `apply --apply` para executar localmente.
4. O mantenedor roda `apply --apply --push` para publicar branches/tags.

## Critérios de aceite

- O kit contém ISO/3.1 E.
- O projeto funciona sem dependências externas obrigatórias.
- `plan` não altera nada.
- `apply` é dry-run por padrão.
- Push exige flag explícita.
- O instalador pergunta a versão/canal e tenta redirecionar para a branch correspondente.
- ZIP final contém todos os arquivos necessários.

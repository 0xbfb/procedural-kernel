# Política — ISO stack-aware

A UBU Suite 0.3.1 deve respeitar a stack real do projeto.

## Regra principal

Não adicionar inicializadores, instaladores, Docker, Makefile ou scripts de bootstrap por padrão.

## Proibido adicionar sem necessidade real

```text
Dockerfile
docker-compose.yml
Makefile
install.bat
run.bat
scripts de instalação genéricos
```

## Permitido nesta migração

A migração UBU Suite 0.3.1 pode adicionar apenas arquivos de governança de release, documentação, configuração e proteção dev-only do versionador.

## Preservação

A migração não deve alterar:

- regra de negócio;
- código de aplicação;
- dependências da stack;
- runtime da aplicação;
- scripts existentes que pertençam ao projeto.

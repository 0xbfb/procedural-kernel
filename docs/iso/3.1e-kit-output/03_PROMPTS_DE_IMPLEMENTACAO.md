# Prompts de implementação gerados pelo roteiro do kit

## Prompt 1 — Criar norma ISO/3.1 E

Crie a norma `UBU-ISO/3.1 E — Esteira de Commit, Versionamento, Branches e Tags`, integrada à pasta `ubu_iso_suite/ISO-3.1E`. A norma deve definir a cadeia `patch > release > nightly > stable`, contrato JSON obrigatório, regras de branch, regras de tag, menu de instalação por canal e critérios de aceite. Atualize README, AGENTS e prompt mestre da suíte para citar a nova norma.

## Prompt 2 — Criar projeto executor

Crie o projeto separado `projetos/ubu-version-governor` com CLI Python 3.10+, sem dependências obrigatórias. Implemente comandos `doctor`, `validate`, `plan` e `apply`. `plan` deve ser somente leitura. `apply` deve ser dry-run por padrão e só executar com `--apply`; push só com `--push`.

## Prompt 3 — Criar contrato JSON e schema

Crie `schemas/ubu-version-chain.schema.json`, `examples/version-chain.example.json` e `docs/releases/version-chain.json`. O contrato deve conter `project`, `release`, `branches`, `commits`, `commands`, `push`, `safety` e `docs`.

## Prompt 4 — Implementar instalação por canal

Crie `install.bat` com menu: patch, release, nightly, stable e branch customizada. Se houver `.git`, execute fetch, checkout e pull da branch escolhida. Se for ZIP sem `.git`, explique a limitação e permita instalação local. Crie `run.bat` que busca atualizações antes de iniciar.

## Prompt 5 — Aplicar ISO/2.0, ISO/2.1 e ISO/3.0

Adicione README, AGENTS, Makefile, Dockerfile, docker-compose, notas de patch/release e documentação de adoção ISO. Garanta que o projeto seja instalável, executável e testável com comandos padronizados.

## Prompt 6 — Validar release final

Execute validação de sintaxe Python, testes unitários e plano de exemplo. Gere zip completo, mantendo o kit original e incluindo a nova ISO e o novo projeto.

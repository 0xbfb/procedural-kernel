# Estrutura recomendada no projeto após adoção das ISOs UBU

```text
project/
  README.md
  AGENTS.md
  Dockerfile
  docker-compose.yml
  Makefile
  install.bat
  run.bat
  .env.example
  .dockerignore
  docs/
    README.md
    UBU-ISO-1.0-DADOS-CAMADAS.md
    UBU-ISO-2.0-DOCUMENTACAO-TECNICA.md
    UBU-ISO-2.1-INSTALACAO-BAT.md
    UBU-ISO-3.0-INICIALIZADORES-E-BOOTSTRAP.md
    ISO_EXCEPTIONS.md
    releases/
      README.md
      PATCH_NOTES.md
      RELEASE_NOTES.md
      NIGHTLY_NOTES.md
      STABLE_NOTES.md
  scripts/
    bootstrap.sh
    bootstrap.bat
    doctor.sh
    doctor.bat
    test-bootstrap.sh
    test-bootstrap.bat
    update.sh
    update.bat
  tests/
    bootstrap/
      test_bootstrap_contract.*
```

## Observações

- `install.bat` e `run.bat` são obrigatórios quando a ISO/2.1 se aplicar.
- `Dockerfile`, `docker-compose.yml` e `Makefile` são obrigatórios para projetos executáveis, salvo exceção formal.
- Exceções devem ficar em `docs/ISO_EXCEPTIONS.md`.
- Projetos monorepo devem repetir README local nos pacotes principais.
- Projetos com dados devem seguir ISO/1.0.
- Todo patch deve atualizar patch notes conforme ISO/2.0.
- Todo patch deve validar bootstrap conforme ISO/3.0.
```

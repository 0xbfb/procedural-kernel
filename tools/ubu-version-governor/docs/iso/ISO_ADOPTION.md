# Adoção ISO do projeto

Este projeto nasce compatível com:

- UBU-ISO/2.0: documentação técnica, patch notes e release notes;
- UBU-ISO/2.1: `install.bat` com instalação simplificada e `run.bat` com update antes do boot;
- UBU-ISO/3.0: Makefile, Dockerfile, docker-compose e comandos canônicos;
- UBU-ISO/3.1 E: contrato JSON para versionamento e promoção patch > release > nightly > stable.

## Exceções

Não há ISO/1.0 obrigatória neste projeto porque não há camada de dados persistente própria. O JSON é contrato de execução, não base de dados operacional.

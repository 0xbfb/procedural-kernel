# Tools locais de desenvolvimento

Este diretório existe apenas para ferramentas locais auxiliares.

## Política UBU-ISO/3.1E

O `ubu-version-governor` é uma ferramenta de desenvolvimento e **não deve ser versionada dentro deste repositório como parte de patches do projeto**.

Quando for necessário usar o governor, instale-o fora do projeto ou em uma cópia local ignorada por Git:

```bash
# exemplo local, fora do patch de release
git clone <repo-ou-kit-do-governor> ../ubu-version-governor
```

O projeto mantém apenas contratos, schemas e scripts pequenos necessários para validar e planejar a cadeia de versionamento.

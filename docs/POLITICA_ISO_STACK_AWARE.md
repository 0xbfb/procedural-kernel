# Política — ISO sensível à stack e sem excesso

As ISOs devem aumentar previsibilidade, não criar peso morto.

A aplicação de ISO deve detectar a stack real do projeto e gerar somente arquivos úteis, executáveis e compatíveis com o fluxo do projeto.

## Regra principal

Não criar Dockerfile, `docker-compose.yml`, Makefile, `install.bat`, `run.bat` ou scripts auxiliares apenas porque existem templates.

Esses arquivos só devem ser criados quando pelo menos uma condição for verdadeira:

1. o projeto já usa o arquivo;
2. a stack exige ou se beneficia diretamente dele;
3. o escopo pede instalação/execução por esse caminho;
4. o ambiente alvo exige;
5. existe critério de aceite que dependa dele.

## Quando dispensar

A dispensa de um arquivo opcional não é erro. É uma decisão técnica normal.

Registre no manifesto:

- arquivo considerado;
- motivo da dispensa;
- comando alternativo oficial;
- risco, se existir.

## Exemplos

- Projeto Python CLI simples: pode usar `pyproject.toml`, `python -m pip install -e .`, `python -m pytest` e dispensar Docker/Makefile.
- Projeto Node/Vite: pode usar `package.json` com scripts `install`, `dev`, `build`, `test` e dispensar Makefile.
- Projeto Laravel já dockerizado: deve validar Docker existente, mas não criar outro compose paralelo.
- Projeto Windows para usuário final: pode usar `install.bat`/`run.bat`, mas somente se esse for o fluxo real do usuário.

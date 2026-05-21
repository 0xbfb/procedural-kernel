# UBU ISO 3.1 — Regra de auto-update do governor

Toda release ou patch deve verificar o repositório oficial do UBU Suite antes de executar a publicação do projeto atual.

## Regra obrigatória

O comando padrão de release é:

```powershell
.\release.ps1
```

Esse comando deve:

1. Verificar `kit.officialRepoUrl` em `release.config.json`.
2. Consultar o repo oficial do kit.
3. Comparar `kit.version` local com a versão remota.
4. Atualizar somente arquivos gerenciados do governor quando houver atualização compatível.
5. Recarregar o fluxo e publicar o projeto atual.

## Proibição

O auto-update do governor não pode alterar código de aplicação nem instalar arquivos que não pertencem à stack real do projeto.

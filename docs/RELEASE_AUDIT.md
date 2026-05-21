# Release Audit — Procedural Kernel 0.1.3

## Resumo

Release `0.1.3` gerada para corrigir arquivos faltantes do repositório e sincronizar a suíte UBU ISO mais recente.

## Escopo

- Hardening de versionamento.
- Sincronização documental ISO.
- Inclusão de `.gitignore` e menu PowerShell.
- Remoção da necessidade de versionar o governor completo dentro do projeto.

## Risco

Baixo para runtime Python. A mudança afeta principalmente documentação, scripts auxiliares e governança de release.

## Atenção operacional

Como zips overlay não removem arquivos rastreados, executar manualmente:

```bash
git rm -r --cached tools/ubu-version-governor
```

caso a pasta esteja rastreada no repositório.

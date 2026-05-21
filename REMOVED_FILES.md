# Arquivos removidos/não versionados

## 0.1.3

- `tools/ubu-version-governor/` deve ser removido do índice Git do projeto principal.

Motivo: o versionador/governor é uma ferramenta de desenvolvimento e não deve subir com patches/releases do pacote `procedural-kernel`.

Comando recomendado:

```bash
git rm -r --cached tools/ubu-version-governor
```

A pasta pode existir localmente para uso do desenvolvedor, mas está coberta por `.gitignore`.

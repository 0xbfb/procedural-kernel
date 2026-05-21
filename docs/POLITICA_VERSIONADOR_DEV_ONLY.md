# Política — Versionador dev-only

O versionador é ferramenta somente de desenvolvimento.

Ele não deve subir completo em:

- patches;
- releases;
- branches `release/*`;
- `nightly`;
- `stable`;
- tags.

Apenas estes arquivos podem ser versionados:

```text
dev/versionador/.gitignore
dev/versionador/README.md
```

Todo binário, runtime, build, cache, zip, script gerado ou executável real do versionador deve permanecer ignorado.

## Validação

```powershell
git ls-files dev/versionador
```

Resultado esperado:

```text
dev/versionador/.gitignore
dev/versionador/README.md
```

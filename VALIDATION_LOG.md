# Validações locais do patch

```text
$ git init && git add -A && git status --short
A  .env.example
A  .gitattributes
A  .gitignore
A  PATCH_MANIFEST.md
A  dev/versionador/.gitignore
A  dev/versionador/README.md
A  docs/GUIA_RELEASE_GIT_AUTOMATIZADO.md
A  docs/POLITICA_ISO_STACK_AWARE.md
A  docs/POLITICA_VERSIONADOR_DEV_ONLY.md
A  docs/UBU-ISO-3.1-RELEASE-GOVERNOR.md
A  patch-legacy.ps1
A  release.config.json
A  release.ps1
A  tools/patch/update-legacy-project.ps1
A  tools/release/README.md
A  tools/release/git-release.ps1
$ git diff --check --cached
(sem saída)
$ git ls-files dev/versionador
dev/versionador/.gitignore
dev/versionador/README.md
$ grep -R "working-tree-encoding" .gitattributes
(sem saída)
$ grep -R "https://github.com/0xbfb/ubu-suite.git" release.config.json
"officialRepoUrl": "https://github.com/0xbfb/ubu-suite.git"
```

Observação: `Select-String` e execução real dos scripts PowerShell não foram executados porque o ambiente atual não possui PowerShell instalado.

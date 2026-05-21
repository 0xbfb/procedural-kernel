# UBU ISO 3.1 - Release Governor aplicado

Este projeto foi atualizado para o formato UBU ISO 3.1.

## Arquivos adicionados/atualizados

- elease.ps1
- 	ools/release/git-release.ps1
- 	ools/release/README.md
- elease.config.json
- .env.example
- .gitattributes
- .gitignore
- dev/versionador/.gitignore
- dev/versionador/README.md

## Repositorios

- Projeto: $RepoUrl
- Kit oficial UBU: $ResolvedOfficialKitRepoUrl

## Comando sugerido

`powershell
.\release.ps1 -Version 0.3.1 -RepoUrl "https://github.com/0xbfb/procedural-kernel.git" -ReleaseKind patch -PatchTitle "Atualizacao para UBU Suite 0.3.1" -PatchDescription "Adiciona release governor, RepoUrl oficial do kit, ISO 3.1 e estrutura dev-only do versionador" -Force
`

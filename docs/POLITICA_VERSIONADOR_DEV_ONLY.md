# Política — Versionador dev-only

O versionador é uma ferramenta de desenvolvimento local para automatizar ou auxiliar o fluxo `patch > release > nightly > stable`.

Ele não é parte do produto final, não é dependência de runtime e não deve ser empacotado em patches de implementação.

## Pode ser versionado

- contratos JSON consumidos pelo versionador;
- exemplos sanitizados;
- documentação de uso;
- manifestos de release;
- `.gitignore` e estrutura mínima de pasta.

## Não pode ser versionado em patches/release

- executável do versionador;
- builds locais;
- caches;
- bancos locais;
- logs;
- artefatos `.zip` gerados;
- credenciais;
- scripts locais que executem comandos destrutivos sem revisão.

## Checklist obrigatório em patch

- [ ] `dev/versionador/*` continua ignorado.
- [ ] Nenhum binário do versionador entrou no zip.
- [ ] Nenhum cache/log/runtime do versionador entrou no zip.
- [ ] `PATCH_MANIFEST.md` informa quando algum contrato do versionador foi incluído.
- [ ] `RELEASE_NOTES.md` do release final não trata o versionador como dependência do produto.


## Distinção importante

O script `tools/release/git-release.ps1` e o disparador `release.ps1` são automações versionáveis de publicação Git. Eles não são o programa local do versionador.

O programa real do versionador continua restrito a `dev/versionador` e deve permanecer ignorado, exceto por `.gitignore` e `README.md`.

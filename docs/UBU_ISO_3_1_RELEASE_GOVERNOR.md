# UBU ISO 3.1 — Release Governor, RepoUrl oficial e atualização de projetos

## Objetivo

Padronizar a manutenção do disparador de release Git, do `release.config.json`, do RepoUrl oficial do kit UBU e do patch de atualização de projetos antigos.

Esta ISO existe para impedir que cada projeto reinvente sua própria esteira de `release > nightly > stable` e para garantir que os prompts finais sempre entreguem um comando executável de publicação.

## Escopo obrigatório

Todo projeto aderente à UBU ISO 3.1 deve possuir:

- `release.ps1` na raiz como disparador curto.
- `tools/release/git-release.ps1` como orquestrador completo.
- `release.config.json` versionado.
- `.env.example` com `UBU_OFFICIAL_KIT_REPO_URL` e `UBU_REPO_URL`.
- `.gitignore` protegendo `.env` e `dev/versionador/*`.
- `dev/versionador/.gitignore` e `dev/versionador/README.md` como única estrutura versionada do versionador.
- `.gitattributes` para reduzir ruído LF/CRLF.

## RepoUrl oficial do kit

O RepoUrl oficial do kit de orquestração UBU deve ser gravado diretamente na configuração gerada pela ISO:

```text
UBU_OFFICIAL_KIT_REPO_URL=https://github.com/0xbfb/ubu-suite.git
```

E em `release.config.json`:

```json
{
  "kit": {
    "officialRepoUrl": "https://github.com/0xbfb/ubu-suite.git",
    "iso": "UBU-ISO-3.1"
  }
}
```

O `RepoUrl` do projeto pode variar por projeto, mas o RepoUrl oficial do kit deve apontar para a fonte canônica do kit UBU.

## Regra sobre o versionador

O programa real do versionador é ferramenta de desenvolvimento local. Ele não deve subir em patches, releases, zips finais ou branches estáveis.

Apenas estes arquivos podem ser versionados:

- `dev/versionador/.gitignore`
- `dev/versionador/README.md`

## Fluxo obrigatório de publicação

O script deve orquestrar sempre a árvore:

```text
release/<versao> -> nightly -> stable
```

A branch `dev` é a origem de trabalho. A tag deve ser criada em `stable`.

## Regras de prompt final

O último prompt de implementação deve exigir que o executor entregue junto do zip final:

- `release.ps1`.
- `tools/release/git-release.ps1`.
- `release.config.json` atualizado.
- comando pronto para publicar a release ou patch.
- descrição e título variáveis por release/patch.
- registro do RepoUrl oficial do kit.
- validação de que `dev/versionador` não carrega binários, builds ou scripts reais.

## Projetos antigos

Projetos em formato antigo devem ser atualizados usando:

```powershell
.\patch-legacy.ps1 -TargetPath "C:\caminho\do\projeto" -RepoUrl "https://github.com/owner/projeto.git" -Version 0.3.2 -Force
```

Depois da migração, o projeto deve publicar o patch usando o `release.ps1` gerado no próprio projeto.

## Manutenção obrigatória do legacy patcher — 0.3.2+

O Release Governor deve manter o `patch-legacy.ps1` e `tools/patch/update-legacy-project.ps1` como ferramentas seguras e idempotentes.

Regras obrigatórias:

- `TargetPath` vazio deve falhar com mensagem clara.
- O erro comum `$PDW` em vez de `$PWD` deve ser mencionado na orientação.
- Cópia com origem e destino iguais deve ser ignorada com mensagem `SKIP`, nunca quebrar o patch.
- O patcher deve ser executável a partir da raiz do kit apontando para um projeto alvo.
- O patcher não deve alterar código de aplicação nem adicionar instaladores não usados pela stack.

## Release config-first — 0.3.3+

A partir da 0.3.3, o Release Governor deve tratar `release.config.json` como fonte primária para publicação.

O comando oficial desejado passa a ser:

```powershell
.\release.ps1 -DryRun
.\release.ps1
```

O prompt final de cada projeto deve atualizar `currentRelease` com versão, tipo, título, descrição, tag e branch de release. Flags continuam aceitas apenas como override.

## Checagem do kit antes do release — 0.3.3+

Antes de publicar o projeto atual, o `release.ps1` deve verificar o repo oficial do kit:

```text
https://github.com/0xbfb/ubu-suite.git
```

Se houver versão compatível mais nova do governor, o projeto deve atualizar primeiro os arquivos gerenciados do governor e só então continuar o release.

O auto-update não pode alterar código de aplicação nem adicionar instaladores não usados pela stack.


## Regra 0.3.3 — Legacy patcher config-first

Ao migrar projetos antigos, `patch-legacy.ps1` deve escrever `release.config.json` completo no schema `3.0`, incluindo `currentRelease`, `project.repoUrl`, `kit.officialRepoUrl`, `releaseDefaults`, `governorFiles` e políticas ativas.

Depois da migração, o comando oficial dentro do projeto alvo é:

```powershell
.\release.ps1 -DryRun
.\release.ps1
```

Flags passam a ser exceção/override, não uso normal.


## Fechamento 0.3.3 — config-first final

O uso padrão passa a ser:

```powershell
.\release.ps1 -DryRun
.\release.ps1
```

Antes da publicação, o governor verifica `https://github.com/0xbfb/ubu-suite.git`. Se houver versão compatível mais nova, atualiza somente arquivos gerenciados do governor e continua o release do projeto atual.

O patcher legado deve preparar `release.config.json` completo para que projetos antigos também publiquem sem flags após a migração.


## Regra 0.3.5 — compatibilidade com config remota legada

O auto-update do governor deve tolerar kits remotos antigos que ainda não possuem `kit.version` em `release.config.json`. A ordem de fallback para inferir versão é: `kit.version`, `currentRelease.version`, `lastRelease.version`, `implementationStage.release` e `releaseHistory[].version`. Se nenhum campo existir, o release deve continuar sem aplicar auto-update, registrando aviso claro.

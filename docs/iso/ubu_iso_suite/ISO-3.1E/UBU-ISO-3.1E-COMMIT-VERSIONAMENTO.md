# UBU-ISO/3.1 E — Esteira de Commit, Versionamento, Branches e Tags

> Norma interna UBU para padronizar a promoção de código entre `patch`, `release`, `nightly` e `stable`, usando um JSON final de patch como contrato de execução.

---

## 1. Identidade da norma

```text
Nome: UBU-ISO/3.1 E
Tema: Commit, versionamento, branches, tags e promoção automatizada
Status: obrigatório para projetos UBU que publicam versões por branch/tag
Depende de: UBU-ISO/2.0, UBU-ISO/2.1 e UBU-ISO/3.0
Ferramenta de referência: ubu-version-governor
```

O sufixo **E** significa **Esteira**: o padrão não descreve só uma branch, mas a cadeia inteira de promoção até uma versão publicável.

---

## 2. Objetivo

Garantir que o último patch de uma etapa consiga transformar a branch atual em uma release auditável, atualizando automaticamente:

1. commits finais;
2. documentação de patch/release;
3. branches de promoção;
4. tags versionadas;
5. push remoto;
6. histórico mínimo de execução;
7. instruções para humanos e agentes.

A norma evita o cenário em que o código está pronto, mas as branches, tags, releases e notas ficam divergentes.

---

## 3. Cadeia oficial de canais

A cadeia padrão é:

```text
patch > release > nightly > stable
```

| Canal | Função | Mutabilidade | Exemplo de branch |
|---|---|---:|---|
| `patch` | Desenvolvimento incremental de uma correção ou feature | alta | `patch/0.1.1` |
| `release` | Candidato fechado para versionamento | média | `release/0.2.0` |
| `nightly` | Integração contínua publicável para testes amplos | média/alta | `nightly` |
| `stable` | Linha estável para usuários finais | baixa | `stable` |

A promoção pode parar em `release` ou `nightly`, mas toda promoção para `stable` deve passar por `release`.

---

## 4. Contrato JSON obrigatório

Todo prompt final de patch que prepara uma versão deve deixar um arquivo JSON no projeto, preferencialmente em:

```text
docs/releases/version-chain.json
```

ou:

```text
release/version-chain.json
```

Esse arquivo é o contrato consumido pelo executor de versionamento.

Campos mínimos:

```json
{
  "schemaVersion": "1.0",
  "project": {
    "name": "meu-projeto",
    "version": "0.2.0"
  },
  "release": {
    "channel": "release",
    "targetVersion": "0.2.0",
    "promoteTo": ["release", "nightly"],
    "tagPrefix": "v"
  },
  "branches": {
    "patch": "patch/{version}",
    "release": "release/{version}",
    "nightly": "nightly",
    "stable": "stable"
  },
  "commits": [
    {
      "message": "chore(release): prepare 0.2.0",
      "include": ["."],
      "allowEmpty": false
    }
  ],
  "push": {
    "enabled": true,
    "remote": "origin",
    "branches": true,
    "tags": true
  },
  "safety": {
    "requireCleanWorkingTree": false,
    "requireBranch": null,
    "allowBranchCreate": true,
    "allowBranchReset": false
  }
}
```

---

## 5. Regra do último patch

O último patch antes de uma release deve entregar:

1. código completo da etapa;
2. documentação atualizada conforme ISO/2.0;
3. inicializadores atualizados conforme ISO/2.1 e ISO/3.0;
4. contrato `version-chain.json` preenchido;
5. comandos de validação executáveis;
6. indicação explícita se a promoção deve chegar em `release`, `nightly` ou `stable`;
7. tag pretendida, por exemplo `v0.2.0`;
8. branch de origem esperada.

Se o JSON estiver ausente, a release não é considerada fechada.

---

## 6. Regras de branch

1. Branches `patch/*` podem ser descartáveis.
2. Branches `release/*` devem ser preservadas e tagueadas.
3. `nightly` pode receber atualizações frequentes.
4. `stable` só deve receber merges de `release/*` tagueada.
5. Nenhum script deve fazer reset destrutivo de branch remota por padrão.
6. Reset de branch só é permitido com flag explícita e campo `safety.allowBranchReset=true`.
7. Tags não devem ser sobrescritas sem confirmação explícita.

---

## 7. Regras de commit

Commits criados pela esteira devem seguir mensagens convencionais simples:

```text
chore(release): prepare 0.2.0
chore(version): promote 0.2.0 to nightly
chore(version): promote 0.2.0 to stable
```

Commits vazios só são permitidos quando `allowEmpty=true` no item do JSON.

---

## 8. Regras de tag

Formato padrão:

```text
v{version}
```

Exemplos:

```text
v0.1.1
v0.2.0
v1.0.0
```

Tags devem ser anotadas quando houver mensagem definida em `release.tagMessage`.

---

## 9. Menu de instalação por versão

Projetos compatíveis com a ISO/3.1 E e ISO/2.1 devem ter um instalador com menu que pergunte qual canal instalar:

```text
1. patch
2. release
3. nightly
4. stable
5. branch customizada
```

O instalador deve resolver a branch correspondente e executar:

```text
git fetch --all --tags
git checkout <branch>
git pull --ff-only
```

Quando o projeto for distribuído como ZIP sem `.git`, o instalador deve explicar que o redirecionamento de branch exige repositório Git ou variável de remoto configurada.

---

## 10. Critérios de aceite

Uma implementação está conforme quando:

- existe contrato JSON versionado;
- existe schema ou validação mínima do contrato;
- existe comando de planejamento dry-run;
- a execução real exige flag explícita;
- push exige flag explícita;
- branches e tags são previsíveis;
- `stable` não é atualizado diretamente sem passar por release;
- `install.bat` tem menu de canal/branch;
- `run.bat` atualiza antes de iniciar;
- README documenta fluxo patch > release > nightly > stable;
- patch notes/release notes registram a promoção.

---

## 11. Regras para agentes de IA

Ao finalizar um patch que prepara release, o agente deve:

1. gerar ou atualizar `version-chain.json`;
2. não executar push sem pedido explícito;
3. preferir dry-run na primeira validação;
4. informar o comando exato para aplicar;
5. gerar notas de release;
6. manter ISO/2.1 e ISO/3.0 atualizadas;
7. não inventar branches fora do contrato;
8. não sobrescrever tag existente sem autorização.

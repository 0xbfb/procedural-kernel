# Prompt-mestre pós-plano para gerar prompts de implementação com release final estável

Use este prompt **logo após finalizar a definição do plano de implementação do projeto**.

A função dele é transformar o plano recém-definido em uma sequência enxuta, rígida e executável de prompts técnicos, garantindo que o último entregável seja um **release limpo, completo, estável e auditável**.

---

```markdown
Você atuará como arquiteto técnico, revisor de código, gerente de execução incremental e auditor de release.

Sua tarefa é transformar o plano de implementação recém-definido nesta conversa em uma sequência enxuta, rígida e executável de prompts técnicos para implementação.

O objetivo principal é garantir que a execução aconteça em etapas seguras, com entregáveis verificáveis, e que o último entregável seja um release limpo, completo, estável e com todos os arquivos necessários.

## Fonte principal de contexto

Use como fonte principal:

1. O plano de implementação definido imediatamente antes deste prompt.
2. O contexto técnico discutido nesta conversa.
3. As decisões já tomadas pelo usuário.
4. Os critérios de aceite já definidos.
5. Os arquivos, zips, diffs, logs, prints, comandos ou trechos de código enviados.
6. As restrições operacionais e preferências explícitas do usuário.
7. O estado inicial do projeto informado na conversa.
8. Quando disponível no kit, a pasta `ubu_iso_suite/` e especialmente `ubu_iso_suite/PROMPT_MESTRE_APLICAR_UBU_ISOS.md` como fonte normativa para padronização ISO.

Não invente requisitos, arquivos, fluxos, features, comandos, dependências, endpoints, tabelas ou abstrações que não estejam sustentados pelo plano ou pelo contexto.

Se uma informação estiver implícita, você pode consolidar e organizar, desde que preserve fidelidade ao que foi discutido.

Se houver ambiguidade leve, escolha a interpretação mais compatível com o histórico da conversa.

Se houver ambiguidade crítica, registre em `Pontos a confirmar`, sem travar a entrega.

---

# Objetivo da sua saída

Gerar um arquivo Markdown contendo todos os prompts finais de implementação, prontos para serem usados um por vez.

A saída deve ser útil para outro chat, agente executor ou ferramenta de codificação aplicar as mudanças incrementalmente.

O conjunto de prompts deve:

- ter o menor número possível de etapas;
- preservar segurança, rastreabilidade, revisão e qualidade;
- manter escopo controlado;
- evitar refatorações desnecessárias;
- garantir que cada etapa use o zip da etapa anterior;
- garantir que a última etapa gere um release completo, e não apenas um patch;
- garantir que o último zip contenha todos os arquivos necessários para execução, revisão ou distribuição.

---

# Regras obrigatórias de análise antes de criar os prompts

Antes de escrever os prompts finais, analise profundamente:

1. O plano técnico.
2. O contexto do projeto.
3. A stack usada.
4. A estrutura esperada de pastas.
5. As dependências técnicas entre tarefas.
6. Os riscos de regressão.
7. Os arquivos que precisam ser criados, editados ou removidos.
8. Os arquivos que não devem ser alterados.
9. Os pontos que precisam ser investigados no código antes de modificar.
10. Os testes e validações necessários.
11. Os efeitos de cada etapa no release final.
12. A forma correta de empacotar os zips.

Você deve agrupar tarefas que façam sentido serem executadas juntas, mas nunca misturar responsabilidades incompatíveis.

Reduza a quantidade total de prompts sempre que possível, sem comprometer clareza, revisão, segurança ou estabilidade.

---

# Regras obrigatórias de numeração e encadeamento

1. A contagem dos prompts deve começar obrigatoriamente em `Prompt 1`.
2. Nunca use `Prompt 0`.
3. O `Prompt 1` deve partir do zip inicial, estado atual ou base informada na conversa.
4. Todo prompt a partir do `Prompt 2` deve começar obrigatoriamente usando o zip gerado na etapa anterior como base.
5. Cada etapa deve produzir um zip.
6. Cada etapa deve informar claramente o nome sugerido do zip gerado.
7. Cada etapa deve listar qual zip deve ser usado como entrada da etapa seguinte.
8. O último prompt deve ser obrigatoriamente uma etapa de auditoria, estabilização e empacotamento final.
9. O último zip deve ser um zip final de release completo, não apenas um patch incremental.


---

# Regra obrigatória de execução das UBU ISOs após o Prompt 1

Quando a pasta `ubu_iso_suite/` estiver disponível no kit ou na entrada, a sequência de prompts deve incluir uma etapa obrigatória imediatamente após o `Prompt 1` para aplicar, validar ou atualizar as normas UBU ISO do projeto.

Essa etapa deve usar como referência:

```text
ubu_iso_suite/PROMPT_MESTRE_APLICAR_UBU_ISOS.md
ubu_iso_suite/ISO-1.0/
ubu_iso_suite/ISO-2.0/
ubu_iso_suite/ISO-2.1/
ubu_iso_suite/ISO-3.0/
ubu_iso_suite/ISO-3.1E/
ubu_iso_suite/AGENTS_UBU_ISO_PADRAO.md
ubu_iso_suite/ESTRUTURA_RECOMENDADA_NO_PROJETO.md
```

A etapa pós-`Prompt 1` deve:

1. classificar se o projeto é novo, existente sem ISOs UBU, existente com algumas ISOs UBU ou já compatível;
2. aplicar ou validar `UBU-ISO/1.0`, `UBU-ISO/2.0`, `UBU-ISO/2.1`, `UBU-ISO/3.0` e `UBU-ISO/3.1 E` conforme aplicabilidade real do projeto;
3. criar ou atualizar documentação, instaladores, inicializadores, scripts, Docker, Makefile, `.env.example`, AGENTS e exceções formais quando necessário;
4. quando o patch preparar release/tag/push, gerar ou validar `version-chain.json` conforme ISO/3.1 E;
5. registrar no `PATCH_MANIFEST.md` quais ISOs foram aplicadas, quais foram apenas verificadas e quais exigiram exceção formal;
6. não inventar comandos inexistentes: quando um comando ainda não existir, documentar como `A DEFINIR`, registrar pendência e classificar o risco;
7. versionar documentação somente quando houver alteração real;
8. produzir zip incremental de patch, salvo se esse for também o último prompt de release.

A numeração continua obrigatoriamente a partir de `Prompt 1`. Portanto, em geral:

```text
Prompt 1 — Primeira etapa técnica do plano
Prompt 2 — Aplicar/validar UBU ISOs do kit
Prompt 3+ — Próximas etapas do plano
Último prompt — Auditoria, estabilização e release completo
```

Se o plano tiver apenas uma etapa técnica antes do release, ainda assim a validação/aplicação das ISOs deve ocorrer antes da auditoria final.

# Modos de entrega obrigatórios

Existem dois modos possíveis de zip.

## 1. Zip incremental de patch

Use para etapas intermediárias.

O zip incremental deve:

- conter apenas arquivos novos, editados ou manifestos necessários;
- preservar a estrutura correta de pastas do projeto;
- ser aplicável sobre o zip da etapa anterior;
- incluir `PATCH_MANIFEST.md`;
- incluir `REMOVED_FILES.md` quando houver remoção de arquivos;
- incluir resumo do que foi alterado;
- listar validações executadas;
- listar pendências e riscos restantes.

## 2. Zip final de release

Use obrigatoriamente na última etapa.

O zip final de release deve:

- conter a árvore completa necessária para executar, revisar ou distribuir o projeto/módulo;
- não depender de nenhum zip anterior para funcionar;
- conter todos os arquivos finais necessários;
- refletir corretamente arquivos removidos;
- não conter código legado que o plano determinou remover;
- não conter arquivos temporários, cache, vendor, node_modules, dumps ou artefatos indevidos;
- incluir `RELEASE_NOTES.md`;
- incluir `PATCH_MANIFEST.md`;
- incluir `REMOVED_FILES.md`, quando houver remoções;
- incluir instruções claras de aplicação, execução e validação;
- informar riscos restantes, caso existam.

---

# Manifestos obrigatórios

Cada zip deve conter um `PATCH_MANIFEST.md`.

O `PATCH_MANIFEST.md` deve listar:

- nome da etapa;
- base usada;
- nome do zip de entrada;
- nome do zip gerado;
- arquivos criados;
- arquivos editados;
- arquivos removidos;
- arquivos intencionalmente não alterados;
- comandos executados;
- testes executados;
- testes não executados e motivo;
- inspeções manuais realizadas;
- greps ou verificações de referência executados;
- pendências;
- riscos restantes;
- observações sobre compatibilidade.

Quando houver remoção de arquivos, o zip também deve conter `REMOVED_FILES.md`.

O `REMOVED_FILES.md` deve listar:

- caminho exato de cada arquivo removido;
- motivo da remoção;
- evidência de que não há referências restantes;
- comandos ou greps usados;
- impacto esperado;
- risco se o arquivo permanecer na base.

No zip final de release, também deve existir `RELEASE_NOTES.md`.

O `RELEASE_NOTES.md` deve listar:

- versão ou nome do release, se informado;
- objetivo do release;
- principais mudanças;
- arquivos e módulos impactados;
- instruções de instalação/aplicação;
- instruções de execução;
- comandos de validação;
- testes executados;
- testes pendentes, se houver;
- riscos restantes;
- checklist final de estabilidade.

---

# Regra obrigatória de fechamento

Independentemente da quantidade de prompts gerados, o último prompt deve ser sempre uma etapa de:

- auditoria;
- estabilização;
- saneamento;
- validação;
- empacotamento final de release.

Essa etapa deve:

1. Usar o zip da etapa anterior como base.
2. Revisar o conjunto completo das alterações.
3. Verificar arquivos faltantes.
4. Verificar imports, namespaces, autoload, rotas, configs, scripts, migrations, testes e documentação, conforme a stack.
5. Remover código morto, logs indevidos, dumps, comentários temporários e debug.
6. Confirmar que arquivos removidos não são mais referenciados.
7. Confirmar que dependências novas, se houver, são justificadas.
8. Validar que o projeto ainda executa ou informar bloqueios reais.
9. Gerar o zip final em modo completo de release.
10. Produzir `PATCH_MANIFEST.md`, `RELEASE_NOTES.md` e `REMOVED_FILES.md`, quando aplicável.

Essa etapa não deve implementar novas features, exceto correções estritamente necessárias para estabilizar o release.

---

# Contrato de estabilidade do último entregável

O último zip só pode ser considerado final se:

- for aplicável em ambiente limpo;
- contiver todos os arquivos necessários;
- não depender de arquivos gerados em etapas anteriores que não estejam nele;
- não contiver código legado removido pelo plano;
- não contiver arquivos temporários, cache, vendor, node_modules ou dumps;
- passar nos testes e checks definidos, ou informar claramente falhas bloqueantes;
- tiver documentação mínima de execução;
- tiver manifesto de arquivos;
- tiver release notes;
- tiver lista de riscos restantes;
- tiver instruções claras para aplicar, executar e validar;
- refletir exatamente a estrutura final esperada do projeto ou módulo.

Se algum critério acima não puder ser cumprido, o último prompt deve exigir que o executor informe claramente o motivo e classifique o risco como:

- bloqueante;
- relevante;
- baixo;
- apenas informativo.

---

# Regras obrigatórias para montar os prompts

1. Cada prompt deve ter uma responsabilidade principal bem definida.
2. Cada prompt deve produzir um `.zip` como entregável final.
3. As alterações devem ser pontuais, simples e limitadas ao necessário para cumprir o plano.
4. Não invente novas features, abstrações, dependências, tabelas, endpoints, comandos ou fluxos.
5. Não faça refatorações amplas fora do escopo.
6. Não altere comportamento existente sem explicitar o motivo e incluir critério de aceite correspondente.
7. Não preserve código legado quando o plano pedir remoção, mas valide impactos antes de remover.
8. Não mascare erros com fallback silencioso, `try/catch` genérico ou logs inúteis.
9. Prefira código simples, legível, testável e fácil de revisar.
10. Se houver conflito entre simplicidade e arquitetura excessiva, escolha simplicidade, desde que os critérios de aceite sejam atendidos.
11. Se houver incerteza técnica, o prompt deve mandar investigar no código antes de alterar.
12. Cada prompt deve exigir revisão final do código antes de gerar o zip.
13. Cada prompt deve exigir análise do diff antes de gerar o zip.
14. Cada prompt deve exigir que o zip preserve a estrutura correta de pastas do projeto.
15. Cada prompt deve exigir que arquivos sensíveis, temporários ou desnecessários não sejam incluídos no zip.
16. Cada prompt deve declarar explicitamente o que está fora de escopo.
17. Cada prompt deve declarar o que pode ser criado, editado ou removido.
18. Cada prompt deve informar os testes e validações obrigatórias.
19. Cada prompt deve informar o que fazer se algum teste não puder ser executado.
20. Cada prompt deve deixar claro que o executor deve usar o zip da etapa anterior como base, quando aplicável.

---

# Modo conservador obrigatório

Quando houver dúvida entre uma solução ampla e uma solução pontual, o executor deve escolher a solução pontual.

Só é permitido refatorar amplamente quando:

- o plano pedir explicitamente;
- houver critério de aceite claro;
- a mudança for necessária para estabilidade;
- o impacto for validado por testes ou checks;
- o prompt explicitar claramente o motivo.

---

# Política para dependências novas

Não adicionar dependências novas, salvo quando o plano exigir claramente.

Se uma dependência nova for indispensável, o prompt deve exigir que o executor informe:

- nome da dependência;
- motivo;
- alternativa sem dependência;
- arquivos de lock alterados;
- impacto em instalação, build ou deploy;
- comando necessário para instalar;
- critério de aceite que justifica a inclusão.

Dependências novas sem justificativa objetiva devem ser proibidas.

---

# Checagem obrigatória de completude

Antes de gerar qualquer zip, cada prompt deve exigir que o executor confirme:

- arquivos de entrada existem;
- arquivos novos foram incluídos;
- arquivos editados estão no caminho correto;
- arquivos removidos realmente não são mais necessários;
- configs necessárias foram incluídas;
- comandos, scripts ou providers foram registrados, se aplicável;
- testes correspondentes foram incluídos ou justificados;
- documentação mínima foi atualizada;
- o zip reproduz exatamente a estrutura esperada do projeto;
- o manifesto foi incluído;
- não há arquivos indevidos no pacote.

No último prompt, essa checagem deve considerar a árvore final completa do release.

---

# Validação de referências cruzadas

Cada prompt deve exigir, conforme a stack e o escopo, verificação de:

- imports;
- namespaces;
- classes;
- traits;
- interfaces;
- rotas;
- endpoints;
- comandos;
- providers;
- listeners;
- events;
- jobs;
- configs;
- variáveis de ambiente;
- migrations;
- factories;
- seeders;
- views;
- componentes;
- scripts;
- documentação;
- testes;
- referências a arquivos removidos;
- referências a código legado.

Quando houver remoção, renomeação ou substituição de arquivos/classes, essa validação é obrigatória.

---

# Validação por stack

O prompt deve identificar a stack do projeto e incluir comandos específicos.

Use apenas comandos compatíveis com o projeto informado.

Exemplos possíveis:

## Laravel/PHP

- `composer dump-autoload`
- `php artisan config:clear`
- `php artisan route:list`
- `php artisan migrate --pretend`
- `php artisan test`

## Node/TypeScript

- `npm install` ou `pnpm install`
- `npm run typecheck` ou `pnpm typecheck`
- `npm run lint` ou `pnpm lint`
- `npm test` ou `pnpm test`
- `npm run build` ou `pnpm build`

## Python

- `python -m compileall .`
- `python -m pytest`
- `python -m pip check`

## Projetos com Docker

- `docker compose config`
- `docker compose build`
- `docker compose up`
- comandos de smoke test definidos no projeto

Se algum comando não puder ser executado, o executor deve informar:

- comando;
- motivo;
- risco;
- validação alternativa feita;
- se o bloqueio impede ou não o release.

---

# Diff sanity check obrigatório

Antes de fechar cada etapa, o prompt deve exigir revisão do diff e confirmação de que:

- o diff altera apenas o escopo permitido;
- não há mudança acidental de formatação em massa;
- não há arquivo sensível incluído;
- não há arquivo temporário incluído;
- não há cache incluído;
- não há vendor, node_modules ou dependências vendorizadas indevidas;
- não há alteração de comportamento não documentada;
- não há logs, dumps ou debugs esquecidos;
- não há duplicação desnecessária de lógica;
- não há código morto;
- não há dependência nova não justificada;
- não há alteração em arquivo de configuração sem documentação correspondente;
- o diff faz sentido em relação ao objetivo da etapa.

---

# Estrutura obrigatória de cada prompt

Cada prompt gerado deve seguir exatamente esta estrutura:

## Prompt N — Título objetivo da etapa

### Base de entrada

- Informe qual zip deve ser usado como ponto de partida.
- Para o `Prompt 1`, use o zip inicial, estado atual ou base informada.
- Para os demais, use obrigatoriamente o zip da etapa anterior.
- Informe qual zip esta etapa deve gerar.

### Objetivo

Explique em poucas linhas o que esta etapa deve entregar.

### Tipo de entregável

Informe se esta etapa deve gerar:

- zip incremental de patch; ou
- zip final de release completo.

### Escopo permitido

Liste exatamente o que pode ser criado, editado ou removido.

### Fora de escopo

Liste claramente o que não deve ser alterado nesta etapa.

### Instruções técnicas detalhadas

Descreva, em ordem lógica, o que deve ser analisado e implementado.

Inclua investigações obrigatórias antes de alterar, quando houver risco ou incerteza.

### Regras de implementação

Inclua regras rígidas sobre:

- simplicidade;
- compatibilidade;
- padrões do projeto;
- tipagem;
- logs;
- tratamento de erros;
- estilo;
- manutenção;
- dependências;
- preservação de contratos existentes.

### Critérios de aceite

Liste critérios objetivos e verificáveis.

Os critérios devem permitir dizer claramente se a etapa foi concluída ou não.

### Validação obrigatória

Inclua:

- comandos;
- testes;
- inspeções manuais;
- greps;
- análise de diff;
- validações de referência cruzada;
- checagem de completude;
- validações específicas da stack.

Se algum teste não puder ser executado, o executor deve registrar motivo, risco e alternativa.

### Revisão final antes do zip

Exija que o executor revise:

- se só alterou o necessário;
- se não deixou código morto;
- se não deixou logs, dumps ou debugs indevidos;
- se não quebrou contratos existentes;
- se os critérios de aceite foram atendidos;
- se o diff faz sentido;
- se dependências novas foram evitadas ou justificadas;
- se arquivos removidos não são mais referenciados;
- se a documentação mínima foi atualizada;
- se o manifesto foi criado;
- se o zip contém somente a estrutura correta.

### Entregável

Especifique:

- nome sugerido do zip;
- modo do zip;
- que o zip deve estar na estrutura correta do projeto;
- que deve conter apenas arquivos novos/editados/removidos necessários, quando for patch incremental;
- que deve conter a árvore completa final, quando for release final;
- que deve incluir `PATCH_MANIFEST.md`;
- que deve incluir `REMOVED_FILES.md`, quando houver remoções;
- que deve incluir `RELEASE_NOTES.md`, quando for o último zip;
- que deve acompanhar um breve resumo do que foi alterado;
- que deve listar testes e validações executados;
- que deve informar qualquer pendência ou risco restante.

---

# Regras para o Markdown final

O Markdown final gerado por você deve conter:

1. Título do conjunto de prompts.
2. Resumo do objetivo geral.
3. Quantidade total de prompts.
4. Confirmação explícita de que a numeração começa no `Prompt 1`.
5. Confirmação explícita de que as UBU ISOs do kit são aplicadas ou validadas imediatamente após o `Prompt 1`, quando a pasta `ubu_iso_suite/` estiver disponível.
6. Ordem de execução obrigatória.
7. Observação clara de que cada etapa depende do zip da etapa anterior.
7. Explicação dos dois modos de entrega:
   - zip incremental de patch;
   - zip final de release.
8. Lista resumida dos prompts em uma tabela com:
   - número;
   - título;
   - objetivo;
   - base de entrada;
   - entregável esperado;
   - modo de zip.
9. Todos os prompts completos, na ordem correta.
10. Uma seção chamada `Checklist global de qualidade`.
11. Uma seção chamada `Checklist final de release limpo`.
12. Uma seção chamada `Pontos a confirmar`, apenas se existirem lacunas reais.
13. Uma seção chamada `Riscos conhecidos`, se houver riscos identificados.

---

# Checklist global de qualidade

Inclua no Markdown final um checklist global que deve ser usado após o último zip.

Esse checklist deve validar:

- sequência executada na ordem correta;
- todos os zips intermediários gerados;
- último zip gerado em modo release completo;
- manifestos presentes;
- release notes presentes;
- arquivos removidos documentados;
- arquivos legados ausentes, quando aplicável;
- configs atualizadas;
- documentação mínima atualizada;
- testes executados;
- build/typecheck/lint executados, quando aplicável;
- comandos principais funcionando;
- imports/namespaces/referências conferidos;
- ausência de arquivos temporários;
- ausência de logs/debug/dumps;
- ausência de dependências não justificadas;
- ausência de comportamento alterado sem critério de aceite;
- estrutura final de pastas correta;
- instruções de aplicação e execução presentes.

---

# Checklist final de release limpo

Inclua também um checklist específico para o último entregável.

O último zip deve ser recusado se:

- for apenas um patch incremental;
- depender de arquivos que ficaram em zips anteriores;
- não tiver `RELEASE_NOTES.md`;
- não tiver `PATCH_MANIFEST.md`;
- não documentar remoções necessárias;
- contiver arquivos temporários;
- contiver cache;
- contiver vendor ou node_modules sem justificativa explícita;
- contiver código legado que deveria ter sido removido;
- não informar validações executadas;
- não informar testes não executados;
- não explicar riscos restantes;
- não conseguir ser aplicado em ambiente limpo.

---

# Tratamento de falta de informação

Se o contexto não tiver informação suficiente para decidir algo importante, não trave a entrega.

Inclua uma seção `Pontos a confirmar` com itens objetivos, por exemplo:

- [ ] Nome exato do zip inicial.
- [ ] Versão desejada do release.
- [ ] Comando oficial de teste.
- [ ] Ambiente alvo.
- [ ] Se o zip final deve conter o projeto inteiro ou apenas o módulo completo.

Não use `Pontos a confirmar` para lacunas irrelevantes.

Não deixe placeholders vazios.

Não faça perguntas fora do Markdown final se for possível entregar uma versão útil.

---

# Separação entre fatos, inferências e lacunas

Quando o contexto for grande ou espalhado, organize mentalmente as informações em:

## Fatos confirmados

Informações explicitamente presentes na conversa, nos arquivos ou no plano.

## Inferências razoáveis

Conclusões prováveis com base no contexto, mas que não foram ditas literalmente.

## Pontos a confirmar

Lacunas que podem afetar arquitetura, segurança, dados, escopo, execução ou release.

Use essa separação para evitar inventar decisões.

No Markdown final, inclua apenas o que for útil para execução.

---

# Saída esperada

Entregue apenas o Markdown final com o conjunto de prompts.

Fora do Markdown, informe somente:

- quantidade total de prompts gerados;
- confirmação de que o último prompt é uma etapa de auditoria/estabilização/release;
- confirmação de que o último zip esperado é um release completo.

Não gere código de implementação neste momento.

Não gere o zip de implementação neste momento.

Gere apenas os prompts finais de execução.
```

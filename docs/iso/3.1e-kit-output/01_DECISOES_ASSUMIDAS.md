# Decisões assumidas — execução do kit sem questionário

O questionário HTML foi pulado conforme solicitado. As decisões abaixo foram assumidas para manter o escopo fechado e executável.

| Decisão | Valor assumido | Justificativa |
|---|---|---|
| Nome do projeto | UBU Version Governor | Deixa claro que o projeto governa versionamento e promoção |
| Norma nova | UBU-ISO/3.1 E | Continuação natural da ISO/3.0 para esteira de versionamento |
| Significado do E | Esteira | O padrão cobre cadeia completa, não apenas um script |
| Cadeia oficial | patch > release > nightly > stable | Mantém exatamente a ordem solicitada |
| Entrada operacional | `version-chain.json` | Contrato simples para agentes e humanos |
| Linguagem do executor | Python 3.10+ | Sem dependências obrigatórias e portátil |
| Instalação Windows | `install.bat` com menu | Compatível com ISO/2.1 |
| Execução padrão | dry-run | Evita push/commit acidental |
| Push | apenas com `--apply --push` | Segurança explícita |
| Branch stable | só recebe release | Reduz risco de publicar patch direto |

# Checklist — UBU-ISO/2.1

Use em todo patch que altere instalação, execução, dependências, update ou bootstrap.

## Aplicabilidade

- [ ] Projeto roda no Windows para usuário final
- [ ] Projeto precisa de setup local
- [ ] Projeto tem CLI/API/app/jogo local
- [ ] ISO/2.1 aplicável
- [ ] ISO/2.1 não aplicável com justificativa

## install.bat

- [ ] Existe na raiz ou local documentado
- [ ] Instala dependências
- [ ] Prepara ambiente local
- [ ] Cria/atualiza run.bat
- [ ] Roda o programa após instalação
- [ ] Remove ou agenda remoção de si mesmo após sucesso
- [ ] Não apaga dados locais
- [ ] Não sobrescreve config sem backup
- [ ] Mostra erro claro
- [ ] Registra log mínimo

## run.bat

- [ ] Existe
- [ ] Verifica atualização antes do boot
- [ ] Inicia direto quando não há atualização
- [ ] Aplica atualização segura quando há atualização
- [ ] Preserva dados do usuário
- [ ] Falha de update não destrói instalação
- [ ] Boot principal funciona ou pendência registrada

## Documentação

- [ ] README explica instalação
- [ ] README explica execução
- [ ] AGENTS.md inclui regra ISO/2.1
- [ ] Patch notes atualizadas
- [ ] Riscos documentados

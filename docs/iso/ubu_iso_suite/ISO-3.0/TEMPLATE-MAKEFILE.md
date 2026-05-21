# Template — Makefile conforme UBU-ISO/3.0

> Adapte os comandos ao stack real do projeto. Não mantenha targets que chamam comandos inexistentes.

```makefile
.PHONY: help install update run test build doctor clean docker-build docker-up docker-down docker-logs install-bat run-bat

help:
	@echo "Comandos disponíveis:"
	@echo "  make install      Instala dependências do projeto"
	@echo "  make update       Atualiza dependências ou código local quando aplicável"
	@echo "  make run          Executa o projeto"
	@echo "  make test         Executa testes"
	@echo "  make build        Gera build"
	@echo "  make doctor       Verifica ambiente e arquivos obrigatórios"
	@echo "  make clean        Remove artefatos temporários"
	@echo "  make docker-build Builda containers"
	@echo "  make docker-up    Sobe containers"
	@echo "  make docker-down  Derruba containers"
	@echo "  make docker-logs  Exibe logs dos containers"

install:
	@echo "Ajuste este target para a stack real: npm, pip, composer, etc."
	@exit 1

update:
	@git pull --ff-only || true

run:
	@echo "Ajuste este target para iniciar o projeto."
	@exit 1

test:
	@echo "Ajuste este target para executar a suíte de testes."
	@exit 1

build:
	@echo "Ajuste este target para buildar o projeto, se aplicável."
	@exit 1

doctor:
	@echo "Verificando arquivos obrigatórios..."
	@test -f README.md
	@test -f AGENTS.md
	@test -f Dockerfile || test -f docs/ISO_EXCEPTIONS.md
	@test -f docker-compose.yml || test -f docs/ISO_EXCEPTIONS.md
	@test -f Makefile
	@echo "Doctor concluído."

clean:
	@echo "Ajuste este target para limpar artefatos temporários."

docker-build:
	docker compose build

docker-up:
	docker compose up --build

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

install-bat:
	@cmd.exe /c install.bat

run-bat:
	@cmd.exe /c run.bat
```

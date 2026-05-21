.PHONY: help install run test validate doctor build clean docker-build docker-up docker-down

help:
	@echo "Comandos disponíveis:"
	@echo "  make install    Instala o pacote em modo editável"
	@echo "  make run        Mostra doctor e plano de exemplo"
	@echo "  make test       Executa testes"
	@echo "  make validate   Valida JSON de exemplo"
	@echo "  make doctor     Verifica ambiente"

install:
	python -m pip install --upgrade pip
	python -m pip install -e . pytest

run:
	python -m ubu_version_governor doctor
	python -m ubu_version_governor plan --input examples/version-chain.example.json

test:
	python -m pytest

validate:
	python -m ubu_version_governor validate --input examples/version-chain.example.json

doctor:
	python -m ubu_version_governor doctor

build:
	python -m pip install build
	python -m build

clean:
	rm -rf build dist *.egg-info .pytest_cache

docker-build:
	docker compose build

docker-up:
	docker compose up --build

docker-down:
	docker compose down

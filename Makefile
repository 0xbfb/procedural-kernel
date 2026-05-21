PYTHON ?= python
STORAGE ?= .tmp/procedural_kernel.sqlite
SEED ?= makefile
EVENTS ?= 100

.PHONY: install test doctor simulate replay inspect export benchmark validate-version-chain version-plan clean

install:
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -e ".[dev]"

test:
	PYTHONPATH=src $(PYTHON) -m pytest -q

doctor:
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli doctor

simulate:
	mkdir -p .tmp
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli simulate --seed $(SEED) --events $(EVENTS) --storage $(STORAGE)

replay:
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli replay --storage $(STORAGE) --limit 3

inspect:
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli inspect --storage $(STORAGE) --limit 3

export:
	mkdir -p .tmp
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli export --storage $(STORAGE) --out .tmp/world_bundle.json --seed $(SEED)

benchmark:
	PYTHONPATH=src $(PYTHON) -m procedural_kernel.cli benchmark --entities 10000

validate-version-chain:
	$(PYTHON) scripts/validate_version_chain.py docs/releases/version-chain.json

version-plan:
	$(PYTHON) scripts/version/plan_version_chain.py

clean:
	rm -rf .pytest_cache .ruff_cache build dist *.egg-info .tmp
	find . -type d -name __pycache__ -prune -exec rm -rf {} +

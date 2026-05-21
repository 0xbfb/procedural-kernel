# Template — Teste de contrato de bootstrap conforme UBU-ISO/3.0

> Este template descreve o comportamento esperado. Adapte para a linguagem do projeto.

## Objetivo

Validar automaticamente que o projeto mantém os arquivos e contratos mínimos de instalação, execução e teste.

## Regras mínimas

O teste deve verificar:

1. `README.md` existe;
2. `AGENTS.md` existe;
3. `Makefile` existe;
4. `Dockerfile` existe ou `docs/ISO_EXCEPTIONS.md` documenta exceção;
5. `docker-compose.yml` existe ou `docs/ISO_EXCEPTIONS.md` documenta exceção;
6. README menciona instalação;
7. README menciona execução;
8. README menciona testes;
9. Node: `package.json` contém scripts `test`, `build` e `start`, ou exceção;
10. Python: `pyproject.toml`, `setup.py` ou `requirements.txt` existe;
11. PHP: `composer.json` existe;
12. ISO/2.1: `install.bat` e `run.bat` existem quando Windows BAT for suportado.

## Exemplo em Python/pytest

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_bootstrap_contract_files_exist_or_have_exception():
    assert (ROOT / "README.md").exists()
    assert (ROOT / "AGENTS.md").exists()
    assert (ROOT / "Makefile").exists()

    exceptions = ROOT / "docs" / "ISO_EXCEPTIONS.md"
    assert (ROOT / "Dockerfile").exists() or exceptions.exists()
    assert (ROOT / "docker-compose.yml").exists() or exceptions.exists()


def test_readme_documents_operational_commands():
    readme = (ROOT / "README.md").read_text(encoding="utf-8").lower()
    assert "instala" in readme or "install" in readme
    assert "execut" in readme or "run" in readme
    assert "test" in readme
```

## Exemplo em Node/Jest

```javascript
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..', '..');

function exists(file) {
  return fs.existsSync(path.join(root, file));
}

test('bootstrap contract files exist or have exception', () => {
  expect(exists('README.md')).toBe(true);
  expect(exists('AGENTS.md')).toBe(true);
  expect(exists('Makefile')).toBe(true);
  expect(exists('Dockerfile') || exists('docs/ISO_EXCEPTIONS.md')).toBe(true);
  expect(exists('docker-compose.yml') || exists('docs/ISO_EXCEPTIONS.md')).toBe(true);
});
```

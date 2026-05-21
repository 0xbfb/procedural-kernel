# Matriz de branches e tags — UBU-ISO/3.1 E

| Origem | Destino | Quando usar | Tag obrigatória? | Push padrão |
|---|---|---|---:|---:|
| `patch/{version}` | `release/{version}` | Fechar release candidate | Sim | Sim, com flag explícita |
| `release/{version}` | `nightly` | Disponibilizar build de teste ampla | Não obrigatória, mas recomendada | Sim, com flag explícita |
| `release/{version}` | `stable` | Publicar versão estável | Sim | Sim, com flag explícita |
| `nightly` | `stable` | Evitar por padrão | Não | Não |
| qualquer | tag existente | Só com autorização explícita | N/A | Não |

## Regra de ouro

`stable` não recebe patch direto. O caminho seguro é sempre:

```text
patch/{version} -> release/{version} -> stable
```

# Template — docker-compose.yml conforme UBU-ISO/3.0

> Adapte serviços, portas, volumes e variáveis ao projeto real.

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ubu-app
    working_dir: /app
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    env_file:
      - .env
    command: []
```

## Comandos obrigatórios

```bash
docker compose config
docker compose build
docker compose up --build
docker compose down
```

## Regras

- Nunca versionar `.env` real.
- Manter `.env.example` atualizado.
- Documentar portas no README.
- Documentar serviços auxiliares, como banco, cache, fila e storage.
- Não deixar serviço sem comando de inicialização claro.

# Template — Dockerfile conforme UBU-ISO/3.0

> Este template deve ser adaptado ao stack real. Não use imagem, portas ou comandos fictícios no projeto final.

## Node

```dockerfile
FROM node:22-bookworm-slim

WORKDIR /app

COPY package*.json ./
RUN npm ci || npm install

COPY . .

RUN npm run build --if-present

EXPOSE 3000
CMD ["npm", "start"]
```

## Python

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN python -m pip install --upgrade pip

COPY pyproject.toml setup.py requirements.txt ./
RUN if [ -f requirements.txt ]; then python -m pip install -r requirements.txt; fi
RUN if [ -f pyproject.toml ] || [ -f setup.py ]; then python -m pip install -e .; fi

COPY . .

CMD ["python", "-m", "NOME_DO_PACOTE"]
```

## PHP/Laravel

```dockerfile
FROM php:8.3-cli

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist

COPY . .

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
```

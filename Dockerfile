FROM python:3.12-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY pyproject.toml README.md ./
COPY src ./src
COPY tests ./tests
COPY docs ./docs
COPY scripts ./scripts
COPY examples ./examples
COPY tools ./tools
RUN python -m pip install --upgrade pip && python -m pip install -e ".[dev]"

CMD ["python", "-m", "procedural_kernel.cli", "doctor"]

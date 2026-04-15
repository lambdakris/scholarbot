# syntax=docker/dockerfile:1

FROM python:3.11-slim

# Node.js is required at runtime by the Claude Agent SDK's bundled CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set work dir — mirrors project root so pyproject.toml package-dir works
WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Install dependencies only (project install needs source, done below)
RUN uv sync --frozen --no-install-project

# Copy source code (mirrors src/ layout from project root)
COPY ./src/inference ./src/inference
COPY ./src/server ./src/server

# Install project as editable package (fast — deps already cached)
RUN uv sync --frozen

# Run as non-root user (required by Claude Agent SDK's --dangerously-skip-permissions)
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

# Default command (overridden by compose for dev)
CMD ["uv", "run", "fastapi", "dev", "src/server/main.py", "--host", "0.0.0.0"]

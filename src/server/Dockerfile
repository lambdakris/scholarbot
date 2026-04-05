# syntax=docker/dockerfile:1

FROM python:3.11-slim

# Node.js is required at runtime by the Claude Agent SDK's bundled CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set work dir
WORKDIR /src/server

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen

# Copy service code
COPY ./src/server .

# Run as non-root user (required by Claude Agent SDK's --dangerously-skip-permissions)
RUN useradd --create-home appuser && chown -R appuser:appuser /src/server
USER appuser

# Default command (overridden by compose for dev)
CMD ["uv", "run", "fastapi", "dev", "main.py", "--host", "0.0.0.0"]

# syntax=docker/dockerfile:1

FROM python:3.11-slim

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

# Default command (overridden by compose for dev)
CMD ["uv", "run", "fastapi", "dev", "main.py", "--host", "0.0.0.0"]

# syntax=docker/dockerfile:1

FROM python:3.11-slim

# Set work dir — mirrors project root so pyproject.toml package-dir works
WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Install dependencies only (project install needs source, done below)
RUN uv sync --frozen --no-install-project

# Copy service code
COPY ./src/portal ./src/portal

# Install project as editable package (fast — deps already cached)
RUN uv sync --frozen

# Default command (overridden by compose for dev)
CMD ["uv", "run", "streamlit", "run", "src/portal/main.py", "--server.address", "0.0.0.0"]

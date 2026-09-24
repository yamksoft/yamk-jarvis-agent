# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.14

# ==========================================
# 1. Frontend Build Stage (Node.js)
# ==========================================
FROM node:20-bookworm-slim AS frontend-build

WORKDIR /build
# Install pnpm
RUN npm install -g pnpm

# Copy frontend dependencies and install
COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN pnpm install

# Copy frontend source and build
COPY frontend/ ./
RUN pnpm format || true
RUN pnpm build

# ==========================================
# 2. Backend Build Stage (Python/UV)
# ==========================================
FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim AS base
ENV PYTHONUNBUFFERED=1
ENV UV_COMPILE_BYTECODE=1
ENV HF_HOME=/app/.cache/huggingface
ENV TORCH_HOME=/app/.cache/torch

FROM base AS backend-build
RUN apt-get update && apt-get install -y gcc g++ python3-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN mkdir -p src
RUN uv sync --locked
RUN uv run --module livekit.agents download-files
COPY src/ ./src/
COPY .env* ./

# ==========================================
# 3. Final Production Stage
# ==========================================
FROM base

# Install Node.js, Supervisor, and Docker CLI
RUN apt-get update && apt-get install -y curl supervisor docker.io \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python backend
COPY --from=backend-build /app /app

# Install Playwright Browsers and dependencies
RUN uv run playwright install chromium && uv run playwright install-deps chromium

# Copy Next.js frontend
COPY --from=frontend-build /build /app/frontend

# Copy Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Next.js port
EXPOSE 3000

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

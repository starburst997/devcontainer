# Version argument - can be overridden at build time
ARG VERSION=latest

# Use the node image as base - will be built in same workflow
ARG BASE_IMAGE=ghcr.io/starburst997/devcontainer/node:${VERSION}
FROM ${BASE_IMAGE}

# PostgreSQL configuration
ARG POSTGRES_VERSION=17
ENV POSTGRES_VERSION=${POSTGRES_VERSION} \
    PGDATA=/var/lib/postgresql/data \
    POSTGRES_USER=postgres \
    POSTGRES_DB=postgres \
    POSTGRES_PASSWORD=postgres

# Install PostgreSQL dependencies
USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install PostgreSQL in a single layer to minimize QEMU invocations
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
        wget \
        lsb-release \
        sudo \
        supervisor \
    && mkdir -p /usr/share/keyrings \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-${POSTGRES_VERSION} \
        postgresql-client-${POSTGRES_VERSION} \
        postgresql-contrib-${POSTGRES_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create PostgreSQL data directory
RUN mkdir -p /var/lib/postgresql/data \
    && chown -R postgres:postgres /var/lib/postgresql \
    && mkdir -p /var/log/postgresql \
    && chown postgres:postgres /var/log/postgresql

# Create startup script
RUN mkdir -p /usr/local/share/postgres
COPY start-postgres.sh /usr/local/share/postgres/start.sh
RUN chmod +x /usr/local/share/postgres/start.sh

# Create supervisor configuration
RUN mkdir -p /etc/supervisor/conf.d
RUN echo "[supervisord]\n\
nodaemon=false\n\
user=root\n\
\n\
[program:postgresql]\n\
command=/usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres -D /var/lib/postgresql/data\n\
user=postgres\n\
autostart=false\n\
autorestart=true\n\
stdout_logfile=/var/log/postgresql/postgresql.log\n\
stderr_logfile=/var/log/postgresql/postgresql_error.log\n\
priority=1\n\
stopasgroup=true\n\
killasgroup=true" > /etc/supervisor/conf.d/postgres.conf

# Expose PostgreSQL port
EXPOSE 5432

# Build arguments for metadata
ARG VERSION
ARG BUILD_DATE
ARG GITHUB_SHA

# Dev container metadata - startup command for PostgreSQL
LABEL devcontainer.metadata='[{ \
    "postStartCommand": "/usr/local/share/postgres/start.sh", \
    "forwardPorts": [5432], \
    "containerEnv": { \
        "PGDATA": "/var/lib/postgresql/data", \
        "POSTGRES_USER": "postgres", \
        "POSTGRES_DB": "postgres", \
        "POSTGRES_PASSWORD": "postgres" \
    } \
}]'

# Image metadata
LABEL org.opencontainers.image.title="Node + PostgreSQL Dev Container" \
      org.opencontainers.image.description="Node.js development environment with embedded PostgreSQL ${POSTGRES_VERSION}" \
      org.opencontainers.image.source="https://github.com/starburst997/devcontainer" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GITHUB_SHA}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="starburst997" \
      org.opencontainers.image.documentation="https://github.com/starburst997/devcontainer/blob/main/README.md"

# Switch back to zsh to maintain compatibility with base image
SHELL ["/bin/zsh", "-c"]

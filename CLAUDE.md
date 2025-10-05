# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides reusable development container configurations, including pre-built Docker images, templates, and features for VS Code dev containers. It focuses on creating consistent, portable development environments.

**Architecture Philosophy:**
- **Pre-built Images**: Tools and runtimes are baked into Docker images for speed
- **Features**: User preferences and optional components (VS Code extensions, etc.)
- **Templates**: Minimal glue connecting images, features, and local mounts

## Common Development Commands

### Building and Publishing

```bash
# Manually trigger a release (happens automatically on push to main)
git push origin main

# Test Docker image build locally
docker build -t test-personal-dev ./images/personal-dev/

# Test multi-architecture build locally
docker buildx build --platform linux/amd64,linux/arm64 -t test-personal-dev ./images/personal-dev/

# Validate template configuration
npm install -g @devcontainers/cli
devcontainer templates apply --template-id nodejs-postgres --template-args '{}' --target-folder test-output
```

### Testing Templates

```bash
# Test template in a new project
mkdir test-project && cd test-project
devcontainer templates apply --template-id nodejs-postgres --template-args '{"nodeVersion":"24","postgresVersion":"latest"}' --target-folder .

# Validate devcontainer configuration
devcontainer up --workspace-folder .
```

## Architecture & Key Components

### Automated Release Pipeline

The release workflow (`.github/workflows/release.yml`) handles the entire publishing lifecycle:
1. **Version Management**: Automatically increments minor version on each push to main using git tags (no version files in repo)
2. **Docker Image Building**: Multi-architecture builds (amd64/arm64) pushed to GitHub Container Registry
3. **Template Publishing**: Uses @devcontainers/cli to publish templates to OCI registry
4. **Release Creation**: Generates changelog from commits and creates GitHub releases

### Docker Image Structure

The repository contains two pre-built images:

**`images/node/`** - Base Node.js environment:
- **Base**: Microsoft's official Node.js devcontainer (Node 24, Debian Bookworm)
- **Package Manager**: pnpm pre-installed globally
- **Shell**: PowerLevel10k theme with automated setup
- **Tools**: Neovim, Claude Code CLI, GitHub CLI
- **Configuration**: History persistence setup, common aliases

**`images/node-postgres/`** - Extends node with PostgreSQL:
- **Base**: `FROM ghcr.io/starburst997/devcontainer/node:latest`
- **Database**: PostgreSQL 17 with supervisor
- **Auto-start**: Script at `/usr/local/share/postgres/start.sh`
- **Metadata**: Contains `devcontainer.metadata` LABEL with `postStartCommand`, `forwardPorts`, and `containerEnv`
- **Persistence**: Expects volume mount at `/var/lib/postgresql/data`

### Template and Feature System

**Templates** (`templates/`) are minimal devcontainer configurations:
- **nodejs**: Uses `node` image + `settings` feature + local mounts
- **nodejs-postgres**: Uses `node-postgres` image + `settings` feature + local mounts + postgres volume

Templates are intentionally minimal - most configuration lives in the images and features.

**Features** (`features/`) provide optional, composable functionality:
- **settings**: VS Code extensions, editor config, lifecycle commands (postCreate, postStart)
- **postgres**: Reference implementation of embedded PostgreSQL (not used in templates; images used instead)

**Key Principle**: Templates = Image + Feature(s) + Mounts. Everything else is pre-built.

## Adding New Components

### New Template
1. Create directory in `templates/[template-name]/`
2. Add `devcontainer-template.json` with metadata
3. Add `.devcontainer/` with configuration files
4. Push to main for automatic publishing

### New Feature
1. Create directory in `features/[feature-name]/`
2. Add `devcontainer-feature.json` with metadata and contributed properties
3. Add `install.sh` for any installation logic
4. Features are published to `ghcr.io/starburst997/features/[feature-name]`

### New Docker Image
1. Create directory in `images/[image-name]/`
2. Add Dockerfile with proper org.opencontainers.image labels
3. Include build args: VERSION, BUILD_DATE, GITHUB_SHA
4. Push to main - workflow automatically discovers and builds all images

## Important Implementation Details

- **Versioning**: Uses semantic versioning via git tags only (starts at v1.0.0, auto-increments minor version)
- **Registry**: All artifacts published to GitHub Container Registry (ghcr.io)
- **Multi-arch**: Docker images support both amd64 and arm64 architectures
- **Image Tags**: Both versioned (1.x.x) and latest tags are published
- **Image Metadata**: OCI labels and devcontainer.metadata LABELs are in Dockerfiles
- **Volume Mounts**: Cannot be moved to Dockerfiles - require `${devcontainerId}` variable from devcontainer.json
- **Pre-built Strategy**: Tools/runtimes in images (fast), preferences in features (flexible), local config in mounts (secure)
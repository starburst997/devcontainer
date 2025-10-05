# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides reusable development container configurations, including pre-built Docker images, templates, and features for VS Code dev containers. It focuses on creating consistent, portable development environments.

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

The `images/node/` directory contains the base Node.js development environment:
- **Base**: Microsoft's official Node.js devcontainer image
- **Enhancements**: PowerLevel10k theme, Neovim, Claude Code CLI, GitHub CLI
- **Persistence**: Command history mounted at `/commandhistory/`
- **Configuration**: Automated setup via `setup-p10k.sh`

### Template and Feature System

Templates in `templates/` and Features in `features/` follow the devcontainer specification:
- `devcontainer-template.json`: Metadata and configurable options
- `.devcontainer/devcontainer.json`: Container configuration
- `.devcontainer/docker-compose.yml`: Multi-service setup (app + database)

The `nodejs-postgres` template provides:
- Parameterized Node.js and PostgreSQL versions
- Pre-configured VS Code extensions
- SSH agent forwarding support
- Git config synchronization

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
- **Template Variables**: Support dynamic values via devcontainer-template.json options
- **Image Tags**: Both versioned (1.x.x) and latest tags are published
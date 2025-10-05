# Development Container Templates & Images

Pre-built development environments for Node.js projects with optional PostgreSQL.

## Quick Start

### Using Dev Container CLI

Install a template in your project:

```bash
# Install CLI
npm install -g @devcontainers/cli

# Apply nodejs template
devcontainer templates apply \
  -t ghcr.io/starburst997/devcontainer/templates/nodejs \
  -w .

# Apply nodejs-postgres template
devcontainer templates apply \
  -t ghcr.io/starburst997/devcontainer/templates/nodejs-postgres \
  -w .
```

### Using VS Code

1. Open your project in VS Code
2. Run command: **Dev Containers: Add Dev Container Configuration Files...**
3. Select **Show All Definitions...**
4. Search for `starburst997/nodejs` or `starburst997/nodejs-postgres`
5. Select template and reopen in container

### Manual Setup

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "ghcr.io/starburst997/devcontainer/node:latest",
  "features": {
    "ghcr.io/starburst997/features/settings": "latest"
  },
  "mounts": [
    "source=${localEnv:SSH_AUTH_SOCK},target=/run/host-services/ssh-auth.sock,type=bind,readonly",
    "source=claude-code-bashhistory-${devcontainerId},target=/commandhistory,type=volume",
    "source=${localEnv:HOME}/.claude,target=/root/.claude,type=bind",
    "source=${localEnv:HOME}/.config/gh,target=/root/.config/gh,type=bind",
    "source=${localEnv:HOME}/.p10k.zsh,target=/root/.p10k.zsh,type=bind,readonly"
  ],
  "remoteEnv": {
    "SSH_AUTH_SOCK": "/run/host-services/ssh-auth.sock",
    "GH_TOKEN": "${localEnv:GH_TOKEN}",
    "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}"
  }
}
```

## Available Resources

### Templates

| Template          | Description                      | Database   |
| ----------------- | -------------------------------- | ---------- |
| `nodejs`          | Node.js 24 + pnpm + tools        | None       |
| `nodejs-postgres` | Node.js + embedded PostgreSQL 17 | PostgreSQL |

**Includes:** PowerLevel10k, Neovim, Claude Code, GitHub CLI, VS Code extensions

### Images

| Image                                                    | What's Inside                    |
| -------------------------------------------------------- | -------------------------------- |
| `ghcr.io/starburst997/devcontainer/node:latest`          | Node.js 24, pnpm, dev tools      |
| `ghcr.io/starburst997/devcontainer/node-postgres:latest` | Everything above + PostgreSQL 17 |

**Tags:** `latest`, `1.x.x` (e.g., `1.0.0`)

### Features

| Feature                                  | Purpose                                        |
| ---------------------------------------- | ---------------------------------------------- |
| `ghcr.io/starburst997/features/settings` | VS Code extensions & dev settings              |
| `ghcr.io/starburst997/features/postgres` | Embedded PostgreSQL (reference implementation) |

## Usage Examples

### Node.js Only

```json
{
  "name": "my-app",
  "image": "ghcr.io/starburst997/devcontainer/node:latest",
  "features": {
    "ghcr.io/starburst997/features/settings": "latest"
  }
  // ... mounts and remoteEnv (see Manual Setup)
}
```

### Node.js + PostgreSQL

```json
{
  "name": "my-app",
  "image": "ghcr.io/starburst997/devcontainer/node-postgres:latest",
  "features": {
    "ghcr.io/starburst997/features/settings": "latest"
  },
  "mounts": [
    "source=postgres-data-${devcontainerId},target=/var/lib/postgresql/data,type=volume"
    // ... other mounts (see Manual Setup)
  ]
  // ... remoteEnv (see Manual Setup)
}
```

**PostgreSQL Connection:**

- Host: `localhost:5432`
- User/Pass: `postgres/postgres`
- Database: `postgres`

## What's Included

All images and templates include:

- **Node.js 24** (Debian Bookworm)
- **pnpm** - Fast package manager
- **PowerLevel10k** - Customizable zsh theme
- **Neovim** - Modern editor
- **Claude Code** - AI development assistant
- **GitHub CLI (gh)** - GitHub integration
- **Multi-arch** - Works on amd64 and arm64

## Repository Structure

```
images/          # Pre-built Docker images
  node/          # Base Node.js environment
  node-postgres/ # Node.js + PostgreSQL
templates/       # Dev container templates
  nodejs/
  nodejs-postgres/
features/        # Dev container features
  settings/
  postgres/
```

## License

MIT

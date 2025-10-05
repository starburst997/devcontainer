# Development Container Templates & Images

This repository provides reusable development container configurations, including:

- **Pre-built Docker images** - Ready-to-use development environments
- **Templates** - Complete devcontainer configurations for various project types
- **Features** - Installable components for customizing containers

## Quick Start

### Using a Template in a New Project

1. In VS Code, open your project folder
2. Run the command: **Dev Containers: Add Dev Container Configuration Files...**
3. Select **Show All Definitions...**
4. Search for `nodejs-postgres` (or other available templates)
5. Select the template and customize options if prompted
6. Reopen in container

### Using in an Existing Project (Manual)

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "features": {
    "ghcr.io/devcontainers-extra/features/pnpm": "latest"
  },
  // ... add your customizations
}
```

And `.devcontainer/docker-compose.yml`:

```yaml
version: "3.8"

services:
  app:
    image: ghcr.io/starburst997/devcontainer/personal-dev:latest
    volumes:
      - ../..:/workspaces:cached
    command: sleep infinity

  db:
    image: postgres:latest
    restart: unless-stopped
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres

volumes:
  postgres-data:
```

## Available Templates

### `nodejs-postgres`

Node.js development environment with PostgreSQL database, including:

- **Node.js 24** (configurable)
- **PostgreSQL** (configurable version)
- **PowerLevel10k** - Beautiful zsh prompt
- **Neovim** - Modern vim editor
- **Claude Code** - AI-powered coding assistant
- **GitHub CLI** - GitHub integration
- **Common aliases** - Productivity shortcuts

**Features:**
- SSH agent forwarding (1Password support)
- Git config synchronization
- Persistent command history
- VS Code extensions pre-installed
- PostgreSQL database ready to use

## Pre-built Images

### `ghcr.io/starburst997/devcontainer/personal-dev:latest`

A fully-configured development environment based on Microsoft's official Node.js devcontainer, enhanced with:

- PowerLevel10k theme for zsh
- Neovim
- Claude Code CLI
- GitHub CLI (gh)
- Persistent bash/zsh history
- Common shell aliases
- Multi-architecture support (amd64, arm64)

**Tags:**
- `latest` - Always the newest version
- `1.x.x` - Specific version (e.g., `1.0.0`, `1.1.0`)

## How It Works

### Automatic Publishing

When you push to the `main` branch:

1. **Version Detection** - Checks the latest git tag
2. **Auto-increment** - Bumps the minor version (e.g., `v1.0.0` → `v1.1.0`)
3. **Build Image** - Creates multi-arch Docker image
4. **Push to Registry** - Publishes to GitHub Container Registry (GHCR)
5. **Publish Templates** - Makes templates available via OCI registry
6. **Create Release** - GitHub release with changelog

### Versioning

- Versions follow semantic versioning: `MAJOR.MINOR.PATCH`
- Commits to `main` increment the **minor** version
- Starting version: `v1.0.0`
- No version files in git - uses git tags only

## Updating Your Container

### When Templates/Images Are Updated

If you're using `:latest` tag (recommended for templates):

1. Run: **Dev Containers: Rebuild Container** (or **Rebuild and Reopen in Container**)
2. Docker will pull the latest image from the registry
3. Your container will be rebuilt with the new version

**Note:** Template changes (devcontainer.json structure) are applied **at creation time only**. To get template updates, you'll need to:
- Manually update your `.devcontainer/devcontainer.json` file, or
- Delete your `.devcontainer` folder and re-apply the template

Image updates (Dockerfile changes) are automatically pulled when rebuilding.

### Pinning to a Specific Version

For production stability, pin to a specific version:

```yaml
services:
  app:
    image: ghcr.io/starburst997/devcontainer/personal-dev:1.2.0  # Specific version
```

## Repository Structure

```
devcontainer/
├── .github/
│   └── workflows/
│       └── release.yml          # Automated publishing workflow
├── images/
│   └── personal-dev/           # Docker image source
│       ├── Dockerfile
│       └── setup-p10k.sh
├── src/
│   ├── nodejs-postgres/        # Template: Node.js + PostgreSQL
│   │   ├── devcontainer-template.json
│   │   └── .devcontainer/
│   │       ├── devcontainer.json
│   │       └── docker-compose.yml
│   └── [future-template]/      # Add more templates here
└── README.md
```

## Creating New Templates

To add a new template:

1. Create a new folder in `src/`
2. Add `devcontainer-template.json` with metadata
3. Add `.devcontainer/` folder with configuration
4. Push to `main` - it will be automatically published

Example structure:

```
src/
└── my-template/
    ├── devcontainer-template.json
    └── .devcontainer/
        ├── devcontainer.json
        └── docker-compose.yml (optional)
```

## Creating New Images

To add a new image:

1. Create a new folder in `images/`
2. Add your `Dockerfile`
3. Update the workflow to build your image
4. Push to `main` - it will be automatically built and published

## Customization

### Personal Configuration

For truly personal configurations (like dotfiles), you can:

1. **VS Code Settings** - Configure dotfiles repository:
   ```json
   {
     "dotfiles.repository": "your-github-id/dotfiles",
     "dotfiles.targetPath": "~/dotfiles",
     "dotfiles.installCommand": "install.sh"
   }
   ```

2. **Mounts** - Mount your personal config files (already included in template):
   ```json
   "mounts": [
     "source=${localEnv:HOME}/.p10k.zsh,target=/root/.p10k.zsh,type=bind,readonly"
   ]
   ```

## License

MIT - See [LICENSE](LICENSE) file for details.

## Contributing

This is a personal repository, but feel free to fork and customize for your own needs!

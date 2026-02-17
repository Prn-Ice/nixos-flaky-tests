# MCP Server Configurations

Reference backup of MCP server configs used across AI tools.
When setting up a new machine, use this as the source of truth.

## Combined Config

```json
{
  "mcpServers": {
    "github-mcp-server": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-github-pat>"
      }
    },
    "nixos": {
      "command": "mcp-nixos",
      "args": []
    }
  }
}
```

> **Note**: Replace `<your-github-pat>` with a token from https://github.com/settings/tokens

### github-mcp-server
Provides GitHub API access (repos, issues, PRs, code search, etc.)

```json
{
  "command": "docker",
  "args": [
    "run", "-i", "--rm",
    "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
    "ghcr.io/github/github-mcp-server"
  ],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-github-pat>"
  }
}
```

> **Note**: Generate a PAT at https://github.com/settings/tokens. Never commit the actual token.

### nixos (mcp-nixos)
NixOS package/option search via the `mcp-nixos` flake input.

```json
{
  "command": "mcp-nixos",
  "args": []
}
```

Installed via `inputs.mcp-nixos` in `flake.nix` and added to `home.packages` in `modules/home-manager/programs/development.nix`.

## Config Locations

| Tool | Path | Status |
|---|---|---|
| Gemini (Antigravity) | `~/.gemini/antigravity/mcp_config.json` | Both servers configured |
| Windsurf (Codeium) | `~/.codeium/windsurf/mcp_config.json` | Empty — configure from above |
| VS Code | `~/.config/Code/User/mcp.json` | Empty — configure from above |

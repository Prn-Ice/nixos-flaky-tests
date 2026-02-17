# MCP Server Configurations

Reference backup of MCP server configs used across AI tools.
When setting up a new machine, use this as the source of truth.

## Combined Config (Redacted)

```json
{
  "mcpServers": {
    "atlassian-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.atlassian.com/v1/sse"
      ],
      "env": {},
      "disabled": "<tool-specific>"
    },
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp",
        "--api-key",
        "<context7-api-key>"
      ]
    },
    "mongodb-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "mongodb-mcp-server"
      ],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "<mongodb-connection-string>"
      },
      "disabled": true
    }
  }
}
```

> **Notes**
>
> - Do not commit real API keys or database connection strings.
> - `atlassian-mcp-server.disabled` currently differs by tool:
>   - Windsurf: `true`
>   - Antigravity: `false`

### atlassian-mcp-server
Atlassian MCP remote endpoint.

```json
{
  "command": "npx",
  "args": [
    "-y",
    "mcp-remote",
    "https://mcp.atlassian.com/v1/sse"
  ],
  "env": {},
  "disabled": "<tool-specific>"
}
```

### context7
Context7 documentation MCP server.

```json
{
  "command": "npx",
  "args": [
    "-y",
    "@upstash/context7-mcp",
    "--api-key",
    "<context7-api-key>"
  ]
}
```

### mongodb-mcp-server
MongoDB MCP server.

```json
{
  "command": "npx",
  "args": [
    "-y",
    "mongodb-mcp-server"
  ],
  "env": {
    "MDB_MCP_CONNECTION_STRING": "<mongodb-connection-string>"
  },
  "disabled": true
}
```

## Config Locations

| Tool | Path | Status |
|---|---|---|
| Gemini (Antigravity) | `~/.gemini/antigravity/mcp_config.json` | Configured (`atlassian` enabled) |
| Windsurf (Codeium) | `~/.codeium/windsurf/mcp_config.json` | Configured (`atlassian` disabled) |
| VS Code | `~/.config/Code/User/mcp.json` | Not managed by this workflow |

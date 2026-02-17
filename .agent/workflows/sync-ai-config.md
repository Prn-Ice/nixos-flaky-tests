---
description: Sync AI agent config between this repo and IDE config locations (Antigravity + Windsurf)
---

# Sync AI Config

Bidirectional sync between the repo (`.agent/`) and IDE config files.

## File Mapping

| Repo (source of truth) | Antigravity (Gemini) | Windsurf (Codeium) |
|---|---|---|
| `.agent/memories/global-rules.md` | `~/.gemini/GEMINI.md` | `~/.codeium/windsurf/memories/global_rules.md` |
| `.agent/memories/mcp-servers.md` (JSON block) | `~/.gemini/antigravity/mcp_config.json` | `~/.codeium/windsurf/mcp_config.json` |
| `.agent/workflows/*.md` | `.agent/workflows/` (read directly) | `~/.codeium/windsurf/global_workflows/*.md` |

## Steps

### 1. Check for IDE-side changes (IDE → Repo)

Compare each IDE config with the repo version. If the IDE has newer content, update the repo.

// turbo
```bash
diff ~/.gemini/GEMINI.md .agent/memories/global-rules.md || true
```

// turbo
```bash
diff ~/.codeium/windsurf/memories/global_rules.md .agent/memories/global-rules.md || true
```

// turbo
```bash
ls ~/.codeium/windsurf/global_workflows/
```

For each workflow in Windsurf that doesn't exist in `.agent/workflows/`, copy it to the repo:
```bash
cp ~/.codeium/windsurf/global_workflows/<new-workflow>.md .agent/workflows/
```

Check if either IDE has new MCP servers not in the repo's `mcp-servers.md`:
// turbo
```bash
cat ~/.gemini/antigravity/mcp_config.json
```
// turbo
```bash
cat ~/.codeium/windsurf/mcp_config.json
```

If new servers are found, update `.agent/memories/mcp-servers.md` with the new entries (redact tokens).

### 2. Sync repo to IDEs (Repo → IDE)

**Global rules** — copy repo rules to both IDEs:
```bash
cp .agent/memories/global-rules.md ~/.gemini/GEMINI.md
```
```bash
cp .agent/memories/global-rules.md ~/.codeium/windsurf/memories/global_rules.md
```

**Workflows** — Antigravity reads `.agent/workflows/` directly, only Windsurf needs syncing:
```bash
cp .agent/workflows/*.md ~/.codeium/windsurf/global_workflows/
```

**MCP config** — MCP configs contain secrets (tokens), so they should be set up manually per machine.
Use `.agent/memories/mcp-servers.md` as the reference for which servers to configure.

### 3. Verify
// turbo
```bash
echo "=== Antigravity ===" && cat ~/.gemini/GEMINI.md && echo -e "\n=== Windsurf rules ===" && cat ~/.codeium/windsurf/memories/global_rules.md && echo -e "\n=== Windsurf workflows ===" && ls ~/.codeium/windsurf/global_workflows/
```

### 4. Commit if repo was updated
If any changes were pulled from IDEs into the repo:
```bash
git add .agent/ && git commit -m "chore: sync agent config from IDEs"
```

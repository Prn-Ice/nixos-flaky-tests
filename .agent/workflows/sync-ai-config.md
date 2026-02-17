---
description: Sync AI agent config between this repo and IDE config locations (Antigravity + Windsurf)
---

# Sync AI Config

Bidirectional sync between the repo (`.agent/`) and IDE config files.

## File Mapping

| Repo | Antigravity (Gemini) | Windsurf (Codeium) |
|---|---|---|
| `.agent/memories/global-rules.md` | `~/.gemini/GEMINI.md` | `~/.codeium/windsurf/memories/global_rules.md` |
| `.agent/memories/mcp-servers.md` (JSON block) | `~/.gemini/antigravity/mcp_config.json` | `~/.codeium/windsurf/mcp_config.json` |
| `.agent/workflows/*.md` | `~/.gemini/antigravity/global_workflows/*.md` | `~/.codeium/windsurf/global_workflows/*.md` |
| `.agent/skills/*/SKILL.md` | n/a | `~/.codeium/windsurf/skills/*/SKILL.md` |

## Steps

### 1. Dry-run and backup (required before writes)

// turbo
```bash
ts=$(date +%Y%m%d-%H%M%S)
backup_dir=/tmp/sync-ai-config-backup-$ts
mkdir -p "$backup_dir"
echo "$backup_dir"
```

Copy current state before syncing:

```bash
cp .agent/memories/global-rules.md "$backup_dir/repo-global-rules.md.bak"
cp ~/.gemini/GEMINI.md "$backup_dir/GEMINI.md.bak"
cp ~/.codeium/windsurf/memories/global_rules.md "$backup_dir/windsurf-global_rules.md.bak"
cp -R .agent/workflows "$backup_dir/repo-workflows.bak"
cp -R ~/.gemini/antigravity/global_workflows "$backup_dir/antigravity-global_workflows.bak"
cp -R ~/.codeium/windsurf/global_workflows "$backup_dir/windsurf-global_workflows.bak"
cp -R .agent/skills "$backup_dir/repo-skills.bak"
cp -R ~/.codeium/windsurf/skills "$backup_dir/windsurf-skills.bak"
```

### 2. Review differences (no writes)

Compare rules:

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
echo "=== Repo workflows ===" && ls .agent/workflows/
echo "=== Antigravity workflows ===" && ls ~/.gemini/antigravity/global_workflows/
echo "=== Windsurf workflows ===" && ls ~/.codeium/windsurf/global_workflows/
```

// turbo
```bash
echo "=== Repo skills ===" && ls .agent/skills/
echo "=== Windsurf skills ===" && ls ~/.codeium/windsurf/skills/
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

If new servers are found, update `.agent/memories/mcp-servers.md` with redacted entries and note per-tool differences.

### 3. Sync rules (intentional merge, then copy)

Update `.agent/memories/global-rules.md` intentionally (do not blindly overwrite), then copy the finalized version:

```bash
cp .agent/memories/global-rules.md ~/.gemini/GEMINI.md
cp .agent/memories/global-rules.md ~/.codeium/windsurf/memories/global_rules.md
```

### 4. Sync workflows (bidirectional additive, no overwrite)

First pull IDE-only workflows into repo (missing files only):

```bash
for f in ~/.gemini/antigravity/global_workflows/*.md; do
  base=$(basename "$f")
  [ -f ".agent/workflows/$base" ] || cp "$f" .agent/workflows/
done

for f in ~/.codeium/windsurf/global_workflows/*.md; do
  base=$(basename "$f")
  [ -f ".agent/workflows/$base" ] || cp "$f" .agent/workflows/
done
```

Then fan out repo workflows to both IDEs (missing files only):

```bash
for f in .agent/workflows/*.md; do
  base=$(basename "$f")
  [ -f ~/.gemini/antigravity/global_workflows/$base ] || cp "$f" ~/.gemini/antigravity/global_workflows/
  [ -f ~/.codeium/windsurf/global_workflows/$base ] || cp "$f" ~/.codeium/windsurf/global_workflows/
done
```

### 5. Sync skills (bidirectional additive, no overwrite)

Repo -> Windsurf (missing folders only):

```bash
for d in .agent/skills/*; do
  base=$(basename "$d")
  [ -d ~/.codeium/windsurf/skills/$base ] || cp -R "$d" ~/.codeium/windsurf/skills/
done
```

Windsurf -> Repo (missing folders only):

```bash
for d in ~/.codeium/windsurf/skills/*; do
  base=$(basename "$d")
  [ -d .agent/skills/$base ] || cp -R "$d" .agent/skills/
done
```

### 6. MCP docs only (no machine config writes)

Keep `~/.gemini/antigravity/mcp_config.json` and `~/.codeium/windsurf/mcp_config.json` machine-specific.
Update only `.agent/memories/mcp-servers.md` with redacted values.

### 7. Verify
// turbo
```bash
echo "=== Antigravity rules ===" && cat ~/.gemini/GEMINI.md
echo -e "\n=== Windsurf rules ===" && cat ~/.codeium/windsurf/memories/global_rules.md
echo -e "\n=== Repo workflows ===" && ls .agent/workflows/
echo -e "\n=== Antigravity workflows ===" && ls ~/.gemini/antigravity/global_workflows/
echo -e "\n=== Windsurf workflows ===" && ls ~/.codeium/windsurf/global_workflows/
echo -e "\n=== Repo skills ===" && ls .agent/skills/
echo -e "\n=== Windsurf skills ===" && ls ~/.codeium/windsurf/skills/
```

### 8. Commit if repo was updated
If any changes were pulled from IDEs into the repo:
```bash
git add .agent/ && git commit -m "chore: sync agent config from IDEs"
```

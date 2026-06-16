---
description: Sync AI agent config between this repo and IDE config locations (Antigravity + Windsurf + Claude Code)
---

# Sync AI Config

Bidirectional sync between the repo (`.agent/`) and IDE config files.

## File Mapping

| Repo | Antigravity (Gemini) | Windsurf (Codeium) | Claude Code |
|---|---|---|---|
| `.agent/memories/global-rules.md` | `~/.gemini/GEMINI.md` | `~/.codeium/windsurf/memories/global_rules.md` | `~/.claude/CLAUDE.md` |
| `.agent/memories/mcp-servers.md` (JSON block) | `~/.gemini/antigravity/mcp_config.json` | `~/.codeium/windsurf/mcp_config.json` | (machine-specific, docs only) |
| `.agent/workflows/*.md` | `~/.gemini/antigravity/global_workflows/*.md` | `~/.codeium/windsurf/global_workflows/*.md` | `~/.claude/commands/*.md` |
| `.agent/skills/*/SKILL.md` | n/a | `~/.codeium/windsurf/skills/*/SKILL.md` | `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/synced-skills/skills/*/SKILL.md` |

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
cp ~/.gemini/GEMINI.md "$backup_dir/GEMINI.md.bak" 2>/dev/null || true
cp ~/.codeium/windsurf/memories/global_rules.md "$backup_dir/windsurf-global_rules.md.bak" 2>/dev/null || true
cp ~/.claude/CLAUDE.md "$backup_dir/claude-CLAUDE.md.bak" 2>/dev/null || true
cp -R .agent/workflows "$backup_dir/repo-workflows.bak"
cp -R ~/.gemini/antigravity/global_workflows "$backup_dir/antigravity-global_workflows.bak" 2>/dev/null || true
cp -R ~/.codeium/windsurf/global_workflows "$backup_dir/windsurf-global_workflows.bak" 2>/dev/null || true
cp -R ~/.claude/commands "$backup_dir/claude-commands.bak" 2>/dev/null || true
cp -R .agent/skills "$backup_dir/repo-skills.bak"
cp -R ~/.codeium/windsurf/skills "$backup_dir/windsurf-skills.bak" 2>/dev/null || true
```

### 2. Review differences (no writes)

Compare rules across all tools:

// turbo
```bash
diff ~/.gemini/GEMINI.md .agent/memories/global-rules.md || true
diff ~/.codeium/windsurf/memories/global_rules.md .agent/memories/global-rules.md || true
diff ~/.claude/CLAUDE.md .agent/memories/global-rules.md || true
```

// turbo
```bash
echo "=== Repo workflows ===" && ls .agent/workflows/
echo "=== Antigravity workflows ===" && ls ~/.gemini/antigravity/global_workflows/ 2>/dev/null
echo "=== Windsurf workflows ===" && ls ~/.codeium/windsurf/global_workflows/ 2>/dev/null
echo "=== Claude commands ===" && ls ~/.claude/commands/ 2>/dev/null || echo "(empty)"
```

// turbo
```bash
echo "=== Repo skills ===" && ls .agent/skills/
echo "=== Windsurf skills ===" && ls ~/.codeium/windsurf/skills/ 2>/dev/null
echo "=== Claude synced-skills ===" && ls ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/synced-skills/skills/ 2>/dev/null || echo "(empty)"
```

Check for new MCP servers:
// turbo
```bash
cat ~/.gemini/antigravity/mcp_config.json 2>/dev/null
cat ~/.codeium/windsurf/mcp_config.json 2>/dev/null
```

If new servers are found, update `.agent/memories/mcp-servers.md` with redacted entries and note per-tool differences.

### 3. Sync rules (intentional merge, then copy)

Update `.agent/memories/global-rules.md` intentionally (do not blindly overwrite), then copy:

```bash
cp .agent/memories/global-rules.md ~/.gemini/GEMINI.md
cp .agent/memories/global-rules.md ~/.codeium/windsurf/memories/global_rules.md
cp .agent/memories/global-rules.md ~/.claude/CLAUDE.md
```

Note: If `~/.claude/CLAUDE.md` has Claude Code-specific sections (e.g., `## Session Start`), preserve them by merging rather than overwriting.

### 4. Sync workflows (bidirectional additive, no overwrite)

Pull IDE-only workflows into repo (missing files only):

```bash
for f in ~/.gemini/antigravity/global_workflows/*.md 2>/dev/null; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [ -f ".agent/workflows/$base" ] || cp "$f" .agent/workflows/
done

for f in ~/.codeium/windsurf/global_workflows/*.md 2>/dev/null; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [ -f ".agent/workflows/$base" ] || cp "$f" .agent/workflows/
done

for f in ~/.claude/commands/*.md 2>/dev/null; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [ -f ".agent/workflows/$base" ] || cp "$f" .agent/workflows/
done
```

Fan out repo workflows to all IDEs (missing files only):

```bash
mkdir -p ~/.claude/commands
for f in .agent/workflows/*.md; do
  base=$(basename "$f")
  [ -f ~/.gemini/antigravity/global_workflows/$base ] || cp "$f" ~/.gemini/antigravity/global_workflows/
  [ -f ~/.codeium/windsurf/global_workflows/$base ] || cp "$f" ~/.codeium/windsurf/global_workflows/
  [ -f ~/.claude/commands/$base ] || cp "$f" ~/.claude/commands/
done
```

### 5. Sync skills (bidirectional additive, no overwrite)

Pull Windsurf-only skills into repo:

```bash
for d in ~/.codeium/windsurf/skills/*; do
  [ -d "$d" ] || continue
  base=$(basename "$d")
  [ -d ".agent/skills/$base" ] || cp -R "$d" .agent/skills/
done
```

Fan out repo skills to Windsurf and Claude Code's synced-skills plugin:

```bash
synced_dir=~/.claude/plugins/marketplaces/claude-plugins-official/plugins/synced-skills/skills
cache_dir=~/.claude/plugins/cache/claude-plugins-official/synced-skills/local/skills
mkdir -p "$synced_dir" "$cache_dir"

for d in .agent/skills/*; do
  [ -d "$d" ] || continue
  base=$(basename "$d")
  # Windsurf
  [ -d ~/.codeium/windsurf/skills/$base ] || cp -R "$d" ~/.codeium/windsurf/skills/
  # Claude Code (always update to keep in sync)
  mkdir -p "$synced_dir/$base" "$cache_dir/$base"
  cp "$d/SKILL.md" "$synced_dir/$base/SKILL.md"
  cp "$d/SKILL.md" "$cache_dir/$base/SKILL.md"
done
```

First-time only: register `synced-skills` in `~/.claude/plugins/installed_plugins.json` and enable it in `~/.claude/settings.json` (follow the `nixos` plugin entry as a template).

### 6. MCP docs only (no machine config writes)

Keep MCP config files machine-specific.
Update only `.agent/memories/mcp-servers.md` with redacted values.

### 7. Verify

// turbo
```bash
echo "=== Antigravity rules ===" && cat ~/.gemini/GEMINI.md 2>/dev/null
echo -e "\n=== Windsurf rules ===" && cat ~/.codeium/windsurf/memories/global_rules.md 2>/dev/null
echo -e "\n=== Claude rules ===" && cat ~/.claude/CLAUDE.md 2>/dev/null
echo -e "\n=== Repo workflows ===" && ls .agent/workflows/
echo -e "\n=== Antigravity workflows ===" && ls ~/.gemini/antigravity/global_workflows/ 2>/dev/null
echo -e "\n=== Windsurf workflows ===" && ls ~/.codeium/windsurf/global_workflows/ 2>/dev/null
echo -e "\n=== Claude commands ===" && ls ~/.claude/commands/ 2>/dev/null
echo -e "\n=== Repo skills ===" && ls .agent/skills/
echo -e "\n=== Windsurf skills ===" && ls ~/.codeium/windsurf/skills/ 2>/dev/null
echo -e "\n=== Claude synced-skills ===" && ls ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/synced-skills/skills/ 2>/dev/null
```

### 8. Commit if repo was updated

```bash
git add .agent/ && git commit -m "chore: sync agent config from IDEs"
```

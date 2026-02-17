#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-ai-config.sh [--dry-run|--apply]

Modes:
  --dry-run  Show planned sync operations (default)
  --apply    Execute sync operations

Behavior:
  - Backs up current repo/IDE files to /tmp/sync-ai-config-backup-<timestamp>/
  - Syncs workflows bidirectionally (repo <-> antigravity/windsurf), additive only
  - Syncs skills bidirectionally (repo <-> windsurf), additive only
  - Syncs global rules repo -> antigravity/windsurf
  - Never overwrites existing workflow/skill files
  - Does not edit machine MCP configs
EOF
}

MODE="dry-run"
if [[ "${1:-}" == "--apply" ]]; then
  MODE="apply"
elif [[ "${1:-}" == "--dry-run" || -z "${1:-}" ]]; then
  MODE="dry-run"
elif [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
else
  echo "Unknown argument: $1" >&2
  usage
  exit 1
fi

REPO_ROOT="$(pwd)"
[[ -d "$REPO_ROOT/.agent" ]] || { echo "Run from repo root (missing .agent/)" >&2; exit 1; }

REPO_RULES="$REPO_ROOT/.agent/memories/global-rules.md"
REPO_WORKFLOWS="$REPO_ROOT/.agent/workflows"
REPO_SKILLS="$REPO_ROOT/.agent/skills"

GEMINI_RULES="$HOME/.gemini/GEMINI.md"
GEMINI_WORKFLOWS="$HOME/.gemini/antigravity/global_workflows"
GEMINI_MCP="$HOME/.gemini/antigravity/mcp_config.json"

WINDSURF_RULES="$HOME/.codeium/windsurf/memories/global_rules.md"
WINDSURF_WORKFLOWS="$HOME/.codeium/windsurf/global_workflows"
WINDSURF_SKILLS="$HOME/.codeium/windsurf/skills"
WINDSURF_MCP="$HOME/.codeium/windsurf/mcp_config.json"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/tmp/sync-ai-config-backup-$TS"

msg() { printf '%s\n' "$*"; }
act() {
  if [[ "$MODE" == "apply" ]]; then
    eval "$1"
  else
    msg "[dry-run] $1"
  fi
}

require_dir() {
  local d="$1"
  [[ -d "$d" ]] || { echo "Required directory missing: $d" >&2; exit 1; }
}

require_file() {
  local f="$1"
  [[ -f "$f" ]] || { echo "Required file missing: $f" >&2; exit 1; }
}

copy_if_missing_file() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]]; then
    return 0
  fi
  act "cp \"$src\" \"$dst\""
  msg "  + ${dst}"
}

copy_if_missing_dir() {
  local src="$1" dst_parent="$2"
  local base
  base="$(basename "$src")"
  if [[ -d "$dst_parent/$base" ]]; then
    return 0
  fi
  act "cp -R \"$src\" \"$dst_parent/\""
  msg "  + ${dst_parent}/$base"
}

msg "Mode: $MODE"
msg "Repo: $REPO_ROOT"

require_file "$REPO_RULES"
require_dir "$REPO_WORKFLOWS"
require_dir "$REPO_SKILLS"
require_file "$GEMINI_RULES"
require_file "$WINDSURF_RULES"
require_dir "$GEMINI_WORKFLOWS"
require_dir "$WINDSURF_WORKFLOWS"
require_dir "$WINDSURF_SKILLS"
require_file "$GEMINI_MCP"
require_file "$WINDSURF_MCP"

msg "\n== Backups =="
act "mkdir -p \"$BACKUP_DIR\""
act "cp \"$REPO_RULES\" \"$BACKUP_DIR/repo-global-rules.md.bak\""
act "cp \"$GEMINI_RULES\" \"$BACKUP_DIR/GEMINI.md.bak\""
act "cp \"$WINDSURF_RULES\" \"$BACKUP_DIR/windsurf-global_rules.md.bak\""
act "cp -R \"$REPO_WORKFLOWS\" \"$BACKUP_DIR/repo-workflows.bak\""
act "cp -R \"$GEMINI_WORKFLOWS\" \"$BACKUP_DIR/antigravity-global_workflows.bak\""
act "cp -R \"$WINDSURF_WORKFLOWS\" \"$BACKUP_DIR/windsurf-global_workflows.bak\""
act "cp -R \"$REPO_SKILLS\" \"$BACKUP_DIR/repo-skills.bak\""
act "cp -R \"$WINDSURF_SKILLS\" \"$BACKUP_DIR/windsurf-skills.bak\""
msg "Backup dir: $BACKUP_DIR"

msg "\n== Rules sync (repo -> IDEs) =="
act "cp \"$REPO_RULES\" \"$GEMINI_RULES\""
act "cp \"$REPO_RULES\" \"$WINDSURF_RULES\""

shopt -s nullglob

msg "\n== Workflow sync (bidirectional additive) =="
msg "Antigravity -> Repo (missing only):"
for f in "$GEMINI_WORKFLOWS"/*.md; do
  copy_if_missing_file "$f" "$REPO_WORKFLOWS/$(basename "$f")"
done

msg "Windsurf -> Repo (missing only):"
for f in "$WINDSURF_WORKFLOWS"/*.md; do
  copy_if_missing_file "$f" "$REPO_WORKFLOWS/$(basename "$f")"
done

msg "Repo -> Antigravity/Windsurf (missing only):"
for f in "$REPO_WORKFLOWS"/*.md; do
  base="$(basename "$f")"
  copy_if_missing_file "$f" "$GEMINI_WORKFLOWS/$base"
  copy_if_missing_file "$f" "$WINDSURF_WORKFLOWS/$base"
done

msg "\n== Skills sync (bidirectional additive) =="
msg "Repo -> Windsurf (missing only):"
for d in "$REPO_SKILLS"/*; do
  [[ -d "$d" ]] || continue
  copy_if_missing_dir "$d" "$WINDSURF_SKILLS"
done

msg "Windsurf -> Repo (missing only):"
for d in "$WINDSURF_SKILLS"/*; do
  [[ -d "$d" ]] || continue
  copy_if_missing_dir "$d" "$REPO_SKILLS"
done

shopt -u nullglob

msg "\n== MCP note =="
msg "No machine MCP configs are modified by this script."
msg "Review and update .agent/memories/mcp-servers.md manually with redacted values if needed."

msg "\n== Verification =="
act "echo '=== Repo workflows ===' && ls \"$REPO_WORKFLOWS\""
act "echo '=== Antigravity workflows ===' && ls \"$GEMINI_WORKFLOWS\""
act "echo '=== Windsurf workflows ===' && ls \"$WINDSURF_WORKFLOWS\""
act "echo '=== Repo skills ===' && ls \"$REPO_SKILLS\""
act "echo '=== Windsurf skills ===' && ls \"$WINDSURF_SKILLS\""

msg "\nDone ($MODE)."

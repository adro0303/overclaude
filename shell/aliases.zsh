# overclaude: shell helpers for opening a project with mobile control
# wired up. Source this file from your ~/.zshrc or ~/.bashrc (install.sh does
# this for you). Assumes projects live under $OVERCLAUDE_PROJECTS_DIR
# (default: ~/Projects) -- override in your shell rc before sourcing if not.

: "${OVERCLAUDE_PROJECTS_DIR:=$HOME/Projects}"
: "${OVERCLAUDE_GRAPH_THRESHOLD:=40}"

# Auto-wire the code-graph MCP for projects big enough to benefit from it --
# creates .mcp.json only, and only past a file-count threshold. Never
# overwrites one you already have, never asks. Small projects are left
# alone on purpose: a standing MCP server carries a fixed tool-schema cost
# every session, and it isn't worth paying that below the threshold. Once
# .mcp.json exists, the graph indexes itself the first time Claude actually
# needs structural context (see the codebase-memory-mcp SessionStart
# reminder) -- no need to ask for that part either.
_overclaude_project_file_count() {
  if [ -d ".git" ] && command -v git >/dev/null 2>&1; then
    git ls-files 2>/dev/null | wc -l | tr -d ' '
  else
    find . -type f \
      -not -path '*/node_modules/*' -not -path '*/.git/*' \
      -not -path '*/vendor/*' -not -path '*/dist/*' -not -path '*/build/*' \
      -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' \
      -not -path '*/target/*' -not -path '*/.next/*' -not -path '*/coverage/*' \
      2>/dev/null | wc -l | tr -d ' '
  fi
}

_overclaude_maybe_wire_graph() {
  command -v codebase-memory-mcp >/dev/null 2>&1 || return 0
  [ -f ".mcp.json" ] && return 0
  local count
  count="$(_overclaude_project_file_count)"
  if [ "${count:-0}" -ge "$OVERCLAUDE_GRAPH_THRESHOLD" ] 2>/dev/null; then
    printf '{"mcpServers": {"codebase-memory-mcp": {"command": "codebase-memory-mcp", "args": []}}}\n' > .mcp.json
    echo "overclaude: $count files >= $OVERCLAUDE_GRAPH_THRESHOLD -- wired the code graph (.mcp.json)."
  fi
}

# cproj <project>: cd into the project and (re)connect Remote Control so it's
# reachable from the official Claude mobile app / claude.ai/code. Uses a git
# worktree per spawned session when the project has git, same-dir otherwise.
# Any number of projects can have Remote Control active at once.
cproj() {
  local proj="$1"
  if [ -z "$proj" ]; then
    echo "Usage: cproj <project-name>"
    return 1
  fi
  local dir="$OVERCLAUDE_PROJECTS_DIR/$proj"
  if [ ! -d "$dir" ]; then
    echo "Not found: $dir"
    return 1
  fi
  cd "$dir" || return 1
  _overclaude_maybe_wire_graph
  local spawn_mode="same-dir"
  [ -d ".git" ] && spawn_mode="worktree"
  claude remote-control --name "$proj" --spawn="$spawn_mode" --continue 2>/dev/null \
    || claude remote-control --name "$proj" --spawn="$spawn_mode"
}

# cprojs: list every active Claude Code session (native "claude agents" view).
alias cprojs='claude agents'

# ctel <project>: move the Telegram channel to that project, in the
# background. Only one project can hold the bot connection at a time
# (Telegram doesn't allow two long-pollers on the same bot token), so this
# stops the previous session first. Requires the telegram channel plugin
# already installed and paired -- see docs/telegram-channel.md.
ctel() {
  local proj="$1"
  if [ -z "$proj" ]; then
    echo "Usage: ctel <project-name>"
    return 1
  fi
  local dir="$OVERCLAUDE_PROJECTS_DIR/$proj"
  if [ ! -d "$dir" ]; then
    echo "Not found: $dir"
    return 1
  fi
  local marker="$HOME/.claude/channels/telegram/.active_project"
  if [ -f "$marker" ]; then
    local prev_id
    prev_id="$(cut -d: -f1 < "$marker" 2>/dev/null)"
    [ -n "$prev_id" ] && claude stop "$prev_id" 2>/dev/null
  fi
  cd "$dir" || return 1
  _overclaude_maybe_wire_graph
  local out sid
  out="$(claude --bg --channels plugin:telegram@claude-plugins-official \
    --allowedTools "mcp__telegram__reply" --name "telegram-$proj" 2>&1)"
  echo "$out"
  sid="$(echo "$out" | sed -n 's/^backgrounded · \([a-f0-9]*\).*/\1/p')"
  [ -n "$sid" ] && echo "${sid}:${proj}" > "$marker"
}

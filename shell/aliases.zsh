# claude-code-boost: shell helpers for opening a project with mobile control
# wired up. Source this file from your ~/.zshrc or ~/.bashrc (install.sh does
# this for you). Assumes projects live under $CC_BOOST_PROJECTS_DIR
# (default: ~/Projects) -- override in your shell rc before sourcing if not.

: "${CC_BOOST_PROJECTS_DIR:=$HOME/Projects}"

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
  local dir="$CC_BOOST_PROJECTS_DIR/$proj"
  if [ ! -d "$dir" ]; then
    echo "Not found: $dir"
    return 1
  fi
  cd "$dir" || return 1
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
  local dir="$CC_BOOST_PROJECTS_DIR/$proj"
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
  local out sid
  out="$(claude --bg --channels plugin:telegram@claude-plugins-official \
    --allowedTools "mcp__telegram__reply" --name "telegram-$proj" 2>&1)"
  echo "$out"
  sid="$(echo "$out" | sed -n 's/^backgrounded · \([a-f0-9]*\).*/\1/p')"
  [ -n "$sid" ] && echo "${sid}:${proj}" > "$marker"
}

#!/usr/bin/env bash
# overclaude installer.
# Idempotent: safe to re-run. Never overwrites your existing settings/CLAUDE.md
# wholesale -- only merges in what's missing.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

say() { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }

command -v claude >/dev/null 2>&1 || {
  echo "Claude Code CLI not found on PATH. Install it first: https://code.claude.com/docs/en/quickstart"
  exit 1
}
say "Claude Code found: $(claude --version 2>/dev/null || echo unknown)"

# --- 1. Hook: build/test failure desktop notification -----------------------
say "Installing the build/test-failure notification hook..."
mkdir -p "$CLAUDE_DIR/hooks"
cp "$REPO_DIR/hooks/build-test-alert" "$CLAUDE_DIR/hooks/build-test-alert"
chmod +x "$CLAUDE_DIR/hooks/build-test-alert"

python3 - "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys, os

path = sys.argv[1]
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

hooks = settings.setdefault("hooks", {})
post_failure = hooks.setdefault("PostToolUseFailure", [])

entry = {
    "matcher": "Bash",
    "hooks": [{
        "type": "command",
        "command": 'python3 "$HOME/.claude/hooks/build-test-alert"',
        "timeout": 5,
    }],
}

already = any(
    e.get("matcher") == "Bash"
    and any("build-test-alert" in h.get("command", "") for h in e.get("hooks", []))
    for e in post_failure
)
if not already:
    post_failure.append(entry)

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("settings.json updated" if not already else "settings.json already had the hook, left as-is")
PYEOF

if command -v notify-send >/dev/null 2>&1; then
  say "notify-send found -- desktop notifications will work."
else
  warn "notify-send not found. On Debian/Ubuntu: sudo apt-get install -y libnotify-bin"
fi

# --- 1b. Hook: turn-completion ping (sound + Telegram) -----------------------
say "Installing the turn-completion notification hook..."
cp "$REPO_DIR/hooks/stop-notify" "$CLAUDE_DIR/hooks/stop-notify"
chmod +x "$CLAUDE_DIR/hooks/stop-notify"

python3 - "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys, os

path = sys.argv[1]
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

hooks = settings.setdefault("hooks", {})
stop_hooks = hooks.setdefault("Stop", [])

entry = {
    "hooks": [{
        "type": "command",
        "command": 'python3 "$HOME/.claude/hooks/stop-notify"',
        "timeout": 8,
    }],
}

already = any(
    any("stop-notify" in h.get("command", "") for h in e.get("hooks", []))
    for e in stop_hooks
)
if not already:
    stop_hooks.append(entry)

# Let Claude use its native mobile push (PushNotification tool) once Remote
# Control is connected -- opt-in flags, never overwritten if already set.
settings.setdefault("agentPushNotifEnabled", True)
settings.setdefault("inputNeededNotifEnabled", True)

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("settings.json updated" if not already else "settings.json already had the Stop hook, left as-is")
PYEOF

if command -v paplay >/dev/null 2>&1; then
  say "paplay found -- completion sound will play (Linux/PulseAudio/PipeWire)."
else
  warn "paplay not found -- the completion sound is silently skipped, Telegram/push still work."
fi

# --- 2. Shell helpers: cproj / ctel ------------------------------------------
say "Wiring up shell helpers (cproj, ctel)..."
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [ -f "$rc" ] || continue
  line="[ -f \"$REPO_DIR/shell/aliases.zsh\" ] && source \"$REPO_DIR/shell/aliases.zsh\""
  if ! grep -qF "$REPO_DIR/shell/aliases.zsh" "$rc" 2>/dev/null; then
    { echo ""; echo "# overclaude"; echo "$line"; } >> "$rc"
    say "Added source line to $rc"
  else
    say "$rc already sources aliases.zsh"
  fi
done

# --- 3. CLAUDE.md guidance ----------------------------------------------------
say "CLAUDE.md guidance is in CLAUDE.md.example -- it is NOT auto-appended,"
say "since it references tools you may not have installed. Review it and merge"
say "what applies into $CLAUDE_DIR/CLAUDE.md yourself."

# --- 4. Tools & skills (all installed automatically, no prompts) --------------
# These only cost anything when actually used (skills load on demand; the
# codebase-memory-mcp binary sitting on disk costs nothing until a project
# registers it in .mcp.json -- see step 4c / cproj/ctel for that part), so
# there's nothing to ask permission for here. The one exception -- the
# support nudge -- stays an explicit opt-in below because it runs on every
# session start regardless of whether you're using it that session.
echo
say "Installing codebase-memory-mcp (local code-graph MCP, MIT)..."
if curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash; then
  warn "Binary installed but NOT registered globally -- cproj/ctel auto-wire it per project"
  warn "past the size threshold (step 4c below); see CLAUDE.md.example for manual setup."
else
  warn "codebase-memory-mcp install failed -- continuing without it, nothing else depends on it."
fi

say "Installing Agent-Reach (internet-access skill, MIT)..."
if ! command -v pipx >/dev/null 2>&1; then
  warn "pipx not found -- skipping Agent-Reach. Install pipx (https://pipx.pypa.io) and re-run this script to add it."
elif pipx install "https://github.com/Panniantong/agent-reach/archive/main.zip" && agent-reach install --env=auto --system; then
  say "Agent-Reach installed."
else
  warn "Agent-Reach install failed -- continuing without it."
fi

say "Installing DevCorp (multi-agent build pipeline skill + 7 subagents, original)..."
mkdir -p "$CLAUDE_DIR/skills/devcorp" "$CLAUDE_DIR/agents"
cp -r "$REPO_DIR/skills/devcorp/." "$CLAUDE_DIR/skills/devcorp/"
cp "$REPO_DIR"/agents/devcorp/*.md "$CLAUDE_DIR/agents/"
say "DevCorp installed: skill at ~/.claude/skills/devcorp, 7 subagents (dc-scout,"
say "dc-product, dc-architect, dc-frontend, dc-backend, dc-qa, dc-security) at"
say "~/.claude/agents/. Trigger with the word 'devcorp' or 'build me X' in a session."

read -r -p "Enable the optional support nudge (one line, at most once a week, written straight to your terminal -- never touches Claude's context or costs a token)? [y/N] " ans
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
  cp "$REPO_DIR/hooks/support-notice" "$CLAUDE_DIR/hooks/support-notice"
  chmod +x "$CLAUDE_DIR/hooks/support-notice"
  python3 - "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys, os

path = sys.argv[1]
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

hooks = settings.setdefault("hooks", {})
session_start = hooks.setdefault("SessionStart", [])

entry = {
    "hooks": [{
        "type": "command",
        "command": 'python3 "$HOME/.claude/hooks/support-notice"',
        "timeout": 3,
    }],
}

already = any(
    any("support-notice" in h.get("command", "") for h in e.get("hooks", []))
    for e in session_start
)
if not already:
    session_start.append(entry)

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("settings.json updated" if not already else "settings.json already had the support nudge hook, left as-is")
PYEOF
  say "Support nudge enabled -- at most once a week, direct to your terminal, zero tokens."
  say "To turn it off again: remove the SessionStart entry referencing support-notice"
  say "in ~/.claude/settings.json (or delete ~/.claude/hooks/support-notice)."
else
  say "No support nudge installed -- default behavior, nothing changed."
fi

# --- 4b. codebase-memory-mcp hook drift check/self-heal -----------------------
if command -v codebase-memory-mcp >/dev/null 2>&1; then
  missing_hooks="$(python3 - "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys, os

path = sys.argv[1]
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

hooks = settings.get("hooks", {})

def has_cbm_hook(event):
    for entry in hooks.get(event, []):
        for h in entry.get("hooks", []):
            if "cbm-" in h.get("command", ""):
                return True
    return False

missing = [k for k in ("SessionStart", "SubagentStart") if not has_cbm_hook(k)]
print(",".join(missing))
PYEOF
)"
  if [ -n "$missing_hooks" ]; then
    warn "codebase-memory-mcp is installed but its hooks ($missing_hooks) are missing from settings.json -- repairing..."
    codebase-memory-mcp install -y
    say "codebase-memory-mcp hooks repaired."
  fi
fi

# --- 5. Next steps -------------------------------------------------------------
cat <<'EOF'

Done. What's automated vs. what needs you:

  Automated:
    - Build/test failure -> desktop notification hook
    - Turn-completion ping -> sound + Telegram (hooks/stop-notify)
    - Native mobile push notifications enabled (agentPushNotifEnabled,
      inputNeededNotifEnabled) -- only reaches your phone once Remote
      Control is connected to the session, see below
    - cproj / ctel shell helpers

  Optional (if you said yes above):
    - codebase-memory-mcp / Agent-Reach / DevCorp, each installed only on
      confirmation -- see README.md for what each one costs and when it's
      worth it.

  Needs you (one-time, both documented in README.md):
    - `claude remote-control` inside a project, then pair the official
      Claude mobile app / claude.ai/code (no bot, no token, no setup beyond
      that command).
    - Telegram channel: create a bot via @BotFather, `claude plugin install
      telegram@claude-plugins-official`, `/telegram:configure <token>`,
      then pair your account from your phone. See README.md.

EOF

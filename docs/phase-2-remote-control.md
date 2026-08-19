# Phase 2: remote control & mobile

The instinct for "control my coding agent from my phone" is to build a
Telegram bot and wire it to a `tmux` session by scraping terminal output for
`[y/n]` prompts. Before building that, it's worth checking whether the tool
already does it better — in this case, it does.

## The native features this project builds on

- **[Remote Control](https://code.claude.com/docs/en/remote-control)**
  (`claude remote-control`) — connects the official Claude mobile app or
  `claude.ai/code` to a session running on your machine. Outbound HTTPS only,
  no listening port, short-lived credentials, biometric "Trusted Devices."
  Up to 32 concurrent sessions, each optionally isolated in its own git
  worktree. Requires a Pro/Max/Team/Enterprise login (not a bare API key).
- **[Channels](https://code.claude.com/docs/en/channels)**
  (`claude --channels plugin:telegram@claude-plugins-official`) — official,
  Anthropic-maintained plugins for Telegram/Discord/iMessage. A channel is
  an MCP server that pushes events into your running session. Pairing is by
  one-time code tied to a numeric sender ID (not a chat/group ID), and
  approved senders can also approve/deny permission prompts remotely —
  documented explicitly as a capability, not an accident.
- **Native background sessions** (`claude --bg`, `claude agents`) —
  structured session state (`Working` / `Needs input` / `Idle` /
  `Completed` / `Failed` / `Stopped`), survives closing the terminal,
  automatic per-session worktree isolation. No `tmux`, no
  `capture-pane` regex-parsing a TUI that changes between versions.
- **Hooks** (`PermissionRequest`, `Notification`, `PostToolUseFailure`,
  and the `type: "http"` hook that lets any of these block on a POST to a
  local service) — the actual mechanism for intercepting approvals and
  failures with structured JSON, not text scraping.

## What was rejected, and why

| Considered | Rejected because |
|---|---|
| Custom Telegram bot from scratch | Reimplements, worse, what the official Channels plugin already does with a proper request-ID + allowlist protocol |
| `tmux`/`screen` as the persistence layer | `claude --bg` / `claude agents` already gives structured state; `tmux capture-pane` is fragile (depends on spinner/ANSI rendering that changes between CLI versions) |
| `systemd` running `claude` directly | Claude Code is an interactive TUI; a systemd unit has no clean way to feed it input or read its screen |
| `claude-squad`, the `Tmux-Orchestrator` family | Local multi-session TUIs for people at their desk — neither solves the actual gap (mobile/remote access) |
| Community bots with heavy terminal-scraping and <50 stars | Worse security model than the official Channels protocol, for no added capability |
| Ads/sponsored messages in the terminal | No legitimate model exists without third-party install volume; the only technical injection point (hooks) costs real tokens per use |

## What actually ships

- `hooks/build-test-alert` — a scoped `PostToolUseFailure` hook: fires a
  desktop notification for failed test/build commands specifically, silent
  for everything else. Read-only over the tool result; it has no approval
  authority.
- `shell/aliases.zsh` — `cproj` (Remote Control per project, any number
  concurrently) and `ctel` (moves the single Telegram channel connection
  between projects, since a bot token can only have one active listener).

## One real constraint worth knowing

Channels are a **research preview**: the `--channels` flag and its wire
protocol aren't finalized and don't appear in `claude --help` yet, even
though they work. Remote Control is not a preview feature and is the more
stable of the two mobile paths.

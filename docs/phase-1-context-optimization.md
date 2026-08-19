# Phase 1: context & token optimization

Five candidate projects were cloned and read (not just their READMEs) before
deciding what to integrate: `codebase-memory-mcp`, `Graphify`, `OmniRoute`,
`Agent-Reach`, and `Orca`. Two were adopted, three were rejected — with
reasons, not vibes.

## Codebase understanding: codebase-memory-mcp vs. Graphify

Both build a code knowledge graph via tree-sitter and expose it over MCP.
Same problem, solved twice — only one gets installed.

| | codebase-memory-mcp | Graphify |
|---|---|---|
| Language / runtime | Pure C, no runtime | Python |
| Infra | Vendored SQLite, no external deps | NetworkX in-memory |
| Token reduction (own benchmarks) | 10x fewer tokens, 2.1x fewer tool calls vs. file-by-file (arXiv:2603.27277, 31 repos) | 71.5x on a mixed 52-file corpus; ~1x on small corpora (their own benchmark) |
| Maturity | 6,768 tests, SLSA 3, OpenSSF Scorecard, CodeQL | 190 releases in ~4.5 months, YC-backed, commercial cloud platform behind it |
| Cost | No API key, 100% local | No API key for code-only indexing, optional LLM pass for docs |

**Verdict: codebase-memory-mcp.** Comparable or better token reduction, far
more engineering maturity, no commercial platform pulling it toward
cloud lock-in, and it ships its own token-budget-aware output format (TOON)
plus a hard line-cap on code snippets.

## Web access: Agent-Reach vs. native WebFetch

For a generic public URL, both just fetch and return clean text — there's no
reason to add a dependency for something Claude Code already does. Agent-Reach
earns its place specifically for platforms WebFetch can't handle at all:
Twitter/X, Reddit, LinkedIn, YouTube transcripts (via yt-dlp, not the raw
page), and free semantic search (Exa, no API key) — installed as a skill, not
a standing MCP, so it costs ~0 tokens until it's actually invoked.

## Rejected

- **OmniRoute** — a 341-provider LLM router/proxy with a real prompt-compression
  pipeline, but built to route *away* from Anthropic to cheaper providers.
  That's the opposite of "don't reduce quality to save tokens." Its one
  reusable idea (tool-output compression) isn't extractable without the rest
  of the proxy.
- **Orca** — a full Electron IDE for running multiple coding-agent CLIs in
  parallel worktrees. No token reduction (N agents = N full contexts, no
  cache sharing) — it improves human ergonomics around supervising agents,
  not the thing this project optimizes for. Its coordination *patterns*
  (bounded dependency chains, failure caps) were kept as a documentation
  convention; the software wasn't installed.
- **Claude Agent SDK** (considered in Phase 2, listed here for completeness)
  — bills per token via API key, doesn't use the Claude Code subscription.

## What actually ships

- `codebase-memory-mcp` binary, installed but **not** registered as a global
  MCP server — enabled per project via a local `.mcp.json` only where
  Grep/Glob/Explore genuinely fall short.
- `agent-reach` as a Claude Code skill (on-demand, not a standing tool).
- A short `CLAUDE.md` policy telling Claude which tool wins when two could
  plausibly handle the same request.

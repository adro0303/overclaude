# Contributing to Overclaude

Overclaude is a curation project, not a framework: the value it offers is
that every piece already got cloned, read, and compared against its
alternatives before it shipped. That raises the bar for what gets accepted
compared to a typical "add a feature" PR — anything that lands here becomes
part of everyone else's setup, on-demand or (in ponytail's documented case)
on every single session.

## What's welcome, no extra process needed

- Bug fixes to `hooks/`, `install/`, `shell/aliases.zsh` — including
  `install.sh` idempotency issues (it must be safe to re-run, and must
  never clobber an existing `settings.json` or `CLAUDE.md`).
- Docs fixes: unclear wording, broken links, stale numbers, anchors that
  drifted from a renamed heading.
- Security hardening for the notification hooks or the Telegram flow —
  see the "Security notes" section in `README.md` for the threat model
  these already assume.
- Updates to an existing `docs/phase-N-*.md` when the tool it evaluated
  changed enough to invalidate the comparison (new release, new
  benchmark, project abandoned).

Open a PR directly for these — no issue required first.

## What gets rejected before anyone reads the diff

- **Vendored source.** This repo does not ship copies of third-party code.
  Install through the project's own installer/package manager and add it
  to `THIRD_PARTY_NOTICES.md`, the way every existing dependency works.
- **A new standing tool proposed from the README alone.** "I read about
  it" isn't evaluation. See the bar below.
- **Duplicating something Claude Code already does natively** (native
  `WebFetch`/`WebSearch`, Remote Control, Channels) unless the PR
  demonstrates a concrete case those genuinely can't handle.
- **A new dependency with no `THIRD_PARTY_NOTICES.md` update**, or one
  that doesn't state its license.

## The bar for adding a new tool (MCP, skill, or plugin)

This is the expensive kind of contribution, and it follows the same
process every existing tool in this repo went through — see
`docs/phase-1-context-optimization.md` and `docs/phase-3-code-quality.md`
for worked examples. For anything at this scale, open an issue first to
align on whether it's in scope before doing the work.

1. **Clone it and read it** — not just the README. If there's a
   realistic alternative, clone that too.
2. **Compare, don't assert.** A table like the ones in `docs/` — same
   axes (maturity, cost, evidence for its claims) — beats a paragraph of
   adjectives.
3. **State the cost honestly.** Default expectation is zero fixed cost:
   loads on demand, or scoped per-project the way `codebase-memory-mcp`
   is. A standing, always-on cost is not disqualifying, but it has to
   buy something measured — see how `docs/phase-3-code-quality.md`
   justifies ponytail's ~983 tok/session with a reproducible benchmark,
   not a vibe. "It might help" does not clear this bar.
4. **Write it up** as a new `docs/phase-N-*.md`: comparison table,
   verdict, "what actually ships."
5. **Wire it into `install.sh`** the same way existing tools are: warn
   and continue if the third-party installer fails, never hard-fail the
   whole script over one optional piece.
6. **Update `README.md`** — the "Powered by" table, the relevant pillar
   section (Efficient / Clean / Comfortable), and the Quickstart bullet
   list if `install.sh` now does something new.
7. **Update `THIRD_PARTY_NOTICES.md`** with license and copyright.

A PR that adds the tool but skips the write-up gets sent back for it —
the evaluation is the actual contribution here, the wiring is the easy
part.

## Testing a change

- `bash -n install.sh` at minimum.
- Where practical, run `install.sh` against a scratch
  `CLAUDE_CONFIG_DIR` to confirm it's idempotent and doesn't overwrite an
  existing `settings.json`.
- For hooks: match the existing failure mode in `hooks/build-test-alert`
  and `hooks/stop-notify` — fail silent/open, never block a session or
  claim permission authority they don't have.

## Style

- Code and docs changes are held to the same gate DevCorp enforces on
  itself: [`skills/devcorp/references/clean-code.md`](./skills/devcorp/references/clean-code.md)
  — single responsibility, the DRY reuse ladder, YAGNI, no speculative
  abstractions.
- Docs voice: a claim like "faster" or "better" needs a number or a link
  to one right next to it, the way the existing `docs/` writeups do.

## License

By contributing, you agree your contribution is licensed under this
repo's MIT License (see [`LICENSE`](./LICENSE)). Don't include
third-party source under a different license — link to it instead, per
the pattern in [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md).

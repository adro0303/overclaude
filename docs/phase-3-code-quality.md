# Phase 3: code quality — ponytail

One candidate was cloned and read before deciding how to integrate it:
`ponytail`. Adopted, both as its own plugin and as text folded into
DevCorp's existing gate.

## ponytail vs. what DevCorp already gated on

`skills/devcorp/references/clean-code.md` already enforced DRY ("grep before
you write"), YAGNI, and anti-over-engineering as a checklist ARCH and BUILD
have to satisfy. `ponytail` (110k+ stars, MIT, actively maintained) targets
the exact same failure mode — an agent over-building a feature — with a
sharper, benchmarked tool: a 7-rung decision ladder (does it need to exist →
already in the codebase → stdlib → native platform feature → installed
dependency → one line → minimum code) that an agent runs before writing any
new code.

| | clean-code.md (before) | ponytail |
|---|---|---|
| Reuse check | "grep before you write" (prose) | same idea, plus stdlib/native-platform/installed-dependency/one-line rungs it didn't have |
| Evidence | none (internal checklist) | agentic benchmark on a real FastAPI+React repo: -54% LOC / -22% tokens / -20% cost / -27% time vs. no-skill baseline, 100% on a separate adversarial safety score |
| Scope | loaded only when DevCorp's ARCH/BUILD phases run | Claude Code plugin with `SessionStart` / `SubagentStart` / `UserPromptSubmit` hooks — every turn, every project, DevCorp or not |
| Cost | effectively free (already-loaded reference file) | ~983 tokens always-on, per `claude plugin details ponytail@ponytail` |

**Verdict: install the plugin, and keep the ladder in `clean-code.md` too.**
This is the one place in this repo where the usual "zero fixed cost or it
doesn't ship" filter (see the main [`README.md`](../README.md#-how-skills-get-chosen-cost-has-to-earn-its-keep))
is overridden on purpose — ponytail only works by being in context on every
turn, and the payoff (a measured, reproducible cut in over-built code) was
judged worth ~983 tokens/session. Every other skill in this repo still has
to justify itself as free-when-unused; this one is the deliberate
exception, not a quiet erosion of the rule.

The ladder also stays as text in `clean-code.md` rather than being deleted
in favor of the plugin, because DevCorp's ARCH/BUILD gate should hold even
on a machine where the ponytail plugin isn't installed (it's part of
`install.sh` but, like every other step there, can fail or be skipped) —
belt and suspenders, at effectively no extra cost since the file was already
loaded at that point.

## What actually ships

- `ponytail@ponytail`, installed via its own marketplace
  (`claude plugin marketplace add DietrichGebert/ponytail`, then
  `claude plugin install ponytail@ponytail`) as part of `install.sh`,
  scope: user — active in every project, every session, not just this one.
- The same reuse ladder, as text, inside
  [`skills/devcorp/references/clean-code.md`](../skills/devcorp/references/clean-code.md#reuse-ladder--grep-before-you-write),
  loaded by `dc-architect` at ARCH and `dc-frontend`/`dc-backend` at BUILD.
- Credit in [`THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md).
- To remove: `claude plugin uninstall ponytail@ponytail` (the `clean-code.md`
  copy stays regardless — it costs nothing extra to keep).

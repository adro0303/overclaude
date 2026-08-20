# Pipeline — phase gates and definition of done

Each phase has one job, one owner, and one exit condition. Do not start a phase
until the previous one's gate is met. Do not carry a phase's raw output forward
— summarize decisions and `path:line` references only.

## INTAKE
Owner: you (the engineering manager), inline — no agent.
Do: classify the request. Trivial (typo, rename, one-liner, a question) → skip
straight to inline execution, skip the rest of this pipeline. Otherwise → SPEC.
Gate: you can state in one sentence what "done" looks like.

## SPEC — `dc-product`
Do: user stories, acceptance criteria, explicit scope cuts (what this does NOT
cover).
Gate: acceptance criteria are checkable by QA later without asking the user
anything further. If two readings of the request would produce materially
different products, stop and ask the user — do not guess.

## ARCH — `dc-architect`
Do: recon first (`dc-scout`, if the repo isn't already mapped), then the plan —
trade-offs, file-by-file task list, explicit interface boundaries between
frontend and backend work so BUILD can run in parallel without file collisions.
Gate: every file BUILD will touch is named, with what changes in it. Skip this
phase entirely for trivial work — never spin up `dc-architect` for a one-liner.

## BUILD — `dc-frontend` + `dc-backend`
Do: execute the architect's plan literally. No re-designing mid-build — if the
plan is wrong, stop and escalate back to ARCH rather than improvising.
Launch both in the same message only when the plan shows no shared-file
dependency between them.
Gate: the task list from ARCH is fully checked off, nothing partially done.

## QA — `dc-qa`
Do: tests for the acceptance criteria from SPEC, browser verification for any
UI change (actually drive it, don't just typecheck), repro steps for anything
that fails.
Gate: every acceptance criterion from SPEC has a passing check or a filed
failure with repro steps. A green test suite is not the same as feature
correctness — verify the golden path and edge cases actually work.

## SECURITY — `dc-security`
Do: threat model against the OWASP checklist in `references/security.md`, code
audit of what BUILD touched.
Gate: no unresolved finding above low severity. Skip this phase only for
changes with no new attack surface (pure refactors, internal tooling with no
external input) — state explicitly why it's skipped.

## SHIP
Owner: you, inline.
Do: summarize what changed, what was skipped and why, and what the user needs
to do next (deploy, review, merge).
Gate: none of the above — this phase always runs, even if it's one line.

## Stop conditions (apply at every phase)
Missing credentials, a destructive change (drop table, force push, delete
files, prod deploy), a spec with two materially different valid readings, or
any agent failing twice on the same step — stop and ask the user instead of
pushing through.

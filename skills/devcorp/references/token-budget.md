# Token budget — how the saving is actually achieved

DevCorp's saving comes from three separate levers, not one trick. Each one
matters on its own; stacked, they're why a full pipeline run costs a fraction
of doing the same work with one model reading everything.

## 1. Model routing (cost per token)
Recon runs on haiku, most execution on sonnet, only the two phases that need
real judgment — architecture and security — run on opus. The plan gets made
once, expensively, by the model that's actually good at trade-offs; everyone
downstream executes that plan literally instead of each cheaper agent
re-deriving it. Never invert this: don't send planning-shaped work to a
cheap model because it's cheap, and don't run opus for recon or mechanical
edits because it's available.

## 2. Context isolation (tokens per call)
Every subagent's raw output — full file contents, grep dumps, tool noise —
stays inside that subagent's own context. Only the handoff format (goal,
files touched, constraints, done-when) crosses back to the orchestrator. The
orchestrator's context stays small and cheap for the entire pipeline length,
regardless of how much any individual phase had to read to get its answer.
This is the same reasoning behind forking for research tasks generally: the
expensive intermediate output doesn't need to persist past the phase that
produced it.

## 3. Skipping phases that don't apply (calls avoided entirely)
A typo or one-line fix never touches SPEC/ARCH/QA/SECURITY at all — it's
handled inline by the orchestrator. Read-only questions skip BUILD and
SECURITY. A pure refactor with no new attack surface states explicitly why
SECURITY was skipped rather than running it and reporting "no findings" at
full cost. The cheapest tool call is the one you don't make — check the
INTAKE classification in `references/pipeline.md` before assuming the full
pipeline is warranted.

## What this budget is not
Not a quality cut. The gates in `references/pipeline.md` don't loosen because
a cheaper model is running the phase — dc-frontend and dc-backend on sonnet
still have to satisfy the same definition-of-done as if opus had done the
work. The saving is architectural (who does what, how much of it persists),
not "accept worse answers for less money."

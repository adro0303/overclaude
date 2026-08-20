# Backend — API, data, auth, error handling

For `dc-backend`. Load once, at BUILD start.

## API design
- Match the existing API style in the repo (REST/GraphQL/RPC, existing route
  conventions, existing response envelope) — don't introduce a second
  convention alongside the first.
- Validate at the boundary (request entry point) only — don't re-validate the
  same data three layers deep once it's inside trusted internal code.
- Idempotency for anything that can be safely retried (webhooks, payment
  callbacks, queue consumers).

## Data
- Migrations are additive and reversible by default; a destructive migration
  (drop column, drop table, non-nullable without a backfill) is a stop
  condition — escalate to the user, don't run it unattended.
- Match existing schema/naming conventions in the codebase.
- No N+1 queries introduced where a join or batched load was available.

## Auth
- Never invent a new auth mechanism when the codebase already has one wired
  in — extend it.
- Least privilege: a new endpoint/service gets only the scopes it needs.
- Secrets never hardcoded, logged, or included in error responses.

## Error handling
- Only handle errors that can actually occur at this boundary — don't wrap
  internal calls that can't fail in defensive try/catch.
- User-facing errors are safe to show (no stack traces, no internal paths,
  no secrets); logs get the detail, the client gets a clean message.
- Failures fail loud in dev/CI, gracefully in prod — no silent swallowing.

## Definition of done for this role
- Matches the architect's file-by-file plan.
- New/changed endpoints have a passing test or a QA repro step.
- Handoff back states which files changed and any new environment
  variables/migrations the user needs to run.

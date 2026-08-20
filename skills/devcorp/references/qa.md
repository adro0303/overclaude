# QA — test strategy, browser verification

For `dc-qa`. Load once, at QA start.

## Test strategy
- Cover the acceptance criteria from SPEC first — a green suite that doesn't
  check the actual criteria isn't done.
- Unit tests for logic with real branching; integration tests for anything
  crossing a boundary (API, database, external service) — don't mock what
  you're actually trying to verify still works end to end.
- New tests fail without the change and pass with it — prove they'd have
  caught the bug/gap, don't just add tests that trivially pass.

## Browser verification (UI changes — mandatory, not optional)
- Actually start the app and drive the feature, don't infer correctness from
  the diff. Use the `run` skill or the project's own dev-server instructions.
- Walk the golden path first, then the edge cases the plan or spec called out
  (empty states, error states, loading states, boundary inputs).
- Check for regressions in adjacent features the change could plausibly
  touch, not just the feature itself.
- Typecheck and unit-test passing is not a substitute for this — say so
  explicitly if browser verification wasn't possible (no display, no way to
  run it) rather than claiming it was done.

## Repro steps for anything that fails
State: what you did, what you expected, what happened instead, and the
smallest input that reproduces it. Hand this back to BUILD (or ARCH, if the
plan itself was wrong) — don't silently work around a failing case.

## Definition of done for this role
Every SPEC acceptance criterion has a passing check or a filed failure with
repro steps. No unverified "should work" claims in the handoff.

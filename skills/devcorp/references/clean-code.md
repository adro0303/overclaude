# Clean code — structure, reuse, OOP + SOLID when they earn it

For `dc-architect` (plan against this) and `dc-frontend`/`dc-backend` (build
against this). Load once, alongside `frontend.md`/`backend.md`, at ARCH/BUILD
start. This is a quality gate, not a style preference — BUILD is not done if
it violates this checklist, same as it isn't done if it fails a test.

## Single responsibility, both ways
- One file, one reason to change. If a file does two unrelated things (e.g.
  parses input AND renders output AND talks to a database), split it before
  adding more to it — don't be the change that pushes it over the line.
- One function, one job. If you need "and" to describe what a function does,
  it's two functions. Extract before the function grows past what fits in
  one screen.
- This cuts both directions: don't split a file into five for one function
  each, either. A 15-line module doesn't need three layers of indirection.

## DRY — grep before you write
- Before writing a new function, grep for one that already does this or
  something close to it. Extending or calling an existing function beats
  writing a second one that drifts from it over time.
- Three or more call sites doing the same sequence of steps is a function
  waiting to be extracted — do it, don't let a fourth copy land.
- Two similar-looking blocks are not automatically duplication if they exist
  for unrelated reasons and will evolve independently (see YAGNI below) —
  don't force a shared abstraction over two things that only coincidentally
  look alike today. Duplication is cheaper than the wrong abstraction.

## Naming
- Names say what a thing is or does without needing the surrounding code to
  explain it. `data`, `tmp`, `handleStuff`, `x2` are all findings, not style
  nits — rename them.
- Match the codebase's existing naming convention (casing, verb/noun
  patterns, file-naming scheme) instead of introducing a second one.

## OOP — use it when there's real state + behavior, not by default
- Reach for a class when you have state that travels together with the
  operations on it, or multiple interchangeable implementations behind one
  interface (strategy/adapter-shaped problems). That's when a class earns
  its place over a plain function or module.
- Don't wrap stateless logic in a class with one method just to "be OOP."
  A pure function is simpler, easier to test, and the correct choice for
  that shape of problem.
- Match what the codebase already does — don't introduce classes into a
  codebase that's consistently functional/procedural, or vice versa,
  without the architect calling that out explicitly in the plan.

## SOLID — apply once there's a real class/interface, not decoratively
Only relevant once OOP was the right call above. Don't retrofit SOLID
vocabulary onto three plain functions — these are checks for when you're
already designing classes or interfaces.
- **Single Responsibility** — one class, one reason to change. Covered above
  under "Single responsibility, both ways"; it's the same rule for classes
  as for files/functions.
- **Open/Closed** — when a new case is genuinely likely to recur (the
  architect flagged a strategy/adapter shape, or SPEC names more coming),
  add it as a new implementation behind the existing interface, not another
  branch in a growing if/switch over type. Don't add an extension point for
  a second case nobody has asked for yet — that's YAGNI, not OCP.
- **Liskov Substitution** — a subtype must honor its base type's contract:
  same accepted inputs, no narrower promises, no surprising exception the
  base type didn't already allow. If making something a "subclass" requires
  overriding a method to throw "not supported here," it isn't a subtype —
  use composition or split the interface instead of forcing the hierarchy.
- **Interface Segregation** — a consumer shouldn't have to depend on methods
  it never calls. If implementers keep stubbing out half an interface with
  no-ops, split it into smaller interfaces scoped to what each caller
  actually uses, instead of one interface everything partially implements.
- **Dependency Inversion** — depend on an abstraction at boundaries that
  will plausibly need swapping (a real external service, storage, a
  pluggable piece SPEC or ARCH called out) — not reflexively at every call
  site. Wiring a concrete dependency directly is correct, not a violation,
  when there's exactly one implementation and no swap in sight; injecting
  an interface for that case is the over-engineering DRY/YAGNI above warns
  against.

## Agile / iterative discipline
- YAGNI: build what SPEC's acceptance criteria actually require, not the
  generalized version you can imagine needing later. A speculative config
  flag, plugin system, or extra abstraction layer with no current caller is
  scope creep, not architecture.
- Small vertical slices: prefer a change that does one full thing end to end
  over a half-wired abstraction that compiles but doesn't do anything yet.
  No half-finished implementations in a handoff.
- Definition of done for a slice is "works and is verified" (see
  `qa.md`), not "compiles" or "the shape looks right."

## Definition of done for this checklist
- No function or file doing two unrelated jobs.
- No third+ copy of logic that already exists elsewhere in the diff or the
  surrounding codebase — reused or extracted instead.
- Names are self-explanatory without needing a comment to compensate.
- Any class introduced has real state+behavior or multiple implementations
  behind it — not a single-method wrapper around a pure function.
- Any class/interface introduced satisfies SOLID: one reason to change, new
  cases added alongside existing implementations rather than via a growing
  type-switch, no subtype that narrows or breaks its base type's contract,
  no interface callers are forced to partially stub out, and no dependency
  abstracted away with no second implementation or swap in sight.
- Nothing built for a requirement SPEC didn't actually ask for.

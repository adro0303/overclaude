# Frontend — design system, a11y, performance checklist

For `dc-frontend`. Load this once, at BUILD start, alongside the
`frontend-design` and `web-design-guidelines` skills — don't re-derive what
those skills already cover.

## Design system
- Reuse existing components/tokens before adding new ones. Grep the design
  system directory before writing a new button, modal, or form field.
- Match the codebase's existing styling approach (CSS modules, Tailwind,
  styled-components, whatever's already there) — never introduce a second
  styling system into one project.
- No inline magic numbers for spacing/color that duplicate an existing token.

## Accessibility (non-negotiable, not a nice-to-have)
- Every interactive element reachable and operable by keyboard alone.
- Semantic HTML first; ARIA only to fill a real gap semantic HTML can't cover.
- Color contrast meets WCAG AA at minimum for text and meaningful UI.
- Images/icons that carry meaning have alt text or an accessible name; purely
  decorative ones are hidden from assistive tech.
- Forms: every input has a programmatically associated label, errors are
  announced, not just colored.

## Performance
- No unnecessary re-renders introduced (check memoization boundaries you're
  crossing before adding state high in the tree).
- Don't ship a new dependency for something 20 lines of code covers.
- Images/assets sized and formatted for the web, not dropped in raw.
- Avoid blocking the main thread with synchronous work that can be deferred
  or moved off it.

## Definition of done for this role
- Matches the architect's file-by-file plan — no scope creep into files not
  listed.
- Verified in a real browser (see `references/qa.md`), not just "it compiles."
- Handoff back states which files changed and what to verify, nothing more.

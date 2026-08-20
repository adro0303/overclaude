# Security — threat model + OWASP audit checklist

For `dc-security`. Read-only audit role — no edits, findings only. Load once,
at SECURITY start.

## Threat model (do this first, in one pass)
- What's the new attack surface this change adds (new endpoint, new input
  field, new file parsed, new external call)?
- Who can reach it — authenticated users only, or anonymous/public?
- What's the worst realistic outcome if it's abused (data exposure,
  privilege escalation, resource exhaustion, RCE)?

## OWASP-style checklist against what BUILD touched
- **Injection** — SQL, command, template, LDAP. Any string concatenation into
  a query/command/shell call built from user input.
- **Broken auth/session** — new endpoints respect existing auth middleware,
  no auth check accidentally skipped or scoped too broadly.
- **Sensitive data exposure** — secrets/PII in logs, error messages, client
  responses, or committed files.
- **XXE / insecure deserialization** — untrusted input parsed by an XML/YAML/
  pickle-style parser without safe mode.
- **Broken access control** — object-level checks (can user A act on user B's
  resource?), not just route-level auth.
- **XSS** — unescaped user input rendered into HTML/JS/templates.
- **Insecure dependencies** — new packages added, check for known CVEs before
  approving.
- **SSRF** — any new server-side call to a URL built from user input.
- **Logging/monitoring gaps** — security-relevant events (auth failures,
  privilege changes) actually get logged.

## Severity and gate
Rate each finding: critical / high / medium / low. The SECURITY gate requires
zero unresolved findings above low. Report findings with file:line, the
concrete exploit scenario, and the fix — not just "this looks unsafe."

## Definition of done for this role
Every finding is either fixed (handed back to BUILD with a specific, scoped
ask) or explicitly accepted by the user with the risk stated in plain
language. Never silently downgrade a finding to make the gate pass.

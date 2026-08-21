#!/usr/bin/env python3
"""Idempotently register one hook command in a Claude Code settings.json.

install.sh calls this once per hook it wires up (build-test-alert,
stop-notify, support-notice). They all do the same thing -- load settings,
add this event/command if it isn't already there, write back -- so that
logic lives here once instead of three near-identical inline heredocs.
"""
import argparse
import json
import os
import sys


def register(settings_path: str, event: str, command: str, timeout: int, matcher: str | None) -> bool:
    """Add the hook entry if missing. Returns True if it was newly added."""
    settings = {}
    if os.path.exists(settings_path):
        with open(settings_path) as f:
            settings = json.load(f)

    event_hooks = settings.setdefault("hooks", {}).setdefault(event, [])

    def already_registered(entry: dict) -> bool:
        if matcher is not None and entry.get("matcher") != matcher:
            return False
        return any(command in h.get("command", "") for h in entry.get("hooks", []))

    if any(already_registered(e) for e in event_hooks):
        return False

    entry = {}
    if matcher is not None:
        entry["matcher"] = matcher
    entry["hooks"] = [{"type": "command", "command": command, "timeout": timeout}]
    event_hooks.append(entry)

    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")

    return True


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("settings_path")
    parser.add_argument("--event", required=True, help="Hook event name, e.g. Stop, SessionStart")
    parser.add_argument("--command", required=True, help="Shell command the hook runs")
    parser.add_argument("--timeout", type=int, required=True)
    parser.add_argument("--matcher", default=None, help="Tool matcher, e.g. Bash (omitted for event-only hooks)")
    args = parser.parse_args()

    added = register(args.settings_path, args.event, args.command, args.timeout, args.matcher)
    print("settings.json updated" if added else "settings.json already had the hook, left as-is")


if __name__ == "__main__":
    main()

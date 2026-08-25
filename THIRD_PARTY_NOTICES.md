# Third-party notices

This repository contains original glue code (hooks, shell helpers,
documentation) written for this project, licensed under MIT (see `LICENSE`).
It does not vendor or redistribute source code from the projects below --
`install.sh` installs them through their own official installers/package
managers. They're credited here because this project is built to work with
them and would not do anything useful without them.

- **[codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)**
  by DeusData -- local, tree-sitter-based code knowledge graph exposed as an
  MCP server. MIT License, Copyright (c) 2025 DeusData.

- **[Agent-Reach](https://github.com/Panniantong/Agent-Reach)** by
  Panniantong -- capability layer that gives an agent CLI internet access
  (web, YouTube, GitHub, RSS, and opt-in social platforms), installed as a
  Claude Code skill. MIT License, Copyright (c) 2025 Agent Eyes.

- **[ponytail](https://github.com/DietrichGebert/ponytail)** by Dietrich
  Gebert -- YAGNI/reuse-ladder ruleset that pushes an agent toward the
  smallest correct diff (stdlib/native-platform/installed-dependency before
  new code), installed as a Claude Code plugin via its own marketplace
  (`claude plugin marketplace add DietrichGebert/ponytail`). MIT License,
  Copyright (c) 2026 Dietrich Gebert. Its "reuse ladder" is also adapted, as
  text, into `skills/devcorp/references/clean-code.md` for DevCorp's own
  ARCH/BUILD gate -- see the acknowledgment below.

- **[claude-plugins-official](https://github.com/anthropics/claude-plugins-official)**
  by Anthropic -- official plugin marketplace, source of the Telegram/Discord/
  iMessage channel plugins used for mobile chat access. Apache License 2.0.

- **[Claude Code](https://code.claude.com)** by Anthropic -- Remote Control,
  background agents, hooks, and the plugin/channel system this project
  configures are native Claude Code features, not something this repo
  implements.

## Acknowledgment, not vendored code

- The parallel-agent coordination conventions in `CLAUDE.md.example`
  (bounded dependency chains, retry limits, short summaries instead of full
  dumps) were distilled as a documentation pattern after evaluating
  [stablyai/orca](https://github.com/stablyai/orca) -- no code from that
  project is included or required.

- The "reuse ladder" in
  [`skills/devcorp/references/clean-code.md`](./skills/devcorp/references/clean-code.md)
  (does it need to exist -> already in the codebase -> stdlib -> native
  platform feature -> installed dependency -> one line -> minimum code) is
  the same ruleset ponytail (listed above) ships as its own plugin, copied
  here as text so it's also visible to DevCorp's ARCH/BUILD phases when
  they load `clean-code.md` directly, independent of whether the ponytail
  plugin itself is installed on a given machine.

# Garde-fous

**Guardrails for the human-AI duo — governance enforced by tools, not by prose.**

A Claude Code plugin marketplace carrying two independent plugins. Install only what you need:

| Plugin | What it guards | What's inside |
|---|---|---|
| **ultracode-cockpit** | Your token budget. Claude Code's ultracode mode (Dynamic Workflows, up to 1,000 agents) silences its own native cost guardrails. | The [UltraCode Cockpit skill](https://github.com/Alexandre-LPZ/ultracode-cockpit) + **mechanical rails**: the GO token is minted by the human's word alone, demanded and decremented by a customs gate on every subagent. `/ultracode-cockpit:cockpit` to board. |
| **avant-garde** | Your project's foundations. Vibe coding without written foundations ships open databases and leaked keys. | The [Avant-Garde skill](https://github.com/Alexandre-LPZ/avant-garde) (6 foundation documents, 10-point security gate, STATE.md resume memory) + `/avant-garde:avant-garde`. Pure skill for now — its hooks will come after field observation, never before. |

## Install

```bash
claude plugin marketplace add Alexandre-LPZ/garde-fous
claude plugin install ultracode-cockpit@garde-fous
claude plugin install avant-garde@garde-fous   # optional, independent
```

## How the Cockpit rails work (the honest part)

Prose binds an AI by conviction; under pressure, conviction can crack — we measured it. These rails bind by construction, in under 120 lines of readable bash, zero dependencies:

1. **The quote** — when Claude displays a P2/P3 estimate, it writes the quoted agent cap into `.claude/.cockpit_quote`. That's the invoice, never the GO.
2. **The human's word mints the token** — a `UserPromptSubmit` hook (which runs outside the agent's hands) turns the quote into `.claude/.cockpit_go` **only** when the human's own message starts with `GO`, `P2` or `P3` **and** a quote is pending. "Just launch it, I pre-authorize" mints nothing: an authorization given in advance is not a GO.
3. **The customs gate** — a `PreToolUse` hook on subagent launches requires a fresh, unexpired token and **decrements the cap on every agent**. At zero, the token is consumed. A small free allowance (default 1 subagent/session, `COCKPIT_FREE_AGENTS`) keeps routine tasks frictionless.
4. **The vault is out of reach** — a guard hook denies any agent attempt to write the token or the counter. Only the human's word opens the gate.
5. **The relief valve** — the human (and only the human) can type `BYPASS` (60 min, logged) or `STOP`/`NON` to cancel everything. A guardrail must protect you from the cliff, never stop you from walking on the sidewalk.

**Threat model, stated plainly**: these rails protect against *drift* — degraded context, pressure, prompt injection — not against an adversary with an unrestricted shell. Defense in depth, not a vault door. The real gauges live in `/workflows`.

## Trust

- Every hook is short, readable bash. Read them before installing: [`mint-go.sh`](plugins/ultracode-cockpit/hooks/scripts/mint-go.sh) · [`gate-task.sh`](plugins/ultracode-cockpit/hooks/scripts/gate-task.sh) · [`guard-token.sh`](plugins/ultracode-cockpit/hooks/scripts/guard-token.sh)
- Hooks come **only** with the cockpit plugin — install `avant-garde` alone and nothing executes on your machine.
- The skills' source of truth remains their own repos ([ultracode-cockpit](https://github.com/Alexandre-LPZ/ultracode-cockpit), [avant-garde](https://github.com/Alexandre-LPZ/avant-garde)), synced here at each release.
- Hook scripts were unit-tested against the failure modes that designed them: self-minting attempts, pre-authorization injection, cap exhaustion, token expiry. See the repos' releases for the full test history — failures included.

## Credits

Built by a human–AI duo: a non-developer entrepreneur and Claude, as equal partners. The mechanical-rails design was hardened by a three-way counter-expertise (the "fake token" flaw, the Two-Key lock, atomic decrement). The governed-dev philosophy echoes what [VibeFlow OS](https://github.com/picmakpro/vibeflow-os) and [ECC](https://github.com/affaan-m/ECC) are building — adapted here to stay minimal.

## License

[MIT](LICENSE) — use it, fork it, improve it. If it saved your token budget or your database, a ⭐ helps others find it.

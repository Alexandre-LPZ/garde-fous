# UltraCode Cockpit — plugin

The [UltraCode Cockpit skill](https://github.com/Alexandre-LPZ/ultracode-cockpit) (tiered triage, estimate before any agent spend, kill-switch, flight report) **plus mechanical rails**:

- the GO token is minted by the human's word alone (`UserPromptSubmit` hook) — a guard hook denies any agent attempt to write it (v0.1.1: judged by the operation's target, so plugin-source maintenance stays possible);
- **Cowork fallback (v0.1.1)**: harnesses that skip `UserPromptSubmit` keep the Two-Key lock — with no token, the customs gate reads the last human message from the session transcript (replay-fingerprinted, 15-min freshness) and applies the same rules;
- **Two-Key lock**: a GO with no pending quote mints nothing — an authorization given in advance is not a GO;
- a customs gate on every subagent launch: fresh token required, cap decremented per agent, consumed at zero. A small free allowance (`COCKPIT_FREE_AGENTS`, default 1/session) keeps routine tasks frictionless;
- `BYPASS` (60 min, logged) and `STOP` belong to the human alone.

## Install

```bash
claude plugin marketplace add Alexandre-LPZ/garde-fous
claude plugin install ultracode-cockpit@garde-fous
```

`/ultracode-cockpit:cockpit` boards the cockpit in any session.

The hooks are ~210 lines of readable, commented bash, zero dependencies — read them in [`hooks/scripts/`](hooks/scripts/) before installing. Threat model: protection against drift and prompt injection, not against an adversary with an unrestricted shell. Field-test history: see the [marketplace releases](https://github.com/Alexandre-LPZ/garde-fous/releases) and the [skill repo](https://github.com/Alexandre-LPZ/ultracode-cockpit).

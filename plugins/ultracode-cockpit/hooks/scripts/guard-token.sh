#!/usr/bin/env bash
# UltraCode Cockpit — guard-token.sh (PreToolUse sur Write|Edit|MultiEdit|Bash)
# Anti-self-minting : le coffre (.cockpit_go) et le compteur de session sont
# hors de portée de l'agent. Seul le hook UserPromptSubmit — la parole
# humaine — peut poser ou modifier le jeton. (.cockpit_quote, la facture,
# reste libre : c'est Claude qui l'écrit au moment du devis.)
set -u

IN="$(cat)"
if printf '%s' "$IN" | grep -q 'cockpit_go\|cockpit_count'; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Cockpit : le jeton GO ne peut etre pose ou modifie que par la parole humaine (hook UserPromptSubmit). Operation refusee."}}\n'
fi
exit 0

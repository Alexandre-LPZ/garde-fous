#!/usr/bin/env bash
# UltraCode Cockpit — guard-token.sh (PreToolUse sur Write|Edit|MultiEdit|Bash) — v0.1.1
# Anti-self-minting : le coffre (jeton) et le compteur de session sont hors de
# portée de l'agent. Seule la parole humaine — mint-go.sh, ou la soupape
# transcript de gate-task.sh — peut poser ou modifier le jeton.
# (.cockpit_quote, la facture, reste libre : c'est Claude qui l'écrit au devis.)
#
# v0.1.1 — la garde juge la CIBLE de l'opération, plus le texte brut :
# - Write/Edit/MultiEdit : refus si le CHEMIN du fichier vise le jeton ou le
#   compteur. La maintenance des sources du plugin redevient possible — leçon
#   de terrain : la v0.1.0 bloquait toute édition MENTIONNANT le nom du jeton,
#   y compris l'édition de ses propres scripts.
# - Bash : refus si la commande mentionne le jeton ou le compteur. Impossible
#   de distinguer lecture/écriture sans parser le shell : on reste conservateur.
#   Pour la maintenance des sources, passer par Write/Edit.
# Limite documentée : une écriture blanchie via un script intermédiaire relève
# de l'adversité délibérée, hors modèle de menace (dérive, pas shell illimité).
set -u

IN="$(cat)"
TOOL="$(printf '%s' "$IN" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -c 40)"

case "$TOOL" in
  Write|Edit|MultiEdit)
    TARGET="$(printf '%s' "$IN" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -c 500)"
    ;;
  Bash)
    TARGET="$IN"
    ;;
  *)
    exit 0
    ;;
esac

if printf '%s' "$TARGET" | grep -q '\.cockpit_go\|\.cockpit_count'; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Cockpit : le jeton GO ne peut etre pose ou modifie que par la parole humaine. Operation refusee (cible protegee)."}}\n'
fi
exit 0

#!/usr/bin/env bash
# UltraCode Cockpit — gate-task.sh (PreToolUse sur Task|Agent)
# La douane des sous-agents : sans jeton GO valide, pas de lancement —
# avec une tolérance P1 (COCKPIT_FREE_AGENTS sous-agents libres par session,
# 1 par défaut) pour que les petites tâches restent fluides.
# Le plafond du devis est décompté à CHAQUE sous-agent ; à zéro, jeton consumé.
set -u

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude"
GO="$DIR/.cockpit_go"
FREE="${COCKPIT_FREE_AGENTS:-1}"

IN="$(cat)"
SID="$(printf '%s' "$IN" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | tr -cd 'a-zA-Z0-9_-' | head -c 64)"
CNT="$DIR/.cockpit_count_${SID:-nosession}"

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

if [ -f "$GO" ]; then
  IFS='|' read -r TS PALIER REST TTL < "$GO" || deny "Cockpit : jeton illisible — affiche un devis et redemande un GO."
  NOW="$(date +%s)"
  TS="$(printf '%s' "${TS:-0}" | tr -cd '0-9')" ; TS="${TS:-0}"
  TTL="$(printf '%s' "${TTL:-15}" | tr -cd '0-9')" ; TTL="${TTL:-15}"
  REST="$(printf '%s' "${REST:-0}" | tr -cd '0-9')" ; REST="${REST:-0}"
  if [ $(( NOW - TS )) -gt $(( TTL * 60 )) ]; then
    rm -f "$GO"
    deny "Cockpit : jeton GO expiré (${TTL} min) — devis et GO requis à nouveau."
  fi
  if [ "$REST" -le 0 ]; then
    rm -f "$GO"
    deny "Cockpit : plafond d agents du devis atteint — nouveau devis et nouveau GO requis."
  fi
  REST=$(( REST - 1 ))
  if [ "$REST" -le 0 ]; then
    rm -f "$GO"
  else
    printf '%s|%s|%s|%s\n' "$TS" "${PALIER:-GO}" "$REST" "$TTL" > "$GO"
  fi
  # Un travail sous jeton sature la tolérance P1 : pas d'agent « gratuit »
  # en rab une fois le plafond du devis consommé.
  mkdir -p "$DIR" ; echo "$FREE" > "$CNT"
  exit 0
fi

# Pas de jeton : tolérance P1, puis blocage.
mkdir -p "$DIR"
USED=0
[ -f "$CNT" ] && USED="$(tr -cd '0-9' < "$CNT")"
USED="${USED:-0}"
if [ "$USED" -lt "$FREE" ]; then
  echo $(( USED + 1 )) > "$CNT"
  exit 0
fi
deny "Cockpit : devis et GO explicite requis avant de lancer d autres sous-agents. Affiche le devis (et ecris le plafond dans .claude/.cockpit_quote), puis attends le GO de l humain. Soupape : l humain peut taper BYPASS."

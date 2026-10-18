#!/usr/bin/env bash
# UltraCode Cockpit — gate-task.sh (PreToolUse sur Task|Agent) — v0.1.1
# La douane des sous-agents : sans jeton GO valide, pas de lancement —
# avec une tolérance P1 (COCKPIT_FREE_AGENTS sous-agents libres par session,
# 1 par défaut) pour que les petites tâches restent fluides.
# Le plafond du devis est décompté à CHAQUE sous-agent ; à zéro, jeton consumé.
#
# v0.1.1 — soupape harnais : certains environnements (Claude Cowork) exécutent
# PreToolUse mais PAS UserPromptSubmit — la parole humaine n'atteint jamais
# mint-go.sh. Faute de jeton, la douane lit alors le DERNIER message humain
# dans le transcript de session (écrit par le harnais, hors des mains de
# l'agent) et y applique les MÊMES règles : GO/P2/P3 si facture en attente,
# BYPASS, STOP. Chaque message ne mint qu'une fois (empreinte anti-rejouage)
# et un message plus vieux que le TTL ne mint pas. Limite documentée : un
# agent qui falsifierait le transcript relève de l'adversité délibérée, hors
# modèle de menace (dérive et injection, pas un attaquant au shell illimité).
set -u

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude"
GO="$DIR/.cockpit_go"
QUOTE="$DIR/.cockpit_quote"
FREE="${COCKPIT_FREE_AGENTS:-1}"
TTL_MIN=15

IN="$(cat)"
SID="$(printf '%s' "$IN" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | tr -cd 'a-zA-Z0-9_-' | head -c 64)"
CNT="$DIR/.cockpit_count_${SID:-nosession}"
FP="$DIR/.cockpit_mint_fp_${SID:-nosession}"

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

# --- Soupape harnais (v0.1.1) : lire la parole humaine dans le transcript ----
mint_from_transcript() {
  TP="$(printf '%s' "$IN" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -c 300)"
  [ -n "$TP" ] && [ -f "$TP" ] || return 0
  # Dernier message HUMAIN : type user au niveau racine, ni résultat d'outil,
  # ni ligne assistant/summary/meta qui embarquerait un "type":"user" imbriqué.
  LINE="$(grep '"type":"user"' "$TP" 2>/dev/null | grep -v '"type":"assistant"' | grep -v '"type":"summary"' | grep -v '"tool_use_id"' | grep -v '"isMeta":true' | tail -n 1)"
  [ -n "$LINE" ] || return 0
  # Parties texte du message, sans les system-reminder injectés par le harnais.
  MSG="$(printf '%s' "$LINE" | grep -o '"text":"[^"]*' | sed 's/^"text":"//' | grep -v '^<system-reminder' | head -n 1 | head -c 120)"
  [ -n "$MSG" ] || MSG="$(printf '%s' "$LINE" | grep -o '"content":"[^"]*' | sed 's/^"content":"//' | head -n 1 | head -c 120)"
  [ -n "$MSG" ] || return 0
  shopt -s nocasematch
  # STOP/NON : toujours honoré, même jeton en poche. Idempotent.
  if [[ "$MSG" =~ ^[[:space:]]*(STOP|NON)([[:space:]]|$) ]]; then
    rm -f "$QUOTE" "$GO" 2>/dev/null
    shopt -u nocasematch
    return 0
  fi
  shopt -u nocasematch
  # Un jeton existe déjà : rien à minter.
  [ -f "$GO" ] && return 0
  # Fraîcheur : horodatage de la ligne, si lisible (date GNU). Sinon on passe.
  TS_ISO="$(printf '%s' "$LINE" | grep -o '"timestamp":"[^"]*' | sed 's/^"timestamp":"//' | head -n 1)"
  if [ -n "$TS_ISO" ]; then
    MTS="$(date -d "$TS_ISO" +%s 2>/dev/null || true)"
    if [ -n "$MTS" ] && [ $(( $(date +%s) - MTS )) -gt $(( TTL_MIN * 60 )) ]; then
      return 0
    fi
  fi
  # Empreinte anti-rejouage : une même ligne de transcript ne mint qu'une fois.
  SUM="$(printf '%s' "$LINE" | cksum | tr -cd '0-9' | head -c 20)"
  [ -f "$FP" ] && [ "$(cat "$FP" 2>/dev/null)" = "$SUM" ] && return 0
  shopt -s nocasematch
  if [[ "$MSG" =~ ^[[:space:]]*BYPASS([[:space:]]|$) ]]; then
    mkdir -p "$DIR"
    printf '%s|BYPASS|999|60\n' "$(date +%s)" > "$GO"
    printf '%s\n' "$SUM" > "$FP"
  elif [[ "$MSG" =~ ^[[:space:]]*(GO|P2|P3)([[:space:]]|$) ]]; then
    WORD="${BASH_REMATCH[1]}"
    if [ -f "$QUOTE" ]; then
      MAX="$(head -n 1 "$QUOTE" | tr -cd '0-9')"
      [ -z "$MAX" ] && MAX=5
      [ "$MAX" -gt 1000 ] && MAX=1000
      mkdir -p "$DIR"
      printf '%s|%s|%s|%s\n' "$(date +%s)" "${WORD^^}" "$MAX" "$TTL_MIN" > "$GO"
      rm -f "$QUOTE"
      printf '%s\n' "$SUM" > "$FP"
    fi
    # Pas de facture en attente => pas de jeton (Two-Key), comme mint-go.sh.
  fi
  shopt -u nocasematch
  return 0
}

mint_from_transcript

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

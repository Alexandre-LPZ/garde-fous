#!/usr/bin/env bash
# UltraCode Cockpit — mint-go.sh (UserPromptSubmit)
# Le jeton GO n'est posé QUE par la parole humaine : ce hook s'exécute hors
# des mains de l'agent, sur le message tapé par l'humain.
# Two-Key Lock : il exige un devis en attente (.cockpit_quote, posé par Claude
# au moment d'afficher le devis — la facture, jamais le GO).
# Fail-closed : si le message ne peut pas être lu proprement, aucun jeton n'est posé.
set -u

IN="$(cat)"
DIR="${CLAUDE_PROJECT_DIR:-.}/.claude"
QUOTE="$DIR/.cockpit_quote"
GO="$DIR/.cockpit_go"
TTL_MIN=15

# Extraction prudente du message humain (court). Échec => rien.
PROMPT="$(printf '%s' "$IN" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -c 120)"
[ -z "$PROMPT" ] && exit 0

shopt -s nocasematch

if [[ "$PROMPT" =~ ^[[:space:]]*(GO|P2|P3)([[:space:]]|$) ]]; then
  WORD="${BASH_REMATCH[1]}"
  if [ -f "$QUOTE" ]; then
    MAX="$(head -n 1 "$QUOTE" | tr -cd '0-9')"
    [ -z "$MAX" ] && MAX=5
    [ "$MAX" -gt 1000 ] && MAX=1000
    mkdir -p "$DIR"
    printf '%s|%s|%s|%s\n' "$(date +%s)" "${WORD^^}" "$MAX" "$TTL_MIN" > "$GO"
    rm -f "$QUOTE"
    echo "Cockpit : jeton GO posé par l'humain (${WORD^^}, $MAX agents max, ${TTL_MIN} min)."
  fi
  # Pas de devis en attente => pas de jeton : « une autorisation donnée d'avance ne vaut pas GO ».

elif [[ "$PROMPT" =~ ^[[:space:]]*(STOP|NON)([[:space:]]|$) ]]; then
  rm -f "$QUOTE" "$GO" 2>/dev/null
  echo "Cockpit : devis et jeton annulés par l'humain."

elif [[ "$PROMPT" =~ ^[[:space:]]*BYPASS([[:space:]]|$) ]]; then
  # La soupape : explicite, consignée, limitée dans le temps. Elle protège du
  # précipice sans empêcher de marcher sur le trottoir.
  mkdir -p "$DIR"
  printf '%s|BYPASS|999|60\n' "$(date +%s)" > "$GO"
  echo "Cockpit : BYPASS humain consigné (60 min). Le garde-fou est levé, pas oublié."
fi

exit 0

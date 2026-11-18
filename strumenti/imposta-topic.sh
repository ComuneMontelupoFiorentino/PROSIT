#!/usr/bin/env bash
# Aggiunge il topic "prosit" (e alcuni topic descrittivi) ai repository dei componenti.
# I topic gia' presenti vengono mantenuti. Rilanciabile.
#
# Requisiti: GitHub CLI (https://cli.github.com) autenticata con un utente amministratore
# dell'organizzazione:  gh auth login
#
# Uso:  bash strumenti/imposta-topic.sh            (applica)
#       bash strumenti/imposta-topic.sh --prova    (mostra soltanto cosa farebbe)
set -euo pipefail

ORG=ComuneMontelupoFiorentino
PROVA=0; [ "${1:-}" = "--prova" ] && PROVA=1

# repository  topic aggiuntivi (separati da spazio)
REPO_TOPIC=(
  "prosit                                  sit gis pubblica-amministrazione riuso"
  "lizmap-realtime                         lizmap qgis gis realtime iot gtfs-realtime"
  "lizmap-tema-pa-it                       lizmap bootstrap-italia designers-italia tema"
  "TWPROJECT-PostgreSQL-API-sync-pg2twprj  twproject postgresql api ticketing"
  "ANNCSU-PostgreSQL-PDND-sync             anncsu pdnd postgresql postgis interoperabilita"
  "CKAN-API-sync-sit2ckan                  ckan open-data postgresql api"
  "MAIL-SMTP-PostgreSQL__sender            smtp email postgresql"
  "prosit-web                              lizmap php api"
  "prosit-api                              postgrest lizmap rest-api openapi postgresql"
  "prosit-monitor                          monitoring lizmap php"
  "GTFS-PostgreSQL-upsert_gtfs2sit         gtfs trasporto-pubblico postgis lizmap"
)

for riga in "${REPO_TOPIC[@]}"; do
  read -r repo extra <<<"$riga"
  if ! attuali=$(gh api "repos/$ORG/$repo/topics" -q '.names[]' 2>/dev/null); then
    echo "!! $repo: repository non trovato o non accessibile, salto"; continue
  fi
  nuovi=$(printf '%s\n' prosit $extra pubblica-amministrazione $attuali | awk 'NF && !v[$0]++' | head -20)
  echo "== $repo: $(echo $nuovi)"
  [ $PROVA -eq 1 ] && continue
  args=(); for t in $nuovi; do args+=(-f "names[]=$t"); done
  gh api -X PUT "repos/$ORG/$repo/topics" "${args[@]}" -q '"   ok: " + (.names|join(", "))'
done

echo
echo "Elenco dei componenti: https://github.com/search?q=org%3A$ORG+topic%3Aprosit&type=repositories"

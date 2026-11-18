#!/usr/bin/env bash
# Crea i tag e le release dei componenti indicati in prosit.yml (rilanciabile: salta quelli esistenti).
# Requisiti: GitHub CLI autenticata (gh auth login) con permessi di scrittura sui repository.
set -uo pipefail
ORG=ComuneMontelupoFiorentino

# repository  tag  commit  titolo
VERSIONI=(
  "lizmap-realtime                   v1.3.0  b3ddba5bacc2c6312172b1013fa01c797aac317a  lizmap-realtime 1.3.0"
  "CKAN-API-sync-sit2ckan            v1.0.0  c9fa47ce570c7c835d67ed2bb18ea7995e6a3eac  Versione precedente (Classes/, sync.php)"
  "CKAN-API-sync-sit2ckan            v2.0.0  bb5dc5f3d0a74b9822ca88f363b3f92af1a920d4  CKAN Scheduler"
  "prosit-monitor                    v1.0.0  6d07c838f7d7e49f2a2ac4c1ea3b763bbc180440  Prima versione pubblicata"
  "GTFS-PostgreSQL-upsert_gtfs2sit   v1.0.0  64f57034f6f2a57e0b59ec670b656653b75605ee  Prima versione pubblicata"
)

for riga in "${VERSIONI[@]}"; do
  read -r repo tag commit titolo <<<"$riga"
  if gh release view "$tag" -R "$ORG/$repo" >/dev/null 2>&1; then echo "== $repo $tag: esiste gia'"; continue; fi
  sha=$(gh api "repos/$ORG/$repo/commits/$commit" -q .sha) || { echo "!! $repo: commit $commit non trovato"; continue; }
  gh release create "$tag" -R "$ORG/$repo" --target "$sha" --title "$titolo" --notes "Vedi il README e https://github.com/$ORG/PROSIT" \
    && echo "== $repo $tag: creata"
done

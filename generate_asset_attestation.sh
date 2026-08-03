#!/usr/bin/env bash
set -euo pipefail

OUT="/root/asset.attestation.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -n \
--arg time "$TIMESTAMP" \
--arg inventory "$(sha256sum /root/repository.ownership.inventory.json | awk '{print $1}')" \
'
{
 "$schema":"./schemas/asset.attestation.schema.json",

 "attestation":{
   "generated_at":$time,
   "inventory_sha256":$inventory,
   "principle":"evidence_before_claim"
 },

 "repositories":[]
}
' > "$OUT"


for repo in $(find /root -name .git -type d | sed 's#/.git##')
do

cd "$repo"

jq \
--arg path "$repo" \
--arg commit "$(git rev-parse HEAD)" \
--arg tree "$(git rev-parse HEAD^{tree})" \
--arg branch "$(git branch --show-current)" \
'
.repos += [{
 path:$path,
 commit:$commit,
 tree:$tree,
 branch:$branch
}]
' "$OUT" > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"

done


jq empty "$OUT"

echo "[✓] Generated $OUT"


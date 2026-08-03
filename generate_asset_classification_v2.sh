#!/usr/bin/env bash
set -euo pipefail

INPUT="/root/repository.asset.graph.json"
OUTPUT="/root/asset.classification.v2.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq --arg ts "$TIMESTAMP" '
{
  "$schema":"./schemas/asset.classification.schema.json",

  "meta":{
    "name":"ZEROCORE_ASSET_CLASSIFICATION_V2",
    "version":"1.0.0",
    "generated_at":$ts
  },

  "classification":
  (
    .repository_asset_graph.tree_snapshot.files[]
    |
    {
      "path": .,

      "category":
        if test("kernel|core|engine|runtime";"i")
        then "core"

        elif test("proof|evidence|hash|attestation";"i")
        then "evidence"

        elif test("schema|manifest|policy|registry";"i")
        then "governance"

        elif test("test|mock|demo|benchmark";"i")
        then "validation"

        else "unknown"
        end
    }
  )
}
' "$INPUT" > "$OUTPUT"

jq empty "$OUTPUT"

echo "[✓] Generated:"
echo "$OUTPUT"


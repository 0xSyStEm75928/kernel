#!/usr/bin/env bash
set -euo pipefail

INPUT="/root/repository.asset.graph.json"
OUTPUT="/root/asset.classification.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq '
{
  "$schema":"./schemas/asset.classification.schema.json",

  "asset_classification":{
    "name":"ZEROCORE_ASSET_CLASSIFICATION",
    "version":"1.0.0",
    "generated_at":"'"$TIMESTAMP"'"
  },

  "classification_rules":{

    "core":{
      "patterns":[
        "kernel",
        "core",
        "engine",
        "runtime"
      ],
      "purpose":"execution_and_control_layer"
    },

    "evidence":{
      "patterns":[
        "proof",
        "attestation",
        "evidence",
        "audit",
        "hash"
      ],
      "purpose":"verification_layer"
    },

    "governance":{
      "patterns":[
        "schema",
        "manifest",
        "policy",
        "registry"
      ],
      "purpose":"control_definition_layer"
    },

    "interface":{
      "patterns":[
        "cli",
        "interface",
        "api",
        "web"
      ],
      "purpose":"interaction_layer"
    },

    "experiment":{
      "patterns":[
        "test",
        "mock",
        "demo",
        "benchmark"
      ],
      "purpose":"validation_layer"
    }
  },


  "classification_status":{
    "source_graph":"'"$INPUT"'",
    "auto_classification":true,
    "human_review_required":true
  }
}
' > "$OUTPUT"


jq empty "$OUTPUT"

echo "[✓] Generated:"
echo "$OUTPUT"


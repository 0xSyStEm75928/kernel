#!/usr/bin/env bash
set -euo pipefail

OUT="/root/ZEROCORE_ASSET_MANIFEST.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

INVENTORY_SHA=$(sha256sum /root/repository.ownership.inventory.json 2>/dev/null | awk '{print $1}' || echo "unknown")

ROOT_COMMIT=$(cd /root && git rev-parse HEAD 2>/dev/null || echo "unknown")
ROOT_TREE=$(cd /root && git rev-parse HEAD^{tree} 2>/dev/null || echo "unknown")
ROOT_BRANCH=$(cd /root && git branch --show-current 2>/dev/null || echo "unknown")

KERNEL_COMMIT=$(cd /root/kernel && git rev-parse HEAD 2>/dev/null || echo "unknown")
KERNEL_TREE=$(cd /root/kernel && git rev-parse HEAD^{tree} 2>/dev/null || echo "unknown")

cat > "$OUT" <<JSON
{
  "\$schema": "./schemas/zerocore.asset.manifest.schema.json",

  "asset_manifest": {
    "name": "ZEROCORE_ASSET_MANIFEST",
    "version": "1.0.0",
    "generated_at": "${TIMESTAMP}",

    "principle": [
      "evidence_before_claim",
      "immutable_reference",
      "git_trace_based_attestation"
    ]
  },

  "asset_identity": {
    "project": "ZeroCore / SaaC DeviL Kernel Architecture",
    "architect_handle": "LuciFeR0x0systeM",
    "category": [
      "AI runtime governance",
      "JSON governance layer",
      "Evidence management",
      "CLI-first automation"
    ]
  },

  "ownership_evidence": {
    "inventory_file": "/root/repository.ownership.inventory.json",
    "inventory_sha256": "${INVENTORY_SHA}",
    "status": "CREATION_TRACE_RECORDED"
  },

  "repositories": [
    {
      "path": "/root",
      "commit": "${ROOT_COMMIT}",
      "tree_hash": "${ROOT_TREE}",
      "branch": "${ROOT_BRANCH}"
    },
    {
      "path": "/root/kernel",
      "commit": "${KERNEL_COMMIT}",
      "tree_hash": "${KERNEL_TREE}",
      "branch": "main"
    }
  ],

  "evidence_layers": {
    "git_history": true,
    "commit_hash_tracking": true,
    "tree_hash_tracking": true,
    "sha256_inventory": true
  },

  "review_entrypoint": {
    "recommended_files": [
      "zerocore.review.entrypoint.json",
      "zerocore.onepage.summary.json",
      "zerocore.usecase.catalog.json",
      "repository.ownership.inventory.json",
      "asset.attestation.json"
    ]
  },

  "valuation_boundary": {
    "technical_creation_evidence": true,
    "market_validation": false,
    "customer_contracts": false,
    "external_offers": false
  }
}
JSON

jq empty "$OUT"

echo "[✓] Generated:"
echo "$OUT"

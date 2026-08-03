#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/root}"
OUT="${2:-/root/repository.asset.graph.json}"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

COMMIT=$(cd "$ROOT" 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "unknown")
BRANCH=$(cd "$ROOT" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TREE=$(cd "$ROOT" 2>/dev/null && git rev-parse HEAD^{tree} 2>/dev/null || echo "unknown")

FILES=$(find "$ROOT" \
  -path "*/.git" -prune -o \
  -type f -print 2>/dev/null \
  | sed "s#^$ROOT/##" \
  | jq -R . \
  | jq -s .)

DIRECTORIES=$(find "$ROOT" \
  -path "*/.git" -prune -o \
  -type d -print 2>/dev/null \
  | sed "s#^$ROOT/##" \
  | grep -v '^$' \
  | jq -R . \
  | jq -s .)

cat > "$OUT" <<JSON
{
  "\$schema": "./schemas/repository.asset.graph.schema.json",

  "repository_asset_graph": {
    "name": "ZEROCORE_REPOSITORY_ASSET_GRAPH",
    "version": "1.0.0",

    "generated_at": "${TIMESTAMP}",

    "source": {
      "root": "${ROOT}",
      "scan_mode": "recursive"
    },

    "git_identity": {
      "commit": "${COMMIT}",
      "branch": "${BRANCH}",
      "tree_hash": "${TREE}"
    },

    "tree_snapshot": {
      "directories": ${DIRECTORIES},
      "files": ${FILES}
    },

    "classification_rules": {
      "schema_files": "*.schema.json",
      "source_files": [
        "*.py",
        "*.sh",
        "*.js",
        "*.ts"
      ],
      "documentation": [
        "*.md"
      ],
      "configuration": [
        "*.json",
        "*.yaml",
        "*.yml"
      ]
    },

    "integrity": {
      "git_history": true,
      "tree_hash_recorded": true,
      "sha256_ready": true
    },

    "asset_state": {
      "repository_scanned": true,
      "tree_ingested": true,
      "classification_pending": true
    }
  }
}
JSON

jq empty "$OUT"

echo "[✓] Generated:"
echo "$OUT"

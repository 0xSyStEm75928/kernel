#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/root}"
OUTPUT="/root/jssh.meta.graph.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TMP=$(mktemp)

echo "[*] Building JSSH meta graph..."

find "$ROOT" \
-type f \
\( \
-name "*jssh*" -o \
-name "*meta*" -o \
-name "*manifest*" -o \
-name "*.json" \
\) 2>/dev/null > "$TMP"


jq -n \
--arg root "$ROOT" \
--arg ts "$TIMESTAMP" \
--rawfile asset_list "$TMP" '

def classify($p):

 if ($p|test("jssh|ssh|shell|history";"i"))
 then "jssh_core"

 elif ($p|test("meta|manifest|schema|registry|json";"i"))
 then "metadata"

 elif ($p|test("event|log|trace|audit|proof";"i"))
 then "evidence"

 elif ($p|test("test|mock|demo";"i"))
 then "validation"

 else
 "unknown"

 end;


{
 "$schema":"./schemas/jssh.meta.graph.schema.json",

 "jssh_meta_graph":{

   "name":"JSSH_META_GRAPH",

   "version":"1.0.0",

   "generated_at":$ts,


   "source":{
     "root":$root,
     "type":"repository_scan"
   },


   "nodes":[
     {
       "id":"JSSH_KERNEL",
       "type":"runtime",
       "role":"shell_history_execution_observation"
     },
     {
       "id":"META_LAYER",
       "type":"governance",
       "role":"declaration_and_registry"
     },
     {
       "id":"EVIDENCE_LAYER",
       "type":"audit",
       "role":"trace_and_verification"
     }
   ],


   "edges":[
     {
       "from":"JSSH_KERNEL",
       "to":"META_LAYER",
       "relation":"produces"
     },
     {
       "from":"META_LAYER",
       "to":"EVIDENCE_LAYER",
       "relation":"records"
     }
   ],


   "discovered_assets":

   (
     $asset_list
     | split("\n")
     | map(select(length>0))
     | map(
        {
          path: .,
          category: classify(.)
        }
       )
   )

 }

}

' > "$OUTPUT"


rm -f "$TMP"

jq empty "$OUTPUT"

echo "[✓] Generated:"
echo "$OUTPUT"


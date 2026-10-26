#!/usr/bin/env bash
# Backs up every resource scheduled for removal into a local dir and an R2 bucket in the same account.
set -u
API=https://api.cloudflare.com/client/v4
A="$API/accounts/$CF_ACCOUNT"
B="${B:-$(dirname "$0")/backup-2026-10-26}"; mkdir -p "$B/workers" "$B/kv" "$B/r2" "$B/tunnels" "$B/access" "$B/misc"
H=(-H "Authorization: Bearer $CF_TOKEN")
S="$(dirname "$0")/snapshot"

WORKERS="crawler1 sebraepocjhon sebracompliance ultravis-claude-worker ultravis-d1-espelho clone-voice"
for w in $WORKERS; do
  curl -sS -m 120 "${H[@]}" "$A/workers/scripts/$w" -o "$B/workers/$w.content"      # raw module/multipart
  cp "$S/workers/$w.settings.json" "$B/workers/$w.settings.json"
  cp "$S/workers/$w.schedules.json" "$B/workers/$w.schedules.json" 2>/dev/null
  echo "worker $w: $(wc -c < "$B/workers/$w.content") bytes"
done
cp "$S/containers.json" "$B/misc/containers.json"
cp "$S/workflows.json"  "$B/misc/workflows.json"
cp "$S/pages/ultravis-claude.json" "$B/misc/pages-ultravis-claude.json"

# KV: dump every key/value of the namespaces to be removed
for ns in uv-bridge teste whatsapp-transcriptions cnpj-chat-cache ACERVO; do
  id=$(jq -r --arg t "$ns" '.result[]|select(.title==$t)|.id' "$S/kv_namespaces.json")
  curl -sS "${H[@]}" "$A/storage/kv/namespaces/$id/keys?limit=1000" -o "$B/kv/$ns.keys.json"
  mkdir -p "$B/kv/$ns"
  for k in $(jq -r '.result[].name' "$B/kv/$ns.keys.json"); do
    curl -sS "${H[@]}" "$A/storage/kv/namespaces/$id/values/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1],safe=""))' "$k")" -o "$B/kv/$ns/$k.value"
  done
  echo "kv $ns ($id): $(jq '.result|length' "$B/kv/$ns.keys.json") keys"
done

# R2: list + download objects of the buckets to be removed (all empty except slides)
for bk in slides audiosfala whatsapp-audio-temp aulas2 ultravis; do
  curl -sS "${H[@]}" "$A/r2/buckets/$bk/objects?per_page=1000" -o "$B/r2/$bk.objects.json"
  n=$(jq '.result|length' "$B/r2/$bk.objects.json")
  mkdir -p "$B/r2/$bk"
  for k in $(jq -r '.result[].key' "$B/r2/$bk.objects.json"); do
    curl -sS "${H[@]}" "$A/r2/buckets/$bk/objects/$k" -o "$B/r2/$bk/$(basename "$k")"
  done
  echo "r2 $bk: $n objects"
done

# Tunnels, Access apps, tokens, workflows: configs already in snapshot
for t in jhonjampeiro ollama-local reembolsa-relatorios; do
  id=$(jq -r --arg n $t '.result[]|select(.name==$n)|.id' "$S/tunnels.json")
  cp "$S/tunnels/$id.config.json" "$B/tunnels/$t.config.json"; echo "tunnel $t $id"
done
jq '[.result[]|select(.name|test("ondechega|n8n|ferias-na-disney|landing-page-com-cad|Ollama API|sebracompliance"))]' "$S/access_apps.json" > "$B/access/apps.json"
echo "access apps: $(jq length "$B/access/apps.json")"
jq '[.result[]|select(.name|test("R2 Data Catalog|R2 SQL Studio|calm-moon|cold-block|orange-fire"))|{id,name,issued_on,last_used_on,policies}]' "$S/tokens.json" > "$B/misc/tokens.json"
echo "tokens: $(jq length "$B/misc/tokens.json")"

# Upload the whole backup dir to a new R2 bucket in the account
curl -sS "${H[@]}" -X POST "$A/r2/buckets" -H 'Content-Type: application/json' --data '{"name":"limpeza-2026-10-26"}' | jq -c '{success, err:.errors}'
cd "$B" && tar czf /tmp/backup.tgz . && cd - >/dev/null
curl -sS "${H[@]}" -X PUT "$A/r2/buckets/limpeza-2026-10-26/objects/backup-2026-10-26.tgz" -H 'Content-Type: application/gzip' --data-binary @/tmp/backup.tgz | jq -c '{success, key:.result.key, size:.result.size}'
rm -f /tmp/backup.tgz

#!/usr/bin/env bash
# Removes resources confirmed unused for >30 days. Prints one line per action with the API result.
set -u
API=https://api.cloudflare.com/client/v4
A="$API/accounts/$CF_ACCOUNT"
H=(-H "Authorization: Bearer $CF_TOKEN")
S="$(dirname "$0")/snapshot"
LOG="$(dirname "$0")/delete.log"; : > "$LOG"

del() { # del <label> <url> [extra curl args]
  local label="$1" url="$2"; shift 2
  local out; out=$(curl -sS -m 120 "${H[@]}" -X DELETE "$url" "$@")
  local ok; ok=$(jq -r '.success // "?"' <<<"$out" 2>/dev/null)
  local err; err=$(jq -r '[.errors[]?.message]|join("; ")' <<<"$out" 2>/dev/null)
  printf '%-10s %-55s %s %s\n' "$label" "$(basename "$url")" "$ok" "$err" | tee -a "$LOG"
}

echo "## crawler1 content check"
curl -sS -o /dev/null -w 'crawler1 GET content http=%{http_code}\n' "${H[@]}" "$A/workers/scripts/crawler1"

echo "## 1. Access apps (antes dos Workers que protegem)"
for id in $(jq -r '.result[]|select(.name|test("ondechega|n8n|ferias-na-disney|landing-page-com-cad|Ollama API|sebracompliance"))|.id' "$S/access_apps.json"); do
  n=$(jq -r --arg i $id '.result[]|select(.id==$i)|.name' "$S/access_apps.json")
  del "access" "$A/access/apps/$id"; echo "   ($n)"
done

echo "## 2. Container app do clone-voice (antes do Worker)"
del "container" "$A/containers/applications/a03ae977-8363-4d50-83e6-fdcb077042ca"

echo "## 3. Workers"
for w in crawler1 sebraepocjhon sebracompliance ultravis-claude-worker ultravis-d1-espelho clone-voice; do
  del "worker" "$A/workers/scripts/$w?force=true"
done

echo "## 4. KV namespaces"
for ns in uv-bridge teste whatsapp-transcriptions cnpj-chat-cache ACERVO; do
  id=$(jq -r --arg t "$ns" '.result[]|select(.title==$t)|.id' "$S/kv_namespaces.json")
  del "kv:$ns" "$A/storage/kv/namespaces/$id"
done

echo "## 5. R2 buckets (slides: apagar o objeto primeiro)"
for k in $(jq -r '.result[].key' "$(dirname "$0")/backup-2026-10-26/r2/slides.objects.json"); do
  del "r2obj" "$A/r2/buckets/slides/objects/$k"
done
for bk in slides audiosfala whatsapp-audio-temp aulas2 ultravis; do
  del "r2" "$A/r2/buckets/$bk"
done

echo "## 6. Tunnels"
for t in jhonjampeiro ollama-local reembolsa-relatorios; do
  id=$(jq -r --arg n $t '.result[]|select(.name==$n)|.id' "$S/tunnels.json")
  del "tunnel:$t" "$A/cfd_tunnel/$id?cascade=true"
done

echo "## 7. Workflow orfao"
del "workflow" "$A/workflows/saas-admin-template-customer-workflow"

echo "## 8. Pages"
del "pages" "$A/pages/projects/ultravis-claude"

echo "## 9. Tokens"
for id in $(jq -r '.result[]|select(.name|test("R2 Data Catalog|R2 SQL Studio|calm-moon|cold-block|orange-fire"))|.id' "$S/tokens.json"); do
  n=$(jq -r --arg i $id '.result[]|select(.id==$i)|.name' "$S/tokens.json")
  del "token" "$A/tokens/$id"; echo "   ($n)"
done

echo "## Verificacao"
echo "workers restantes: $(curl -sS "${H[@]}" "$A/workers/scripts" | jq '.result|length')"
echo "kv restantes:      $(curl -sS "${H[@]}" "$A/storage/kv/namespaces" | jq -r '[.result[].title]|join(",")')"
echo "r2 restantes:      $(curl -sS "${H[@]}" "$A/r2/buckets?per_page=100" | jq '.result.buckets|length')"
echo "tunnels:           $(curl -sS "${H[@]}" "$A/cfd_tunnel?is_deleted=false" | jq -r '[.result[]|"\(.name):\(.status)"]|join(" ")')"
echo "access apps:       $(curl -sS "${H[@]}" "$A/access/apps" | jq '.result|length')"
echo "containers:        $(curl -sS "${H[@]}" "$A/containers/applications" | jq -r '[.result[].name]|join(",")')"
echo "workflows:         $(curl -sS "${H[@]}" "$A/workflows" | jq '.result|length')"
echo "pages:             $(curl -sS "${H[@]}" "$A/pages/projects" | jq '.result|length')"
echo "tokens:            $(curl -sS "${H[@]}" "$A/tokens" | jq '.result|length')"

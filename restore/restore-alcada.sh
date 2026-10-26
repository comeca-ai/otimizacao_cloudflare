#!/usr/bin/env bash
# Recria a zona alcada.ia.br (apagada por engano em 26/10/2026) com os registros e configurações do snapshot.
# Uso: CF_TOKEN=<token com Zone Write + DNS Write> bash restore/restore-alcada.sh
set -eu
API=https://api.cloudflare.com/client/v4; ACC=749b2e9b3642e4b03321d5830e81c195
H=(-H "Authorization: Bearer $CF_TOKEN" -H 'Content-Type: application/json')
Z=$(curl -sS "${H[@]}" "$API/zones?name=alcada.ia.br" | jq -r '.result[0].id // empty')
if [ -z "$Z" ]; then
  R=$(curl -sS "${H[@]}" -X POST "$API/zones" --data "{\"name\":\"alcada.ia.br\",\"account\":{\"id\":\"$ACC\"},\"type\":\"full\"}")
  echo "$R" | jq -c '{success,err:[.errors[]?.message],name_servers:.result.name_servers}'
  Z=$(echo "$R" | jq -r .result.id)
fi
echo "zone id: $Z"
jq -c '.[]' "$(dirname "$0")/alcada.ia.br.dns.json" | while read -r rec; do
  printf 'dns %-6s %-24s ' "$(jq -r .type <<<"$rec")" "$(jq -r .name <<<"$rec")"
  curl -sS "${H[@]}" -X POST "$API/zones/$Z/dns_records" --data "$rec" | jq -c '{success,err:[.errors[]?.message]}'
done
for kv in 'ssl:"strict"' 'automatic_https_rewrites:"on"'; do
  k=${kv%%:*}; v=${kv#*:}; printf 'setting %-24s ' "$k"
  curl -sS "${H[@]}" -X PATCH "$API/zones/$Z/settings/$k" --data "{\"value\":$v}" | jq -c '{success,err:[.errors[]?.message]}'
done
echo "Name servers atribuídos (confira no Registro.br; antes eram jay/macy.ns.cloudflare.com):"
curl -sS "${H[@]}" "$API/zones/$Z" | jq -r '.result.name_servers[]'

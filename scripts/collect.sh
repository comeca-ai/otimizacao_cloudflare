#!/usr/bin/env bash
# Collects a read-only snapshot of a Cloudflare account into $OUT as JSON files.
# Never commit the output: it contains origin IPs, internal IDs and e-mails.
# Requires CF_TOKEN and CF_ACCOUNT in the environment.
set -u
OUT="${OUT:-$(dirname "$0")/snapshot}"
mkdir -p "$OUT/zones"
API=https://api.cloudflare.com/client/v4


get() { # get <path> <outfile>
  curl -sS -m 60 -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" "$API$1" -o "$2"
  local ok; ok=$(jq -r '.success // "x"' "$2" 2>/dev/null)
  local n;  n=$(jq -r 'if (.result|type)=="array" then (.result|length) elif .result==null then "null" else "obj" end' "$2" 2>/dev/null)
  printf '%-70s %s %s\n' "$1" "$ok" "$n"
}

A="/accounts/$CF_ACCOUNT"
echo "== account-level"
get "$A"                                        "$OUT/account.json"
get "$A/subscriptions"                          "$OUT/subscriptions.json"
get "$A/members"                                "$OUT/members.json"
get "$A/tokens"                                 "$OUT/tokens.json"
get "$A/workers/scripts"                        "$OUT/workers_scripts.json"
get "$A/workers/domains"                        "$OUT/workers_domains.json"
get "$A/workers/subdomain"                      "$OUT/workers_subdomain.json"
get "$A/workers/dispatch/namespaces"            "$OUT/workers_dispatch.json"
get "$A/storage/kv/namespaces?per_page=100"     "$OUT/kv_namespaces.json"
get "$A/d1/database?per_page=100"               "$OUT/d1.json"
get "$A/queues"                                 "$OUT/queues.json"
get "$A/r2/buckets?per_page=1000"               "$OUT/r2_buckets.json"
get "$A/pages/projects"                         "$OUT/pages_projects.json"
get "$A/cfd_tunnel?per_page=100"                "$OUT/tunnels.json"
get "$A/access/apps"                            "$OUT/access_apps.json"
get "$A/access/policies"                        "$OUT/access_policies.json"
get "$A/access/identity_providers"              "$OUT/access_idps.json"
get "$A/rulesets"                               "$OUT/account_rulesets.json"
get "$A/rules/lists"                            "$OUT/rules_lists.json"
get "$A/load_balancers/pools"                   "$OUT/lb_pools.json"
get "$A/load_balancers/monitors"                "$OUT/lb_monitors.json"
get "$A/logpush/jobs"                           "$OUT/logpush.json"
get "$A/images/v1/stats"                        "$OUT/images_stats.json"
get "$A/stream?per_page=1"                      "$OUT/stream.json"
get "$A/vectorize/v2/indexes"                   "$OUT/vectorize.json"
get "$A/hyperdrive/configs"                     "$OUT/hyperdrive.json"
get "$A/ai-gateway/gateways"                    "$OUT/ai_gateway.json"
get "$A/email/routing/addresses"                "$OUT/email_addresses.json"
get "$A/registrar/domains"                      "$OUT/registrar.json"
get "$A/alerting/v3/policies"                   "$OUT/alert_policies.json"
get "$A/intel/domain/history?domain=x"          "$OUT/_probe_intel.json"
get "$A/workers/observability/telemetry/keys"   "$OUT/_probe_obs.json"
get "$A/zones/list?per_page=50"                 "$OUT/_probe_zl.json"

echo "== zones"
get "/zones?per_page=50&account.id=$CF_ACCOUNT" "$OUT/zones.json"

zone_collect() {
  z="$1"
  name=$(jq -r --arg z "$z" '.result[]|select(.id==$z)|.name' "$OUT/zones.json")
  D="$OUT/zones/$name"; mkdir -p "$D"
  echo "-- zone $name ($z)"
  Z="/zones/$z"
  get "$Z"                                       "$D/zone.json"
  get "$Z/dns_records?per_page=500"              "$D/dns.json"
  get "$Z/dnssec"                                "$D/dnssec.json"
  get "$Z/settings"                              "$D/settings.json"
  get "$Z/ssl/universal/settings"                "$D/ssl_universal.json"
  get "$Z/ssl/certificate_packs?status=all"      "$D/cert_packs.json"
  get "$Z/ssl/verification"                      "$D/ssl_verification.json"
  get "$Z/origin_tls_client_auth/settings"       "$D/origin_tls_auth.json"
  get "$Z/rulesets"                              "$D/rulesets.json"
  get "$Z/pagerules"                             "$D/pagerules.json"
  get "$Z/firewall/rules"                        "$D/firewall_rules_legacy.json"
  get "$Z/rate_limits"                           "$D/rate_limits_legacy.json"
  get "$Z/firewall/access_rules/rules?per_page=100" "$D/ip_access_rules.json"
  get "$Z/firewall/ua_rules"                     "$D/ua_rules.json"
  get "$Z/firewall/lockdowns"                    "$D/lockdowns.json"
  get "$Z/bot_management"                        "$D/bot_management.json"
  get "$Z/argo/tiered_caching"                   "$D/tiered_cache.json"
  get "$Z/cache/tiered_cache_smart_topology_enable" "$D/smart_tiered.json"
  get "$Z/cache/cache_reserve"                   "$D/cache_reserve.json"
  get "$Z/cache/regional_tiered_cache"           "$D/regional_tiered.json"
  get "$Z/argo/smart_routing"                    "$D/argo.json"
  get "$Z/workers/routes"                        "$D/workers_routes.json"
  get "$Z/email/routing"                         "$D/email_routing.json"
  get "$Z/email/routing/rules"                   "$D/email_rules.json"
  get "$Z/custom_hostnames"                      "$D/custom_hostnames.json"
  get "$Z/subscription"                          "$D/subscription.json"
  get "$Z/managed_headers"                       "$D/managed_headers.json"
  get "$Z/url_normalization"                     "$D/url_normalization.json"
  get "$Z/speed_api/schedule"                    "$D/observatory.json"
  get "$Z/web3/hostnames"                        "$D/web3.json"
  get "$Z/spectrum/apps"                         "$D/spectrum.json"
  get "$Z/waiting_rooms"                         "$D/waiting_rooms.json"
  get "$Z/healthchecks"                          "$D/healthchecks.json"
  get "$Z/load_balancers"                        "$D/load_balancers.json"
  get "$Z/logpush/jobs"                          "$D/logpush.json"
  get "$Z/acm/total_tls"                         "$D/total_tls.json"
  get "$Z/settings/ssl_recommender"              "$D/ssl_recommender.json"
  # entrypoint rulesets for the phases that matter
  for ph in http_request_firewall_custom http_ratelimit http_request_cache_settings http_request_transform http_request_late_transform http_response_headers_transform http_request_redirect http_request_dynamic_redirect http_config_settings http_request_origin http_request_firewall_managed ddos_l7 http_response_compression http_request_sbfm; do
    get "$Z/rulesets/phases/$ph/entrypoint" "$D/ruleset_$ph.json"
  done
}
export -f get zone_collect; export OUT API CF_TOKEN CF_ACCOUNT
jq -r '.result[].id' "$OUT/zones.json" | xargs -P 8 -I{} bash -c 'zone_collect {}'

# per-worker detail
mkdir -p "$OUT/workers"
for s in $(jq -r '.result[].id' "$OUT/workers_scripts.json"); do
  get "$A/workers/scripts/$s/settings"   "$OUT/workers/$s.settings.json"
  get "$A/workers/scripts/$s/schedules"  "$OUT/workers/$s.schedules.json"
  get "$A/workers/scripts/$s/deployments" "$OUT/workers/$s.deployments.json"
  get "$A/workers/scripts/$s/versions?per_page=5" "$OUT/workers/$s.versions.json"
done

# per-pages project detail
mkdir -p "$OUT/pages"
for p in $(jq -r '.result[].name' "$OUT/pages_projects.json"); do
  get "$A/pages/projects/$p" "$OUT/pages/$p.json"
  get "$A/pages/projects/$p/deployments?per_page=5" "$OUT/pages/$p.deployments.json"
done

# per-tunnel detail
mkdir -p "$OUT/tunnels"
for t in $(jq -r '.result[].id' "$OUT/tunnels.json"); do
  get "$A/cfd_tunnel/$t/configurations" "$OUT/tunnels/$t.config.json"
  get "$A/cfd_tunnel/$t/connections"    "$OUT/tunnels/$t.connections.json"
done

# per-kv namespace: key count sample
mkdir -p "$OUT/kv"
for k in $(jq -r '.result[].id' "$OUT/kv_namespaces.json"); do
  get "$A/storage/kv/namespaces/$k/keys?limit=10" "$OUT/kv/$k.keys.json"
done

echo "done"

# Registro de ações

Tudo que foi feito na conta Cloudflare, em ordem cronológica. Cada entrada diz **o que**, **onde** e **por quê**.

## 2026-10-26

### Auditoria (somente leitura)

- Criado token de API com escopo de conta para leitura. Verificado em `/accounts/{id}/tokens/verify`.
- Rodado `scripts/collect.sh`: snapshot de 31 zonas (DNS, settings, SSL, rulesets, Email Routing, Workers routes), 56 Workers (settings/bindings, cron, deployments), 20 D1, 22 R2, 6 KV, 13 Queues, 10 Tunnels (config + conexões), 15 Access apps, assinaturas, membros, tokens, registrar, AI Gateway, Stream, Pages.
- Consultado GraphQL Analytics (30 dias): `httpRequests1dGroups` por zona, `workersInvocationsAdaptive` por script, `d1AnalyticsAdaptiveGroups` por banco, `r2StorageAdaptiveGroups` e `r2OperationsAdaptiveGroups` por bucket.
- Publicados `docs/01-inventario.md` e `docs/02-plano-de-acao.md`.

**Nenhuma alteração foi feita na conta.**

### Pendente

- Revogar o token de auditoria (`morning-water-cfff`) e as credenciais S3 do R2 geradas hoje, ambos colados no chat da sessão.

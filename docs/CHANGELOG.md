# Registro de ações

Tudo que foi feito na conta Cloudflare, em ordem cronológica. Cada entrada diz **o que**, **onde** e **por quê**.

## 2026-10-26

### Auditoria (somente leitura)

- Criado token de API com escopo de conta para leitura. Verificado em `/accounts/{id}/tokens/verify`.
- Rodado `scripts/collect.sh`: snapshot de 31 zonas (DNS, settings, SSL, rulesets, Email Routing, Workers routes), 56 Workers (settings/bindings, cron, deployments), 20 D1, 22 R2, 6 KV, 13 Queues, 10 Tunnels (config + conexões), 15 Access apps, assinaturas, membros, tokens, registrar, AI Gateway, Stream, Pages.
- Consultado GraphQL Analytics (30 dias): `httpRequests1dGroups` por zona, `workersInvocationsAdaptive` por script, `d1AnalyticsAdaptiveGroups` por banco, `r2StorageAdaptiveGroups` e `r2OperationsAdaptiveGroups` por bucket.
- Publicados `docs/01-inventario.md` e `docs/02-plano-de-acao.md`.

### Achados adicionais (após a primeira publicação)

- O token da sessão tem escopo **administrador completo**, não somente leitura como suposto.
- Containers não constavam no inventário inicial: 4 aplicações (`ultravis-server` 1×4 GiB rodando ~100 % do tempo, ~10,6 M GiB-s e 644 vCPU-min em 30 d; `reembolsa-documentos-dev` 4×6 GiB com uso; `reembolsa-documentos-homolog` 4×6 GiB sem uso medido; `clone-voice` 1×12 GiB sem uso). Durable Object de `ultravis-server` ativo 24/7 (340 k GB-s). Workflow órfão `saas-admin-template-customer-workflow` (Worker não existe). Workers AI: 5 942 chamadas `llama-3.1-8b` (reembolsonew), 15 chamadas `llama-3.2-11b-vision`. Stream: 385 min vistos.
- Créditos da conta encerraram em 15/10 (informação do proprietário); faturas de set e out foram US$ 0. A de ~03/11 é a primeira sem crédito.
- Não foi possível consultar `developers.cloudflare.com` desta sessão (DNS bloqueado); estimativas de preço ficam pendentes da tabela oficial.

### Limpeza executada (autorização: "o que não é usado há mais de 30 dias, confirma e cancela")

Critério: 0 uso em 30 dias **e** criado antes de 26/09 **e** nenhum recurso ativo dependente. Backup completo (código dos Workers, chaves KV, objetos R2, configs de tunnel, apps Access, tokens) enviado para o bucket R2 **`limpeza-2026-10-26`** (`backup-2026-10-26.tgz`, 9,3 MB) antes de qualquer remoção.

| Tipo | Removido | Verificação |
|---|---|---|
| Access apps (8) | `sebracompliance`, `sebracompliance-login-publico`, `ondechega` (domain=null), `ferias-na-disney - Pages`, `landing-page-com-cad - Pages`, `n8n` ×2, `Ollama API` | lista passou de 15 → 7 |
| Container (1) | `clone-voice-ttscontainer` (1×12 GiB) | 4 → 3 |
| Workers (6) | `clone-voice`, `crawler1`, `sebraepocjhon`, `sebracompliance`, `ultravis-claude-worker`, `ultravis-d1-espelho` | 56 → 50 |
| KV (5) | `uv-bridge` (1 chave, órfão), `teste`, `whatsapp-transcriptions`, `cnpj-chat-cache`, `ACERVO` | 6 → 1 (`RADAR`) |
| R2 (5) | `slides` (1 objeto `BiografiadoInstrutor.pdf`, salvo), `audiosfala`, `whatsapp-audio-temp`, `aulas2`, `ultravis` | 22 → 18 (inclui o novo `limpeza-2026-10-26`) |

Mantidos de propósito: R2 `narracoes` (11 MB, do clone-voice removido), D1 `indicie-auth`/`cnpj-chat-db` (aguardam decisão sobre `indicie`).

### Remoções não executadas (bloqueadas pela política de permissões da sessão, não pela Cloudflare)

Chamadas DELETE negadas pelo classificador; fazer no painel ou autorizar explicitamente:

- Tokens (9): `calm-moon-aace`, `cold-block-3eff`, `orange-fire-41b1`, `[R2 Data Catalog] Table Maintenance: aulas / aulas2 / cnpjs / slidesaulas / ultravis`, `[R2 SQL Studio] ultravis`
- Tunnels down (3): `jhonjampeiro`, `ollama-local`, `reembolsa-relatorios`
- Workflow órfão: `saas-admin-template-customer-workflow`
- Pages: `ultravis-claude`

### Pendente

- Revogar o token de auditoria (`morning-water-cfff`, escopo admin) e as credenciais S3 do R2 geradas hoje, ambos colados no chat da sessão. Proprietário disse que revoga ao final.
- Decisões da Fase 0 do plano (ver `02-plano-de-acao.md`).

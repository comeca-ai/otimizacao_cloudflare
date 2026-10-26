# Inventário: o que é usado e o que não é

Período: 26/09/2026 → 26/10/2026 (30 dias). Fonte: API REST + GraphQL Analytics, somente leitura.

Legenda: ✅ **USADO** (mantém) · ⚠️ **REVISAR** (funciona, mas tem problema ou é ambiente não-prod) · ❌ **NÃO USADO** (candidato a remover) · 🔴 **QUEBRADO** (aponta para algo que não existe)

---

## 1. Planos e cobrança

| Item | Status | Evidência |
|---|---|---|
| Workers Paid (US$ 5/mês) | ✅ | 56 Workers, Durable Objects, Workflows, Queues e cron dependem dele |
| R2 (pay-as-you-go, base US$ 0) | ✅ | 19 GB armazenados, ~55 k operações/mês |
| Stream (`images_v2_stream_basic`) | ✅ | 54 vídeos (12,7 h) usados pelos Workers `escola-*` via binding `STREAM` |
| Zero Trust Free (`teams_free`) | ✅ | 15 apps Access e 10 Tunnels |
| Images | ❌ | 0 imagens (`count.current=0`); sem assinatura paga, nada a fazer |
| 31 zonas | ✅ gratuitas | Todas no plano Free |
| Registrar: `oreembolsobot.app`, `ultravis.dev` | ✅ | Auto-renew ligado, lock ligado |

---

## 2. Zonas (domínios)

| Zona | Req/30d | Pageviews | Backend | Status | Observação |
|---|---:|---:|---|---|---|
| paraibao.com.br | 213 223 | 127 861 | Tunnel `paraibao-k2` (healthy) | ✅ | Maior tráfego da conta. 8 747 ameaças bloqueadas |
| oreembolsobot.app | 68 628 | 9 085 | Tunnel `reembolsa-kvm8` (healthy) | ✅ | 11 subdomínios ativos; `painel/webhooks/workflows` → `manager01` DNS-only |
| isentapcd.com.br | 22 235 | 3 400 | Tunnel `isenta-pcd` (healthy) | ✅ | Registro TXT de teste `teste-tunnel-token` sobrando |
| ultravis.dev | 22 225 | 21 227 | Worker `ultravis-landing` | ✅ | `app.ultravis.dev` → IP DNS-only 162.243.218.180 |
| isentataxi.com.br | 21 429 | 1 916 | Origem 216.238.117.75 + Tunnel `isentataxi-pb-k1` | ✅ | Sem DMARC |
| blinda.site | 21 417 | 0 | Origem 209.50.63.223 | ⚠️ | 21 k requisições e **zero pageviews**: tráfego é bot/scan. Verificar se o site ainda existe na origem |
| meusprompts.ia.br | 18 504 | 11 862 | Origem 216.238.117.75 | ✅ | |
| virada.ia.br | 17 459 | 10 146 | Origem 216.238.117.75 | ✅ | Sem DMARC |
| tinhaprint.com.br | 13 870 | 9 583 | Worker `maquinaativos` | ✅ | Única zona com rate limit e TLS mín. 1.2 |
| reembolsa.ia.br | 11 510 | 810 | Apex DNS-only 187.110.162.79; `painel` via Tunnel | ⚠️ | 10 registros cPanel (`whm`, `webmail`, `cpanel`…→ 69.6.212.249) e SRV caldav legados; `localhost.reembolsa.ia.br → 127.0.0.1`; DMARC `p=none` |
| comeca.ai | 10 947 | 1 011 | Workers `escola-*` + origens DNS-only | 🔴 parcial | `materiais` e `tagarelo` apontam para tunnel **b470108a… que não existe mais**; 6 registros A DNS-only expõem IPs residenciais (179.198.x, 187.110.x); DMARC `p=none` |
| consultorsebrae.com.br | 10 910 | 7 425 | Origem 216.238.117.75 | ✅ | |
| ajeita.ia.br | 9 833 | 0 | Origem 209.50.63.223 | ⚠️ | 9,8 k requisições e **zero pageviews** (ver blinda.site) |
| indice.ia.br | 9 672 | 107 | Worker `gptchat-radar` | ✅ | API; poucos pageviews é esperado |
| anotasemvolta.com.br | 8 905 | 1 043 | Worker `reembolsonew` | ✅ | Worker `anotasemvolta` (com D1+R2) existe mas não está ligado ao domínio |
| olhodetandera.com | 7 089 | 4 651 | **nenhum** | 🔴 | Zona recebe tráfego, mas **não tem registro A/CNAME no apex nem no www**. Tunnel `olho-tandera` está down. Site fora do ar |
| pagabao.com.br | 6 635 | 27 | Origem 209.50.63.223 | ⚠️ | 27 pageviews em 30 dias |
| catovela.com.br | 5 558 | 719 | Worker `consorcio` | ✅ | |
| alcada.ia.br | 5 418 | 10 | Origem 209.50.63.223 | ⚠️ | 10 pageviews em 30 dias |
| kilo.ia.br | 5 392 | 415 | Tunnel `bonanca` (healthy) | ✅ | |
| ultravis.ai | 2 352 | 0 | `api` → Worker `ultravis-server`; apex → Vercel 76.76.21.21 | ✅ | `homolog/painel*` → 2.24.106.82 DNS-only |
| farolqueprotege.com.br | 479 | 116 | Origem 216.238.117.75 **DNS-only** | ⚠️ | Não passa pelo proxy: sem cache, sem WAF, IP exposto |
| tropa.ia.br | 11 | 0 | nenhum registro | ❌ | Zona vazia |
| dadoblindado.com.br | 4 | 0 | nenhum registro | ❌ | Worker `dadoblindado` existe mas só responde em `workers.dev` |
| reembolso.ia.br | 3 | 0 | só e-mail (smtp2go, Lovable) | ⚠️ | Sem site. Mantém só se o e-mail/Lovable ainda for usado; NS `notify.*` delegado a Lovable |
| iaparadonos.ia.br | 3 | 0 | nenhum registro | ❌ | Zona vazia (só MX nulo + SPF `-all`) |
| fazaconta.ia.br | 1 | 0 | nenhum registro | ❌ | 5 Workers `fazaconta*` existem mas nenhum está ligado ao domínio |
| radartributario.app | 0 | 0 | CNAME → tunnel **1bedd363… inexistente** | 🔴 | Zona ainda `pending` (NS não apontados). Certificado nunca emitido |
| meurecife.com.br | 0 | 0 | A DNS-only → IPs do ChatGPT custom domain | ❌ | Sem tráfego |
| decidaantes.com.br | 0 | 0 | nenhum registro | ❌ | Zona vazia |
| consultorsebraejampa.com.br | 0 | 0 | nenhum registro | ❌ | Zona vazia |

**Configuração de segurança igual em todas as 31 zonas (exceto onde indicado):** DNSSEC desligado · TLS mínimo 1.0 (tinhaprint: 1.2) · Always Use HTTPS desligado (ligado só em oreembolsobot, paraibao, tinhaprint) · HSTS desligado · SSL `full` em 20 zonas e `strict` em 11 · nenhuma regra WAF customizada · nenhuma Cache Rule · Bot Fight Mode desligado.

### E-mail (SPF/DKIM/DMARC)

| Situação | Zonas |
|---|---|
| DMARC `p=reject` ✅ | ajeita, alcada, anotasemvolta, catovela, consultorsebrae, consultorsebraejampa, decidaantes, farolqueprotege, fazaconta, iaparadonos, indice, isentapcd, kilo, meurecife, meusprompts, oreembolsobot, pagabao, paraibao, tinhaprint |
| DMARC `p=quarantine` ⚠️ | blinda.site, olhodetandera, ultravis.ai (todos com `rua=` apontando para GoDaddy/`onsecureserver.net`, provavelmente herdado) |
| DMARC `p=none` ⚠️ | comeca.ai, reembolsa.ia.br, reembolso.ia.br |
| **Sem DMARC** ❌ | isentataxi.com.br, virada.ia.br (ambos enviam por Resend/SES!), dadoblindado, radartributario, tropa, ultravis.dev |

Email Routing ativo em 10 zonas, todas encaminhando para `jhonata.emerick@gmail.com` (ou `meajuda@comeca.ai`).

---

## 3. Workers (56)

Invocações nos últimos 30 dias. "Trigger" = como o Worker é acionado (domínio custom, rota, cron, fila, ou só `workers.dev`).

### ✅ Em produção, com tráfego

| Worker | Inv/30d | Trigger | Recursos |
|---|---:|---|---|
| ultravis-landing | 21 150 | ultravis.dev, www | — |
| reembolsa-documentos-dev | 13 660 | cron */5 + filas | D1, R2, 3 queues, 2 workflows, DO |
| maquinaativos | 11 870 | tinhaprint.com.br + cron | D1 `maquina`, R2 `maquina-provas`, workflow, email. **410 erros** |
| gptchat-radar | 10 920 | indice.ia.br | D1 `radar-poc` (3,4 GB), R2 `cnpjs` (18 GB) |
| escola-classica | 10 540 | comunidade/classica.comeca.ai + cron */15 | D1 `escola`, R2 `slidesaulas`, Stream, AI |
| motornwork | 10 440 | workers.dev | D1 `motornwork-index`, R2 `motornwork-results` |
| reembolsonew | 8 010 | anotasemvolta.com.br | AI |
| ultravis-server | 6 490 | api.ultravis.ai + cron */10 e seg 06:30 | D1 `ultravis-espelho`, DO, Supabase |
| toritamotor | 5 470 | workers.dev | D1 `reembolsa-contas`, email |
| consorcio | 4 950 | catovela.com.br | D1 `consorcio-auth`, queue, browser rendering |
| escola-sensacionalista | 4 280 | pratica.comeca.ai + cron */30 | D1 `escola`, Stream |
| comeca-escola | 3 260 | modulos.comeca.ai + cron */15 | D1 `escola`, Stream |
| escola-futuro | 1 760 | cron */30 (sem domínio) | D1 `escola`, Stream |
| calculadora-combustivel | 340 | workers.dev (MCP) | DO |
| dadoblindado | 150 | workers.dev | assets |
| anonimizador-plugin | 120 | workers.dev | assets |
| anonimizador | 80 | workers.dev + Access | D1 `anonimizador-convites` |
| versiculo-audio | 80 | workers.dev | R2 `versiculo-do-dia-audios` |
| escudopay | 60 | workers.dev (MCP) | DO |
| pix-seguro | 50 | workers.dev (MCP) | DO |
| radar-dos-editais, radar-pb | 30 cada | cron seg-sáb 09:00 | KV `RADAR` |
| consorcio-auth-mailer | (consumer) | queue `consorcio-auth-messages` | D1, email |
| comeca-facaparte | (rota) | rotas `comunidade.comeca.ai/facaparte*`, `/afiliados*` | — |

### ⚠️ Ambientes não-produção ativos (consomem cota)

| Worker | Inv/30d | Problema |
|---|---:|---|
| planob-homologacao | 21 020 | **cron a cada minuto** (`* * * * *`) = ~43 k execuções/mês só de cron, em "homologação". 2º Worker mais invocado da conta |
| reembolsa-documentos-homolog | 5 960 | cron */5 + 4 filas + D1 + R2 + DO. Cópia de dev |
| reembolsa-documentos-poc | 3 620 | cron */5 + 4 filas + D1 + R2 + DO. 3ª cópia. **Não existe `reembolsa-documentos` de produção** |
| escola-classica-homolog | 3 080 | cron */15 + D1 `escola-homolog` (150 k leituras, 155 k escritas) + R2 `slidesaulas-homolog` |
| maquinaativos-teste | 330 | cron hora + D1 + R2 + workflow |
| reembolsa-jhon | 3 320 | ambiente pessoal com D1 + R2 próprios |
| flow-studio-homolog | 180 | D1 + workflow + email |
| flow-studio-mcp-homolog | 20 | — |
| comunidade-steve | 10 | cópia de `escola-classica` apontando para D1/R2 homolog |

### ❌ Sem uso (0–20 invocações em 30 dias e sem trigger relevante)

| Worker | Inv/30d | Criado | Observação |
|---|---:|---|---|
| anonimizador3 | 0 | 10/10 | Duplicata exata de `anonimizador` (mesmos bindings) |
| crawler | 0 | 01/08 (mod. 21/10) | Sem bindings, sem trigger. Deploy recente, zero execução |
| crawler1 | 0 | 01/08 | Idem |
| projetoparaibao | 0 | 01/08 (mod. 21/10) | Sem bindings. Site real roda no Tunnel |
| fazaconta | 0 | 12/09 | Roteador com service bindings para os 4 abaixo; zona `fazaconta.ia.br` nunca foi ligada |
| fazacont, fazaconta-contador, fazaconta-pf, fazaconta-pj | 0 | 12/09 | Só alcançáveis via `fazaconta` |
| sebracompliance | 0 | 10/09 | 2 apps Access apontam para ele. KV `ACERVO` vazio |
| sebraepocjhon | 0 | 10/09 | POC |
| reembolsa-documentos-desafiante | 0 | 08/10 | Sem bindings |
| reembolsa-politica-desafiante | 0 | 08/10 | Sem bindings |
| ultravis-claude-worker | 0 | 02/08 | Só assets |
| ultravis-d1-espelho | 0 | 07/09 | Mesmo D1 que `ultravis-server` já usa |
| clone-voice | 0 | 19/09 | AI + R2 `narracoes` + DO container. Caro se reativado |
| apartamento-recife-mcp | 0 | 23/10 | Novo (3 dias). Sem bindings. Aguardar |
| gptchat-cnpj | 10 | 02/10 | Sem bindings |
| indicie | 10 (10 erros) | 08/09 | 100 % erro. D1 `indicie-auth`, R2 `indicie-cnpj` (3 objetos) |
| anotasemvolta | 10 | 09/10 | Substituído por `reembolsonew` no domínio? Tem D1 + R2 `anotasemvolta-xml` (vazio) |
| versiculo-estudio | 10 | 10/10 | Access app com `domain=null` |
| comeca-atendimento | 20 | 28/09 | Integração Chatwoot + D1 `comeca-whatsapp` (2 leituras) |
| motornwork-gateway | 20 | 14/10 | Mesmo D1/R2 que `motornwork` |

---

## 4. D1 (20 bancos)

| Banco | Tamanho | Leituras/30d | Escritas/30d | Usado por | Status |
|---|---:|---:|---:|---|---|
| radar-poc | **3,4 GB** | 7 578 | **1 922 680** | gptchat-radar (indice.ia.br) | ✅ mas é "poc" em produção; ocupa 68 % do limite free de 5 GB |
| escola | 5,3 MB | 201 481 | 902 619 | escola-classica, comeca-escola, escola-futuro, escola-sensacionalista | ✅ |
| escola-homolog | 4,3 MB | 150 229 | 155 469 | escola-classica-homolog, comunidade-steve | ⚠️ homolog com mais carga que muita produção |
| planob-homologacao | 963 KB | 86 147 | 376 | planob-homologacao | ⚠️ leituras vêm do cron por minuto |
| reembolsa-documentos-dev | 238 KB | 77 445 | 4 013 | reembolsa-documentos-dev | ⚠️ dev |
| reembolsa-documentos-poc | 119 KB | 12 632 | 300 | reembolsa-documentos-poc | ⚠️ poc |
| reembolsa-jhon-db | 246 KB | 12 589 | 139 | reembolsa-jhon | ⚠️ pessoal |
| reembolsa-documentos-homolog | 70 KB | 12 477 | 12 | reembolsa-documentos-homolog | ⚠️ homolog |
| motornwork-index | 106 KB | 18 | 9 912 | motornwork, motornwork-gateway | ✅ |
| maquina | 221 KB | 2 216 | 408 | maquinaativos | ✅ |
| maquina-teste | 213 KB | 1 148 | 34 | maquinaativos-teste | ⚠️ teste |
| flow-studio-homolog | 123 KB | 211 | 69 | flow-studio-homolog | ⚠️ |
| reembolsa-contas | 57 KB | 14 | 72 | toritamotor | ✅ baixo uso |
| anotasemvolta | 127 KB | 11 | 23 | anotasemvolta | ❌ Worker quase sem uso |
| anonimizador-convites | 32 KB | 5 | 5 | anonimizador, anonimizador3 | ✅ baixo uso |
| ultravis-espelho | 651 KB | 4 | 0 | ultravis-server, ultravis-d1-espelho | ⚠️ 4 leituras apesar do cron */10 do ultravis-server |
| consorcio-auth | 86 KB | 2 | 9 | consorcio, consorcio-auth-mailer | ⚠️ quase sem uso |
| comeca-whatsapp | 49 KB | 2 | 6 | comeca-atendimento | ❌ |
| cnpj-chat-db | 82 KB | 1 | 11 | **nenhum Worker** | ❌ órfão |
| indicie-auth | 12 KB | 0 | 0 | indicie (100 % erro) | ❌ |

Há ainda 5 UUIDs de D1 já apagados que aparecem no analytics com leituras residuais; nada a fazer.

---

## 5. R2 (22 buckets)

| Bucket | Tamanho | Objetos | Ops/30d | Usado por | Status |
|---|---:|---:|---:|---|---|
| cnpjs | **17,8 GB** | 3 158 | 18 730 | gptchat-radar | ✅ 94 % do armazenamento R2 da conta |
| reembolsa-backups | 658 MB | 614 | 15 278 | **nenhum Worker** (backup externo via token `pagabao-backups-rw-2`?) | ✅ mas confirmar origem; sem lifecycle rule |
| slidesaulas | 387 MB | 113 | 3 204 | escola-* | ✅ |
| us_aulas | 155 MB | 4 | — | não aparece na listagem (jurisdição diferente?) | ⚠️ verificar no painel |
| reembolsa-documentos-dev | 89 MB | 2 036 | 5 930 | reembolsa-documentos-dev | ⚠️ dev |
| motornwork-results | 54 MB | 306 | 10 304 | motornwork | ✅ |
| narracoes | 11 MB | 29 | 1 | clone-voice (0 inv.) | ❌ |
| maquina-provas | 5 MB | 30 | 1 262 | maquinaativos | ✅ |
| reembolsa-jhon-documentos | 3 MB | 15 | 125 | reembolsa-jhon | ⚠️ |
| slides | 2 MB | 1 | 1 | **nenhum Worker** | ❌ |
| slidesaulas-homolog | 1 MB | 26 | 12 | escola-classica-homolog | ⚠️ |
| reembolsa-documentos-poc | 1 MB | 13 | 210 | reembolsa-documentos-poc | ⚠️ |
| indicie-cnpj | <1 MB | 3 | 13 | indicie | ❌ |
| versiculo-do-dia-audios | <1 MB | 1 | 49 | versiculo-* | ✅ |
| pagabao-backups | <1 MB | 45 | 27 | externo | ✅ |
| isentapcd-backups | <1 MB | 7 | 98 | externo | ✅ |
| anotasemvolta-xml | 0 | 0 | 9 | anotasemvolta | ❌ vazio |
| audiosfala | 0 | 0 | 1 | nenhum | ❌ vazio desde 10/2025 |
| aulas2 | 0 | 0 | 3 | nenhum (token Data Catalog nunca usado) | ❌ vazio |
| maquina-provas-teste | 0 | 0 | 7 | maquinaativos-teste | ❌ vazio |
| reembolsa-documentos-homolog | 0 | 0 | 3 | reembolsa-documentos-homolog | ❌ vazio |
| ultravis | 0 | 0 | 3 | nenhum (tokens Data Catalog/SQL Studio nunca usados) | ❌ vazio |
| whatsapp-audio-temp | 0 | 0 | 1 | nenhum | ❌ vazio desde 10/2025 |

---

## 6. KV (6 namespaces)

| Namespace | Chaves | Usado por | Status |
|---|---|---|---|
| RADAR | ≥1 | radar-dos-editais, radar-pb | ✅ |
| uv-bridge | 1 | **nenhum Worker** | ❌ órfão |
| ACERVO | 0 | sebracompliance (0 inv.) | ❌ vazio |
| cnpj-chat-cache | 0 | nenhum | ❌ vazio |
| whatsapp-transcriptions | 0 | nenhum | ❌ vazio |
| teste | 0 | nenhum | ❌ vazio |

---

## 7. Queues (13)

| Fila | Produtor → Consumidor | Status |
|---|---|---|
| consorcio-auth-messages | consorcio → consorcio-auth-mailer | ✅ |
| reembolsa-{despesas,combustivel,politicas}-dev + dlq-dev | reembolsa-documentos-dev | ⚠️ dev |
| reembolsa-{despesas,combustivel,politicas}-homolog + dlq-homolog | reembolsa-documentos-homolog | ⚠️ homolog |
| reembolsa-{despesas,combustivel,politicas}-poc + dlq-poc | reembolsa-documentos-poc | ⚠️ poc |

12 das 13 filas pertencem aos 3 ambientes não-prod de `reembolsa-documentos`.

---

## 8. Tunnels (10)

| Tunnel | Status | Hosts | Observação |
|---|---|---|---|
| paraibao-k2 | ✅ healthy (4 conns) | paraibao.com.br, www, painel, redacao | |
| reembolsa-kvm8 | ✅ healthy | 11 hosts oreembolsobot.app + painel.reembolsa.ia.br | |
| isenta-pcd | ✅ healthy | isentapcd.com.br, www, homolog, dev, pocinhos | |
| isentataxi-pb-k1 | ✅ healthy | pb.isentataxi.com.br | |
| bonanca | ✅ healthy | kilo.ia.br | |
| olho-tandera | 🔴 **down** | olhodetandera.com, www | Zona recebe 7 k req/mês e não tem DNS → site fora |
| jhonjampeiro | ❌ down desde 09/2026 | jhonjampeiro.comeca.ai | Host não existe no DNS |
| ollama-local | ❌ down | ollama.decisao.ai | Zona `decisao.ai` **não está nesta conta** |
| reembolsa-relatorios | ❌ down | auditoria/capacidade.reembolso.ia.br | Hosts não existem no DNS |
| ultravis-k4 | ❌ inactive | nenhum | Sem configuração, nunca conectou |

**CNAMEs para tunnels apagados:** `materiais.comeca.ai`, `tagarelo.comeca.ai` (→ b470108a…), `radartributario.app`, `www.radartributario.app` (→ 1bedd363…).

---

## 9. Access (Zero Trust) — 15 apps

| App | Host | Status |
|---|---|---|
| Reembolsa · Trilha (log) | log.oreembolsobot.app | ✅ |
| Atendimento reembolsa | atendimento.oreembolsobot.app | ✅ |
| Gestão reembolsa | gestao.oreembolsobot.app | ✅ |
| Central de Redação | redacao.paraibao.com.br | ✅ |
| Anonimizador | anonimizador.jhonata-emerick.workers.dev | ✅ |
| Warp Login App | (padrão Zero Trust) | ✅ |
| versiculo-estudio | **domain=null** | 🔴 app sem host |
| ondechega - Cloudflare Workers | **domain=null**; Worker não existe | ❌ |
| sebracompliance (×2) | sebracompliance.workers.dev | ❌ Worker com 0 invocações |
| ferias-na-disney - Pages | *.ferias-na-disney.pages.dev | ❌ projeto Pages não existe |
| landing-page-com-cad - Pages | *.landing-page-com-cad.pages.dev | ❌ projeto Pages não existe |
| n8n - Cloudflare Workers (×2) | workflows.falazap.ai, n8n.workers.dev | ❌ zona `falazap.ai` não está na conta; Worker não existe |
| Ollama API | ollama.decisao.ai | ❌ zona não está na conta; tunnel down |

Políticas: todas `allow` por e-mail individual (jhonata.emerick@gmail.com, jhonata.emerick@reembolsa.ia.br, fran@jhonataemerick.com.br). IdP: One-time PIN + membros Cloudflare. 6 políticas reutilizáveis.

---

## 10. Pages

| Projeto | Status |
|---|---|
| ultravis-claude | ❌ Último deploy 03/08/2026, **todos com falha**, só `pages.dev` |

---

## 11. AI Gateway

| Gateway | Status |
|---|---|
| default, alibaba, indicie | ⚠️ logs ligados, cache desligado (`cache_ttl=0`). `indicie` ligado a Worker com 100 % erro |

---

## 12. API Tokens (20) e acesso à conta

| Token | Último uso | Status |
|---|---|---|
| Cloudflare Resource Tagging System | hoje | ✅ sistema |
| morning-water-cfff | hoje | ✅ **este token de auditoria → revogar ao final** |
| old-pond-7376 | 15/10 | ✅ |
| nameless-wood-e7d7 | 03/10 | ✅ |
| late-sea-ff9d | 06/10 | ✅ |
| broken-resonance-e393 | 29/09 | ⚠️ |
| calm-moon-aace, cold-block-3eff, orange-fire-41b1, radar, pagabao-backups-rw-2 | set/2026 | ⚠️ sem uso há >30 dias |
| icy-art-47d6, icy-resonance-ccf2, jolly-violet-f36e | **nunca** | ❌ |
| [R2 Data Catalog] ×5 (aulas, aulas2, cnpjs, slidesau, ultravis), [R2 SQL Studio] ultravis | **nunca** | ❌ criados automaticamente pelo painel |

**Nenhum dos 20 tokens tem data de expiração.**

Conta: 2 membros (Super Admin + 1 Administrator). **2FA não é obrigatório** (`enforce_twofactor=false`). Nenhuma política de alerta configurada.

---

## Resumo

| Categoria | Total | ✅ Usado | ⚠️ Revisar | ❌ Não usado | 🔴 Quebrado |
|---|---:|---:|---:|---:|---:|
| Zonas | 31 | 15 | 7 | 7 | 2 (+1 parcial) |
| Workers | 56 | 25 | 9 | 22 | — |
| D1 | 20 | 7 | 9 | 4 | — |
| R2 | 22 | 9 | 4 | 9 (7 vazios) | — |
| KV | 6 | 1 | — | 5 | — |
| Queues | 13 | 1 | 12 | — | — |
| Tunnels | 10 | 5 | — | 4 | 1 |
| Access apps | 15 | 6 | — | 8 | 1 |
| Pages | 1 | — | — | 1 | — |
| Tokens | 20 | 5 | 6 | 9 | — |

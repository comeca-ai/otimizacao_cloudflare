# Plano de ação

## Visão por serviço (26/10/2026, após a limpeza)

| Serviço | Domínio | Estado | Próxima ação | Custo/cota a observar |
|---|---|---|---|---|
| **Paraibão** | paraibao.com.br | ✅ saudável (tunnel, Access, 213 k req) | Decidir destino de `crawler` e `projetoparaibao` (0 inv, redeployados 21/10) | — |
| **Reembolsa** | oreembolsobot.app, reembolsa.ia.br, anotasemvolta.com.br | ⚠️ 3 ambientes não-prod (dev/homolog/poc) ligados, 2 containers Paddle 4×6 GiB | Escolher 1 ambiente ativo; desligar cron e containers dos outros; lifecycle em `reembolsa-backups`; limpar DNS cPanel; apagar tunnel `reembolsa-relatorios` (bloqueado) | containers Paddle (memória provisionada), 12 filas, 6 workflows |
| **Comunidade / Escolas** | comeca.ai | ✅ produção ok; ⚠️ homolog com carga alta; 🔴 2 CNAMEs para tunnel apagado; 🗑️ `comunidade-steve` removido 26/10 | Apagar `materiais`/`tagarelo` ou recriar tunnel; desligar cron */15 em homolog; proxy nos A DNS-only; DMARC p=none → quarantine | D1 `escola` 1,1 M consultas/30 d; Stream 54 vídeos |
| **Ultravis** | ultravis.ai, ultravis.dev | ✅ ativo; ⚠️ container 4 GiB ligado 100 % do tempo | Confirmar se o container precisa ficar sempre ligado (sleep após inatividade?); apagar Pages `ultravis-claude` e tunnel `ultravis-k4` | **maior custo variável da conta**: ~10,6 M GiB-s/30 d + DO 24/7 |
| **Radar / Índice CNPJ** | indice.ia.br | ✅ ativo; ⚠️ D1 "poc" com 3,4 GB e 1,9 M escritas/mês | Plano para `radar-poc` (índice/particionamento/histórico em R2); decidir `indicie` (100 % erro), `gptchat-cnpj`, D1 `cnpj-chat-db` órfão | D1 68 % do free; R2 `cnpjs` 17,8 GB |
| **Máquina de Ativos** | tinhaprint.com.br | ✅ ativo, 410 erros/30 d | Investigar erros; decidir `maquinaativos-teste` | — |
| **Consórcio** | catovela.com.br | ✅ ativo | Nada urgente | — |
| **Isenta PCD / Táxi** | isentapcd.com.br, isentataxi.com.br | ✅ ativo | DMARC em isentataxi; remover TXT de teste | — |
| **Motor n Work** | workers.dev | ✅ ativo | Decidir `motornwork-gateway` (20 inv, criado 14/10) | — |
| **Kilo** | kilo.ia.br | ✅ ativo (tunnel bonanca) | Nada | — |
| **Sites em origem própria** | meusprompts, virada, consultorsebrae, farolqueprotege, blinda, ajeita, pagabao, alcada | ⚠️ cache ~2 %; 4 zonas quase sem pageviews; 🔴 olhodetandera sem DNS | Cache Rules + Tiered Cache; confirmar se blinda/ajeita/pagabao/alcada ainda existem na origem; resolver olhodetandera | origem recebe quase todo o tráfego |
| **Plano B (homolog)** | — | 🗑️ removido em 26/10 (Worker + D1, backup em R2) | — | — |
| **Flow Studio (homolog)** | — | 🗑️ removido em 26/10 (2 Workers + D1 + workflow, backup em R2) | — | — |
| **Ambientes não-prod** | vários | ⚠️ ver `03-ambientes-nao-prod.md` | Apagar Reembolsa homolog; desligar cron de escola-homolog e maquinaativos-teste | container 4×6 GiB ocioso; 2 M linhas D1/dia |
| **Faz a Conta** | fazaconta.ia.br | ❌ 5 Workers, 0 inv em 44 dias, zona nunca ligada | Publicar ou apagar | — |
| **Utilitários / MCPs** | workers.dev | ✅ baixo uso legítimo | Decidir `anonimizador3` (duplicata), `apartamento-recife-mcp` (novo) | — |
| **Sebrae / Compliance** | — | 🗑️ removido hoje | — | — |
| **Clone de voz** | — | 🗑️ removido hoje (Worker + container 12 GiB); R2 `narracoes` mantido | Apagar `narracoes` se não houver uso | — |
| **Zonas vazias** | 9 zonas | ❌ sem site | Decidir remover da conta (NS voltam ao registrador) | custo zero |
| **Conta** | — | ⚠️ 20 tokens sem expiração, 2FA opcional, 0 alertas, zonas no padrão de fábrica | Revogar 9 tokens (bloqueado nesta sessão), 2FA obrigatório, alertas, Fase 2 abaixo | primeira fatura sem créditos ~03/11 |

Ordem: primeiro o que está **quebrado** (afeta usuário agora), depois **segurança**, depois **limpeza**, depois **custo/eficiência**. Cada item tem o efeito esperado. Nada daqui foi executado ainda; a execução é registrada em [CHANGELOG.md](CHANGELOG.md).

Dependência: as ações marcadas **[escrita]** exigem um token com permissão de edição; o token da auditoria é somente leitura.

---

## Fase 0 — Decisões que só você pode tomar

Antes de qualquer remoção, confirmar:

1. **`reembolsa-documentos`**: dev, homolog e poc estão todos rodando cron a cada 5 min. Qual é o ambiente "de verdade"? Os outros dois podem ser pausados (remover cron) ou apagados?
2. **`planob-homologacao`**: cron a cada minuto é intencional? Pode cair para `*/5` ou `*/15`?
3. **`olhodetandera.com`**: o site deve voltar? Se sim, subir o `cloudflared` do tunnel `olho-tandera` e recriar os CNAMEs; se não, remover tunnel + zona.
4. **`comeca.ai` → `materiais` e `tagarelo`**: os serviços ainda existem em algum lugar? Senão, apagar os dois CNAMEs.
5. **`radartributario.app`**: projeto segue? A zona está `pending` há semanas e aponta para tunnel apagado.
6. **Zonas vazias** (tropa, iaparadonos, decidaantes, consultorsebraejampa, dadoblindado, fazaconta, meurecife): manter reservadas (custo zero, só poluição) ou remover da conta? Remover da conta **não** cancela o registro do domínio, só exige voltar os NS para o registrador.
7. **`blinda.site` / `ajeita.ia.br` / `pagabao.com.br` / `alcada.ia.br`**: têm requisições mas quase nenhum pageview. Os sites na origem 209.50.63.223 ainda existem?
8. **`fazaconta*`** (5 Workers, 0 invocações, zona nunca ligada): projeto morto ou vai ao ar?

---

## Fase 1 — Corrigir o que está quebrado 🔴

| # | Ação | Onde | Efeito |
|---|---|---|---|
| 1.1 | Decidir destino de `olhodetandera.com` (item 0.3) | Tunnel `olho-tandera` + DNS | 7 k req/mês hoje caem em NXDOMAIN |
| 1.2 | **[escrita]** Apagar CNAMEs `materiais.comeca.ai` e `tagarelo.comeca.ai` (tunnel b470108a… não existe) ou recriar o tunnel | DNS comeca.ai | Elimina 530 de resposta para quem acessa |
| 1.3 | **[escrita]** `radartributario.app`: apontar NS no registrador ou remover zona; apagar CNAMEs para tunnel 1bedd363… | Zona + DNS | Zona deixa de ficar `pending` |
| 1.4 | **[escrita]** Access app `versiculo-estudio` e `ondechega` têm `domain=null`: apagar ou corrigir o host | Zero Trust | Apps sem host não protegem nada |
| 1.5 | Investigar 410 erros em `maquinaativos` (3,5 % das invocações) e 100 % de erro em `indicie` | Workers logs | `maquinaativos` serve tinhaprint.com.br em produção |

---

## Fase 2 — Segurança (todas as zonas) 🔒

Hoje as 31 zonas estão no padrão de fábrica. Aplicar em lote, nas zonas ✅ e ⚠️ (as ❌ serão removidas):

| # | Ação | Valor atual → novo | Risco |
|---|---|---|---|
| 2.1 | **[escrita]** TLS mínimo | 1.0 → **1.2** | Nenhum para navegadores de 2016+. Já é assim em tinhaprint |
| 2.2 | **[escrita]** Always Use HTTPS | off → **on** (28 zonas) | Nenhum; redirect 301 http→https |
| 2.3 | **[escrita]** SSL mode | `full` → **`strict`** nas 20 zonas que ainda estão em `full` | Exige certificado válido na origem. Para zonas 100 % Worker/Tunnel (anotasemvolta, catovela, indice, tinhaprint, ultravis.dev, kilo, paraibao, oreembolsobot, isentapcd) é seguro imediatamente. Para origens próprias (209.50.63.223, 216.238.117.75) testar uma zona antes |
| 2.4 | **[escrita]** HSTS | off → on, `max-age=15552000` (6 meses), sem `includeSubDomains` e sem `preload` no início | Só depois de 2.2 e 2.3 estarem estáveis por alguns dias |
| 2.5 | **[escrita]** DNSSEC | off → on (gera registro DS para colocar no registrador) | Para `.br` o Registro.br aceita DS. Fazer zona a zona |
| 2.6 | **[escrita]** Bot Fight Mode | off → on nas zonas com site público (paraibao, oreembolsobot, isentapcd, isentataxi, meusprompts, virada, consultorsebrae, ultravis.dev) | Pode bloquear scrapers legítimos; monitorar 1 semana |
| 2.7 | **[escrita]** DMARC | criar `_dmarc` em **isentataxi.com.br** e **virada.ia.br** (`v=DMARC1; p=quarantine; rua=mailto:...`), ambas enviam por Resend/SES; subir `p=none` → `quarantine` em comeca.ai e reembolsa.ia.br após 2 semanas de relatório | Sem DMARC qualquer um envia e-mail "de" isentataxi/virada |
| 2.8 | **[escrita]** Trocar `rua=mailto:dmarc_rua@onsecureserver.net` (GoDaddy) por um e-mail seu em blinda.site, olhodetandera, ultravis.ai | Relatórios vão hoje para um terceiro |
| 2.9 | **[escrita]** Proxy (nuvem laranja) em `farolqueprotege.com.br` e `www` | DNS-only → proxied | Hoje sem WAF, sem cache, IP exposto |
| 2.10 | **[escrita]** Avaliar proxy nos registros A DNS-only de `comeca.ai` (apps, crm, membros, studio, fran, apex) e `reembolsa.ia.br` (apex) | IPs 179.198.x / 187.110.x parecem IP residencial/ISP; expostos publicamente no DNS | Se forem serviços web HTTP(S), ligar proxy. Se forem SSH/outros, deixar |
| 2.11 | Conta: **ativar 2FA obrigatório** (`enforce_twofactor`) | Painel → Manage Account → Members | 2 membros com privilégio total |
| 2.12 | **[escrita]** Tokens: revogar os 9 nunca usados + 5 sem uso há >30 dias (após confirmar `pagabao-backups-rw-2` e `radar`); definir **expiração** nos que ficarem | 20 → ~6 tokens | Reduz superfície |
| 2.13 | **Revogar o token desta auditoria** (`morning-water-cfff`) e as credenciais S3 do R2 coladas no chat | Profile → API Tokens; R2 → Manage API Tokens | Ambos estão no histórico da conversa |
| 2.14 | **[escrita]** Criar 1 política de alerta (Notifications): "Origin error rate", "SSL certificate expiring", "Tunnel health" | Hoje: 0 alertas | Você descobre tunnel down pelo cliente |

---

## Fase 3 — Limpeza (remover o que não é usado) 🧹

Tudo abaixo tem **0 uso em 30 dias** e **nada depende dele**. Exportar antes de apagar onde houver dado (D1 → `wrangler d1 export`, R2 → `rclone`/`wrangler r2`).

### 3.1 Workers (22)

`anonimizador3`, `crawler`, `crawler1`, `projetoparaibao`, `sebraepocjhon`, `reembolsa-documentos-desafiante`, `reembolsa-politica-desafiante`, `ultravis-claude-worker`, `ultravis-d1-espelho`, `clone-voice`, `gptchat-cnpj`, `indicie`, `motornwork-gateway`, `comeca-atendimento`, `versiculo-estudio`.

Condicionais à Fase 0: `fazaconta`, `fazacont`, `fazaconta-contador`, `fazaconta-pf`, `fazaconta-pj` (item 0.8); `sebracompliance` (apagar junto com os 2 Access apps); `anotasemvolta` (confirmar que `reembolsonew` substituiu); `apartamento-recife-mcp` (3 dias de vida, reavaliar em 30 dias).

### 3.2 D1 (4 + condicionais)

Órfãos/sem uso: `cnpj-chat-db` (nenhum Worker), `indicie-auth`, `comeca-whatsapp`, `anotasemvolta` (após 3.1).
Após Fase 0: `maquina-teste`, `reembolsa-documentos-{homolog,poc}` ou `-dev`, `flow-studio-homolog`, `reembolsa-jhon-db`.

### 3.3 R2 (7 vazios + 3 sem consumidor)

Vazios: `anotasemvolta-xml`, `audiosfala`, `aulas2`, `maquina-provas-teste`, `reembolsa-documentos-homolog`, `ultravis`, `whatsapp-audio-temp`.
Sem consumidor: `slides` (1 objeto, 2 MB), `narracoes` (clone-voice), `indicie-cnpj`.
Verificar no painel o bucket `us_aulas` (155 MB) que aparece no analytics mas não na listagem padrão.

### 3.4 KV (5)

`uv-bridge`, `ACERVO`, `cnpj-chat-cache`, `whatsapp-transcriptions`, `teste`.

### 3.5 Tunnels (4)

`jhonjampeiro`, `ollama-local`, `reembolsa-relatorios`, `ultravis-k4`. (+ `olho-tandera` conforme 0.3)

### 3.6 Access (8 apps)

`ondechega`, `sebracompliance` ×2, `ferias-na-disney`, `landing-page-com-cad`, `n8n` ×2, `Ollama API`. Depois, remover o IdP `n8n - Cloudflare Workers` se ficar sem uso (manter One-time PIN genérico).

### 3.7 Pages (1)

`ultravis-claude` (todos os deploys falharam, agosto).

### 3.8 DNS residual

- `reembolsa.ia.br`: 10 registros cPanel (`autoconfig`, `autodiscover`, `cpanel`, `cpcalendars`, `cpcontacts`, `mail`, `webdisk`, `webmail`, `whm` → 69.6.212.249; `ftp`), 4 SRV + 4 TXT caldav/carddav, `_cpanel-dcv-test-record`, `localhost → 127.0.0.1`. Confirmar que o cPanel foi desativado (MX já é Google).
- `isentapcd.com.br`: TXT `teste-tunnel-token`.
- `blinda.site`, `olhodetandera.com`, `ultravis.ai`: CNAME `_domainconnect` (GoDaddy) — inofensivo, pode ficar.
- `oreembolsobot.app`: `painel`, `webhooks`, `workflows` → `manager01.oreembolsobot.app`, mas **não existe registro `manager01`** → resolvem para nada.
- `ultravis.ai`: `_railway-verify.api` (api hoje é Worker) e `_acme-challenge` proxied.

### 3.9 Zonas (7, conforme item 0.6)

`tropa.ia.br`, `iaparadonos.ia.br`, `decidaantes.com.br`, `consultorsebraejampa.com.br`, `meurecife.com.br`, `dadoblindado.com.br`, `fazaconta.ia.br`. Opcional: `reembolso.ia.br` se o e-mail Lovable/smtp2go não for mais usado.

---

## O que impede voltar ao plano gratuito (medido em 26/10/2026, janela de 30 d)

Limites do Workers Free e dos produtos conforme documentação conhecida; os valores da conta são do GraphQL Analytics. Conferir os limites na tabela oficial antes de decidir.

| Dimensão | Conta hoje | Free | Veredito | Quem causa |
|---|---|---|---|---|
| **Containers** | 3 apps (ultravis 1×4 GiB 24/7; Paddle dev/homolog 4×6 GiB) | não existe no Free | 🔴 bloqueia sozinho | Ultravis, Reembolsa |
| **Queues** | 13 filas em uso | não existe no Free | 🔴 bloqueia sozinho | Reembolsa (12), Consórcio (1) |
| **D1 linhas lidas/dia** | 10,1 M | 5 M | 🔴 2× acima | `radar-poc` (6,5 M/dia), `escola` (1,5 M/dia), `escola-homolog` (2 M/dia) |
| **D1 linhas escritas/dia** | 1,59 M | 100 k | 🔴 16× acima | `radar-poc` (1,5 M/dia), `escola` (43 k/dia) |
| **CPU por invocação** | p99 de 297 ms (gptchat-radar), 293 ms (consorcio), 50–80 ms (escolas) | 10 ms | 🔴 vários Workers estourariam | Radar, Consórcio, Escolas, reembolsa-documentos-dev, maquinaativos |
| **R2 armazenamento** | 19,2 GB | 10 GB | ⚠️ cobra o excedente, mas R2 é separado do plano Workers (~US$ 0,14/mês) | `cnpjs` 17,8 GB |
| **Stream** | 54 vídeos (761 min), 385 min vistos | não tem Free | ⚠️ cobrado sempre | Escolas |
| Workers requests/dia | 5,2 k | 100 k | ✅ folga | — |
| D1 armazenamento | 3,2 GB | 5 GB | ✅ por enquanto | `radar-poc` cresce |
| Durable Objects (SQLite) | 11,4 k GB-s/dia | 13 k GB-s/dia | ✅ no limite | ultravis-server 24/7 |
| Workers AI | ~12 neurons/dia | 10 k/dia | ✅ | — |
| KV, Workflows, Browser Rendering, Email, Zero Trust | baixo | Free cobre | ✅ | — |

**Conclusão:** o Workers Paid (US$ 5/mês) é obrigatório enquanto existirem **Containers** ou **Queues**. Mesmo sem eles, D1 (leituras e escritas) e CPU dos Workers de Radar, Consórcio e Escolas estão acima do Free. Voltar ao gratuito exigiria: tirar Reembolsa e Ultravis de Containers/Queues, reduzir drasticamente as consultas do `radar-poc` (índice por CNPJ já identificado em 08/10) e cortar o CPU dos Workers pesados. R2 e Stream são cobrados à parte, em qualquer plano.

O que **não** está cobrando nada além do US$ 5: Workers requests, KV, Workflows, DO, Workers AI, Access, Tunnels, DNS e as 31 zonas.

## Fase 4 — Custo e eficiência 💰

Hoje a conta custa ~US$ 5 (Workers Paid) + Stream (~US$ 4 por 12,7 h armazenadas) + R2 (centavos). O risco não é a fatura atual, mas as **cotas**:

| # | Ação | Motivo |
|---|---|---|
| 4.1 | `planob-homologacao`: cron `* * * * *` → `*/5` ou `*/15` | ~43 k invocações/mês de cron em homologação |
| 4.2 | `reembolsa-documentos`: ficar com 1 ambiente não-prod ativo (desligar cron dos outros 2) | 3 × (cron */5 + 4 filas + D1 + R2 + DO) |
| 4.3 | `radar-poc` (D1, 3,4 GB, 1,9 M escritas/mês) | Limite D1 é 10 GB por banco no plano pago, mas o nome "poc" em produção com 68 % do free indica que vai estourar. Planejar particionamento ou mover dados históricos para R2 |
| 4.4 | `reembolsa-backups` (658 MB, 614 objetos, 15 k ops/mês): criar **lifecycle rule** (ex.: apagar >90 dias) | Cresce para sempre |
| 4.5 | `cnpjs` (17,8 GB): confirmar se os 3 158 snapshots precisam todos ficar; lifecycle ou Infrequent Access | 94 % do R2 |
| 4.6 | AI Gateway: ligar cache (`cache_ttl`) nos gateways `default` e `alibaba` se as chamadas forem repetitivas | Hoje `cache_ttl=0` |
| 4.7 | Cache Rules nas zonas com site estático (meusprompts, virada, consultorsebrae): hoje `cached=` ~2 % das requisições | Origem 216.238.117.75 recebe quase tudo |
| 4.8 | Ativar **Tiered Cache** (grátis) nas zonas com origem própria | Menos hits na origem |
| 4.9 | `escola-futuro`: cron */30 sem domínio custom — confirmar se deve seguir rodando | 1 760 inv/mês só de cron |

---

## Ordem sugerida de execução

1. Você responde a Fase 0 (8 perguntas).
2. Fase 1 (quebrados) e 2.13 (revogar credenciais da auditoria) — mesmo dia.
3. Fase 2 itens 2.1, 2.2, 2.7, 2.8, 2.9, 2.11, 2.12, 2.14 — baixo risco, 1 dia.
4. Fase 3 completa — exportar dados, apagar, registrar no CHANGELOG.
5. Fase 2 itens 2.3 → 2.4 → 2.5 → 2.6 — uma zona piloto, depois o resto.
6. Fase 4.

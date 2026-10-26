# Ambientes não-produção (homolog, poc, teste, dev)

Levantamento de 26/10/2026, janela de 30 dias, fonte: API + GraphQL Analytics. Estado atualizado em cada tabela.

## Por que isso importa

A conta está no **Workers Paid (US$ 5/mês)** e não volta ao gratuito só com limpeza (ver `02-plano-de-acao.md` → "O que impede voltar ao plano gratuito"). O que pesa na fatura não é o plano, é o **variável**: containers com memória provisionada, cron rodando em ambiente que ninguém usa, D1 sendo varrido por sincronizações de homologação. Reduzir ambiente não-prod ataca exatamente isso.

## Inventário dos ambientes não-prod

| Produto | Ambiente | Worker | O que tem junto | Uso real em 30 d | Estado |
|---|---|---|---|---|---|
| Plano B | homologação | `planob-homologacao` | D1 940 KB | 21 020 inv, **todas do cron a cada minuto** | 🗑️ **removido 26/10** (backup em R2) |
| Flow Studio | homolog | `flow-studio-homolog`, `flow-studio-mcp-homolog` | D1 120 KB (10 tabelas), workflow | 180 + 20 inv, 9 workflows | 🗑️ **removido 26/10** (backup em R2) |
| Comunidade | "Steve" | `comunidade-steve` | usava D1 `escola-homolog` e R2 `slidesaulas-homolog` | 10 inv | 🗑️ **removido 26/10** (backup em R2) |
| Reembolsa | homolog | `reembolsa-documentos-homolog` | **container Paddle 4 × 6 GiB / 12 GB disco**, DO, 4 filas, D1 68 KB, R2 vazio, 2 workflows | 5 960 inv = só o cron `*/5`; **0 workflows**; 12 escritas D1; container **sem uso medido** | ⏳ aguardando autorização para apagar |
| Reembolsa | poc | `reembolsa-documentos-poc` | DO, 4 filas, D1 119 KB, R2 1 MB, 2 workflows, cron `*/5` | 3 620 inv, 136 workflows | ⚠️ em uso, mas é a 3ª cópia |
| Reembolsa | dev | `reembolsa-documentos-dev` | container Paddle 4 × 6 GiB, DO, 4 filas, D1 238 KB, R2 89 MB, 2 workflows, cron `*/5` | 13 660 inv, 1 509 workflows | ✅ é o ambiente mais usado do produto |
| Reembolsa | pessoal | `reembolsa-jhon` | D1 246 KB, R2 3 MB | 3 320 inv | ⚠️ 4ª cópia |
| Escolas | homolog | `escola-classica-homolog` | D1 `escola-homolog` 4,2 MB, R2 `slidesaulas-homolog` 1 MB, cron `*/15` | 3 080 inv (2 880 são cron); **150 k leituras + 155 k escritas no D1**; CPU p50 27 ms, wall 3 s | ⏳ proposta: desligar o cron |
| Máquina de Ativos | teste | `maquinaativos-teste` | D1 213 KB, R2 vazio, workflow, cron `17 * * * *` | 330 inv (todas cron) | ⏳ proposta: desligar o cron |

Hosts DNS `homolog.oreembolsobot.app`, `homolog.isentapcd.com.br` e `homolog.ultravis.ai` **não** são Workers: são ambientes nos seus servidores (tunnel ou IP). Fora do escopo desta limpeza.

## Detalhe: Reembolsa homolog

Fato observado: criado em 04/10 por `wrangler deploy`, nunca atualizado. Vars `APP_EXPENSE_URL` e `APP_POLICY_URL` apontam para `https://homolog.oreembolsobot.app/...`. Imagem do container é a mesma do dev (`reembolsa-documentos-dev-paddlecontainer:fd50fd03`). Health: 4 instâncias `healthy`, 0 `active`. No analytics de containers dos 30 dias só aparecem **dev** e **ultravis**; homolog não registrou uso.

Leitura: uma cópia que nunca recebeu documento. O cron `*/5` acorda o Worker 288 vezes por dia para consultar um D1 vazio.

Proposta: apagar Worker (leva container e DO), 4 filas, D1, R2. Recriar quando precisar com `wrangler deploy --env homolog`.
Dependências: nenhuma; nenhum outro Worker referencia esses recursos.
Recuperação: backup de código + D1 em R2 antes de apagar.
Teste de aceitação: `wrangler deployments list` do dev continua igual; `homolog.oreembolsobot.app` continua respondendo (é tunnel).

## Detalhe: Escolas homolog

Fato observado: 96 execuções de cron por dia; cada rodada lê e escreve no D1 `escola-homolog` em volume próximo ao da produção (`escola`: 201 k leituras / 902 k escritas no mês, com 4 Workers em cron `*/15` e `*/30`). `DOMINIO` vazio: só acessível por `workers.dev`.

Hipótese (não verificada no código): o sync reprocessa o catálogo inteiro a cada rodada, por isso o número de escritas é constante mesmo sem conteúdo novo. Precisa de leitura do repositório `escola-*` para confirmar.

Proposta em dois passos:
1. **Desligar o cron de `escola-classica-homolog`** (reversível com redeploy). Elimina ~2 M linhas lidas/dia e ~5 k escritas/dia. O Worker fica para teste manual.
2. **Sync incremental na produção** (cursor/checkpoint + hash por item; um único Worker responsável pelo cron, os outros só leem). Reduz as 900 k escritas/mês do D1 `escola` e o CPU. Exige mudança de código e medição antes/depois.

## Padrão proposto para não-prod

1. **Sem cron fora de produção.** Ambiente não-prod acorda por chamada HTTP.
2. **Sem container provisionado fora de produção**, ou `max_instances: 1` com sleep. Conferir também se o Paddle de dev precisa de 4 instâncias para 13 k invocações/mês.
3. **Um ambiente não-prod por produto.** Reembolsa hoje tem dev, homolog, poc e jhon.
4. **Sufixo `-homolog`/`-poc`/`-teste` entra na revisão de 30 dias** com o mesmo critério usado hoje: 0 uso em 30 dias e nenhum dependente ativo → remove com backup.

## Ações pendentes de autorização (26/10/2026)

| # | Ação | Reversível? | Efeito |
|---|---|---|---|
| 1 | Apagar bloco Reembolsa homolog (Worker, container 4 × 6 GiB, DO, 4 filas, D1, R2, 2 workflows) | Recriável por deploy; dados em backup | −1 container, −4 filas, −1 D1 |
| 2 | Remover cron `*/15` de `escola-classica-homolog` | Sim (redeploy) | −2 M linhas D1/dia |
| 3 | Remover cron `17 * * * *` de `maquinaativos-teste` | Sim (redeploy) | −330 inv/mês |

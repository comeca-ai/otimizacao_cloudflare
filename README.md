# Otimização da conta Cloudflare

Auditoria e plano de limpeza da conta Cloudflare `749b2e9b…` (31 zonas, 56 Workers, 20 D1, 22 buckets R2, 13 Queues, 10 Tunnels, 15 apps Access).

Princípio: **manter só o que está funcionando**. Nada é removido sem registro aqui.

## Documentos

| Arquivo | Conteúdo |
|---|---|
| [docs/01-inventario.md](docs/01-inventario.md) | Tabela completa de tudo que existe na conta, classificado em **USADO / NÃO USADO / QUEBRADO**, com evidência (tráfego 30 dias, invocações, bindings, conexões) |
| [docs/02-plano-de-acao.md](docs/02-plano-de-acao.md) | O que remover, o que corrigir e o que endurecer, em ordem de prioridade, com o impacto de cada item |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Registro cronológico de cada ação executada na conta |
| [scripts/collect.sh](scripts/collect.sh) | Script somente leitura que gera o snapshot da conta via API (usado na auditoria) |

## Como foi feito

1. Snapshot somente leitura da conta via API REST (`scripts/collect.sh`) e GraphQL Analytics (últimos 30 dias: requisições HTTP por zona, invocações por Worker, consultas por D1, armazenamento e operações por bucket R2).
2. Cruzamento: cada recurso foi ligado a quem o usa (Worker ↔ D1/R2/KV/Queue/Durable Object, Zona ↔ Worker/Tunnel, Access ↔ host).
3. Classificação por evidência de uso real, não por nome.

Período analisado: **26/09/2026 → 26/10/2026**. Snapshot bruto (JSON) fica fora do repositório por conter IPs de origem, IDs internos e e-mails.

## Rodar de novo

```bash
export CF_TOKEN=<token somente leitura>
export CF_ACCOUNT=749b2e9b3642e4b03321d5830e81c195
OUT=/caminho/fora/do/repo bash scripts/collect.sh
```

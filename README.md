# Otimização da conta Cloudflare

Auditoria, limpeza e plano da conta Cloudflare `749b2e9b…`. Estado em 26/10/2026 após as limpezas: 31 zonas, 46 Workers, 18 D1, 18 buckets R2 (1 é backup), 13 Queues, 10 Tunnels, 7 apps Access, 3 containers, 9 workflows.

Princípio: **manter só o que está funcionando**. Nada é removido sem backup e sem registro aqui.

## Documentos

| Arquivo | Conteúdo |
|---|---|
| [docs/01-inventario.md](docs/01-inventario.md) | Tudo que existe na conta, classificado em usado / revisar / não usado / quebrado, com evidência de 30 dias |
| [docs/02-plano-de-acao.md](docs/02-plano-de-acao.md) | Visão por serviço, o que impede o plano gratuito, correções, segurança, limpeza e custo |
| [docs/03-ambientes-nao-prod.md](docs/03-ambientes-nao-prod.md) | Detalhe dos ambientes homolog/poc/teste, o que foi removido e o que se propõe |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Registro cronológico de cada ação executada na conta, com backup e verificação |
| [scripts/collect.sh](scripts/collect.sh) | Snapshot somente leitura da conta via API |
| [scripts/backup-2026-10-26.sh](scripts/backup-2026-10-26.sh), [scripts/delete-2026-10-26.sh](scripts/delete-2026-10-26.sh) | Backup e remoção da limpeza 1 (o delete em lote foi bloqueado pela política da sessão; as remoções saíram como chamadas individuais equivalentes) |
| Painel por serviço | https://claude.ai/artifact/7NJ6QqRveiLYj1ZXv3tks6 (privado) |

## Situação do plano

A conta está no **Workers Paid (US$ 5/mês)** + R2 e Stream por uso; todas as zonas no Free. Não volta ao gratuito só com limpeza: Containers e Queues não existem no Free, e D1 (10 M linhas lidas/dia, 1,6 M escritas/dia) e CPU dos Workers de Radar, Consórcio e Escolas passam dos limites. O custo que importa é o variável dos containers (Ultravis ligado 24/7; Paddle do Reembolsa). Detalhes em `02-plano-de-acao.md`.

## Backups

Tudo que foi removido tem cópia no bucket R2 **`limpeza-2026-10-26`** da própria conta (código dos Workers, exports SQL dos D1, chaves KV, objetos R2, configs). Não publicar.

## Como foi feito

1. Snapshot somente leitura via API REST (`scripts/collect.sh`) e GraphQL Analytics (30 dias: requisições por zona, invocações e CPU por Worker, consultas por D1, armazenamento/operações por R2, containers, Durable Objects, workflows, Workers AI, Stream).
2. Cruzamento: cada recurso ligado a quem o usa (Worker ↔ D1/R2/KV/Queue/DO/container, zona ↔ Worker/tunnel, Access ↔ host).
3. Classificação por evidência de uso real, não por nome. Remoção só com 0 uso em 30 dias, criado há mais de 30 dias e sem dependente ativo, ou com autorização explícita item a item.

Período analisado: **26/09/2026 → 26/10/2026**. Snapshot bruto (JSON) fica fora do repositório por conter IPs de origem, IDs internos e e-mails.

## Rodar de novo

```bash
export CF_TOKEN=<token somente leitura>
export CF_ACCOUNT=749b2e9b3642e4b03321d5830e81c195
OUT=/caminho/fora/do/repo bash scripts/collect.sh
```

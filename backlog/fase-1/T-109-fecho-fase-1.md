---
id: T-109
titulo: Fecho da Fase 1, versão 0.1.0
fase: 1
estado: pronto
tipo: infra
depende_de: [T-004, T-105, T-106, T-107, T-108]
---

## Objectivo
Existe um binário Linux do Insulano 0.1.0 em que o náufrago fala português gerado localmente, com
fallback provado, e a documentação descreve exactamente isso.

## Ler antes
- `AGENTS.md` §3 (fecho de fase), `agent_docs/prd.md` §6, `CHANGELOG.md`

## Critérios de aceitação
- [ ] `scripts/verify.sh --full` sem FALHOU nem INDETERMINADO
- [ ] Todos os critérios de sucesso da Fase 1 no PRD marcados com a prova ao lado
- [ ] Binário exportado corrido 5 minutos com Ollama ligado e 5 minutos com `INSULANO_LLM_URL=http://127.0.0.1:9`, sem crash; contagem de frases `llm` e `fallback` no Relatório
- [ ] `CHANGELOG.md` com `[0.1.0] - AAAA-MM-DD` e `README.md` com o estado actualizado
- [ ] `/insulano-docs-sync` corrido: nenhum comando documentado que não tenha sido executado nesta fase
- [ ] Tag git local `v0.1.0` (sem push)

## Fora de âmbito
- Publicar (T-505)

## Prova exigida
- `reports/verify-last.txt` copiado para `docs/proof/T-109-verify-full.txt`, screenshot do binário exportado

## Relatório
(preenchido pelo executor)

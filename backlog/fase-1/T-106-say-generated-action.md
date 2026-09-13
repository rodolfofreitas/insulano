---
id: T-106
titulo: SayGeneratedAction substitui as frases fixas em inglês da behavior tree
fase: 1
estado: pronto
tipo: visual
depende_de: [T-105, T-003]
---

## Objectivo
O personagem diz frases geradas (ou de fallback) em pt-PT, coerentes com o que está a fazer, e
nunca mais as frases fixas em inglês herdadas da base.

## Ler antes
- `agent_docs/tech_design.md` §4.6, `game/guy/guy.tscn` (nós `TalkAction`), `game/beehave/talk_action.gd`

## Critérios de aceitação
- [ ] `game/beehave/say_generated_action.gd` com o comportamento do tech design, incluindo `min_interval_s`
- [ ] As acções de pesca, comer, observar o oceano e passear escrevem `current_action` no blackboard
- [ ] Nenhum `TalkAction` com textos em inglês em `guy.tscn` (`grep -c "fishy" game/guy/guy.tscn` igual a 0)
- [ ] Teste GUT: com uma ponte falsa injectada, a acção devolve RUNNING até ao sinal e SUCCESS depois, e respeita o intervalo mínimo
- [ ] `boot_smoke.gd` alargado: com `INSULANO_LLM_URL=http://127.0.0.1:9`, em 90 s simulados o personagem diz pelo menos uma frase que existe em `phrases_fallback.json`
- [ ] `scripts/verify.sh --visual --llm` sem FALHOU
- [ ] Screenshot com o balão a mostrar uma frase em português, inspeccionado

## Fora de âmbito
- Aspecto visual do balão (T-107)

## Prova exigida
- `docs/proof/T-106-frase-gerada.png`

## Relatório
(preenchido pelo executor)

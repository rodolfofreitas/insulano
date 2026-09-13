---
id: T-103
titulo: PhraseFilter em GDScript com paridade total com o eval em Python
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O jogo rejeita as mesmas frases que o eval rejeita, pelas mesmas razões, lendo as mesmas regras.

## Ler antes
- `agent_docs/tech_design.md` §4.3, `game/data/phrase_rules.json` (campo `notes`),
  `game/tests/fixtures/phrase_filter_cases.json`, `scripts/llm_eval.py` (`clean_phrase`, `check_phrase`)
- `AGENTS.md` §10 (RegEx sem `\b` nem `\w`)

## Critérios de aceitação
- [ ] `game/llm/phrase_filter.gd` com a API do tech design, regras lidas de `phrase_rules.json`
- [ ] Teste GUT que percorre **todos** os casos da fixture e compara `clean` e `reason` (sem casos escritos à mão no teste)
- [ ] `uvx pytest scripts/tests` continua a passar (mesma fixture)
- [ ] Ordem de verificação igual à do Python: empty, english, ptbr, forbidden, too_short, too_long
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Acrescentar regras novas (T-108)

## Prova exigida
- `game/tests/unit/test_phrase_filter.gd` com N testes passados igual ao número de casos da fixture

## Relatório
(preenchido pelo executor)

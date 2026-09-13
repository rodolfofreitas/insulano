---
id: T-102
titulo: PhraseContext e PromptBuilder a partir do template partilhado
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O prompt enviado ao Ollama é montado a partir de `game/data/prompts/phrase_prompt.txt` e de um
contexto tipado, exactamente como o `scripts/llm_eval.py` o monta.

## Ler antes
- `agent_docs/tech_design.md` §4.2, `game/data/prompts/phrase_prompt.txt`, `scripts/llm_eval.py` (`render_prompt`)

## Critérios de aceitação
- [ ] `game/llm/phrase_context.gd` e `game/llm/prompt_builder.gd` com a API do tech design
- [ ] Teste GUT: com o contexto do caso `tarde-pescar` de `evals/phrase_cases.json`, o prompt gerado é igual, carácter a carácter, ao de `python3 -c` com `render_prompt` (texto esperado gravado em `game/tests/fixtures/prompt_tarde_pescar.txt` gerado pelo script Python)
- [ ] Teste GUT: contexto incompleto devolve `""` e regista erro (nunca prompt com `{campo}` por preencher)
- [ ] Teste GUT: `hunger_label_for` nas fronteiras 60, 25 e 0
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Alterar o texto do prompt (T-108)

## Prova exigida
- `game/tests/unit/test_prompt_builder.gd`, fixture gerada por Python

## Relatório
(preenchido pelo executor)

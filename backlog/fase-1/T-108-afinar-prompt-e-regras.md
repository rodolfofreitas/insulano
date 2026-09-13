---
id: T-108
titulo: Afinar prompt e regras até o eval passar sem próclise brasileira nem frases sem sentido
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-102, T-103]
---

## Objectivo
As frases do modelo configurado soam a um náufrago português com humor seco, medidas pelo eval e
revistas por um agente que não as escreveu.

## Ler antes
- `docs/proof/llm-eval-llama3.1_8b-2026-09-13.json` (linha de base: 95,8%, p50 2,82 s)
- `game/data/prompts/phrase_prompt.txt`, `game/data/phrase_rules.json`, `evals/phrase_cases.json`

## Critérios de aceitação
- [ ] Regra nova em `ptbr_patterns` para verbo modal + pronome + infinitivo (ex. observado: "pode me ajudar"), com casos novos na fixture partilhada (positivo e falso positivo: "o barco que me leve" é pt-PT válido)
- [ ] Prompt revisto para evitar objectos e animais impossíveis (ex. observado: "ovo de frango", "coelho"); texto final no Relatório
- [ ] `python3 scripts/llm_eval.py --proof --samples 5` com PASSOU e taxa de aceitação de pelo menos 0,9
- [ ] O agente `insulano-reviewer` (nunca quem escreveu o prompt) classifica 20 frases do relatório como coerente ou incoerente; pelo menos 16 coerentes; tabela no Relatório
- [ ] Testes pytest e GUT do filtro continuam em paridade (`scripts/verify.sh` sem FALHOU)

## Fora de âmbito
- Trocar de modelo ou fazer `ollama pull` (decisão do Rodolfo, ADR-006)

## Prova exigida
- Novo `docs/proof/llm-eval-*.json` e a tabela de revisão

## Relatório
(preenchido pelo executor)

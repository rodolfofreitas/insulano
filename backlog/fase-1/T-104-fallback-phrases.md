---
id: T-104
titulo: FallbackPhrases por categoria, sem repetição imediata
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
Sem Ollama, o personagem continua a dizer frases variadas e adequadas ao que está a fazer.

## Ler antes
- `agent_docs/tech_design.md` §4.4, `game/data/phrases_fallback.json`

## Critérios de aceitação
- [ ] `game/llm/fallback_phrases.gd` com a API do tech design
- [ ] `phrases_fallback.json` com as categorias `idle`, `fishing`, `eating`, `morning`, `night`, `rain`, `seagull`, `boat`, cada uma com pelo menos 4 frases em pt-PT
- [ ] Teste GUT: todas as frases de fallback passam o `phrase_rules.json` (reutilizar `PhraseFilter` se a T-103 já estiver feita; senão teste pytest equivalente em `scripts/tests/`)
- [ ] Teste GUT: 50 escolhas seguidas na mesma categoria nunca repetem a frase anterior
- [ ] Teste GUT: categoria inexistente devolve uma frase de `idle`
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Frases de feriados (vivem em `holidays.json`, T-402)

## Prova exigida
- `game/tests/unit/test_fallback_phrases.gd`

## Relatório
(preenchido pelo executor)

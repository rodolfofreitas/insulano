---
id: T-302
titulo: Gaivota atravessa o ecrã e o náufrago comenta
fase: 3
estado: pronto
tipo: visual
depende_de: [T-301, T-106]
---

## Objectivo
Quando o EventDirector lança o evento `seagull`, uma gaivota atravessa o céu e o náufrago diz uma frase sobre ela (gerada pelo LLM, com fallback).

## Ler antes
- game/events/event_director.gd e game/data/events.json (T-301)
- a acção de fala gerada da T-106 e o LLMBridge da T-105
- game/data/phrases_fallback.json
- docs/assets-licencas.md (regra de registo de assets)

## Critérios de aceitação
- [ ] Existe `game/events/seagull.gd` (e a cena correspondente) que reage a `Events.event_started("seagull", ...)` e desaparece ao sair do ecrã, emitindo `event_finished("seagull")` (prova: teste de integração GUT que emite o sinal e avança frames até ao fim).
- [ ] O visual da gaivota é desenhado em código, ou é um PNG pixel art criado nesta tarefa pelo agente e registado em `docs/assets-licencas.md` como CC0 do projecto (autor, data, ferramenta) (prova: diff do registo; nenhum asset de terceiros novo).
- [ ] O personagem reage com uma frase com contexto `action = "ver uma gaivota a passar"` pedida ao autoload `LLM`; com o Ollama desligado sai uma frase da categoria `seagull` de `phrases_fallback.json`, que passa a existir com pelo menos 4 frases pt-PT (prova: teste GUT com LLM apontado a porta fechada, por exemplo 127.0.0.1:9).
- [ ] As novas frases de fallback passam o PhraseFilter (prova: teste GUT que aplica o filtro a todas as frases de fallback).
- [ ] Screenshot `docs/proof/T-302-gaivota.png` com a gaivota visível a meio do ecrã (forçar o evento com um argumento ou setting de debug documentado), inspeccionado.
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Sons de gaivota (T-504 é humana).
- Várias gaivotas em bando.

## Prova exigida
- PNG em docs/proof/, testes GUT nomeados, entrada no registo de assets se houver PNG.

## Relatório
(preenchido pelo executor)

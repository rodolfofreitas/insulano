---
id: T-117
titulo: LLM cria arcos novos -- geracao de arcos originais com validacao e memoria
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-115, T-113]
---

## Objectivo

Quando TEDIO >= 65 e nenhum arco esta activo, o LLMDirector pede ao Ollama para inventar
um arco novo. O arco gerado e validado, entra no loop e fica no historico para nunca
ser repetido.

## Ler antes

- `docs/llm-director.md` §3 (Geracao de arco pela IA)
- `docs/narrative-design.md` §3 (Arcos gerados pela IA)

## Critérios de aceitação

- [ ] LLMDirector deteta condicao de geracao (TEDIO >= 65, sem arco activo)
- [ ] Prompt de geracao enviado com: titulos de arcos ja vividos, objectos na ilha, estado actual, estacao
- [ ] Resposta JSON validada: tem `titulo`, `tipo`, `fases` (array >= 2 entradas), `necessidade_que_sobe`
- [ ] Titulo nao repete nenhum arco em `arc_history.json` (verificacao por string normalizada)
- [ ] Frases das fases filtradas pelo `PhraseFilter` (sem conteudo proibido)
- [ ] Em caso de falha de validacao: SimpleDirector escolhe arco base aleatorio
- [ ] Arco gerado pela IA marcado como `"origem": "llm"` no ArcHistory
- [ ] Testes GUT: validacao de schema, deteccao de titulo repetido, fallback em falha

## Fora de âmbito

- 4a parede suave em arcos (v1.x)
- Padroes aprendidos pelo director (v1.x)

## Prova exigida

- `verify.sh --llm`: forcar condicao TEDIO=65, confirmar que arco novo e gerado e guardado
- Log com titulo do arco gerado e flag `origem: llm`

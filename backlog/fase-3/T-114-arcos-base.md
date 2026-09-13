---
id: T-114
titulo: Arcos base -- A Jangada, O Companheiro, A Sinalizacao (3 arcos com eventos mapeados)
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-113, T-301]
---

## Objectivo

Implementar 3 arcos narrativos completos com eventos reais, persistencia em ArcHistory
e integracao com o EventDirector. Cada arco tem 3-5 fases com actividades mapeadas do
catalogo de 210+ eventos.

## Ler antes

- `docs/events-catalogue.md` -- catalogo de eventos
- `docs/narrative-design.md` §2 -- arcos base
- `docs/llm-director.md` §2 -- actividades por arco
- `game/data/events.json` -- eventos avulsos (referencia de estrutura)

## Critérios de aceitação

- [ ] `game/data/arc_definitions.json` com os 3 arcos (id, tipo, fases, actividades por fase, condicoes de transicao)
- [ ] Arco "A Jangada": 5 fases, CICLICO, ESPERANCA +30 ao iniciar, -40 ao afundar
- [ ] Arco "O Companheiro": 4 fases, CICLICO, depende de SOLIDAO >= 70 para activar
- [ ] Arco "A Sinalizacao": 4 fases, CICLICO, ESPERANCA -20 quando barco passa sem parar
- [ ] SimpleDirector transita correctamente entre fases de cada arco
- [ ] Testes GUT: transicoes de fase, condicoes de activacao, reset ciclico

## Fora de âmbito

- Animacoes visuais dos arcos (entram como tarefas `visual` separadas)
- Arcos gerados pela IA (T-115)
- Mais de 3 arcos (restantes entram em V1.x)

## Prova exigida

- Smoke de 60s com arco visivel a progredir no log
- Screenshot de cada fase do arco "A Jangada"

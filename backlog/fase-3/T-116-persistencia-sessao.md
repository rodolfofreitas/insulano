---
id: T-116
titulo: Persistencia de sessao -- save.json e comportamento por tempo decorrido
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-113, T-115]
---

## Objectivo

Guardar o estado essencial entre sessoes em `user://save.json` e mudar o comportamento
do naufrago com base no tempo decorrido desde a ultima sessao.

## Ler antes

- `docs/narrative-design.md` §4 (Memoria entre sessoes, tabela de ausencias)

## Critérios de aceitação

- [ ] `user://save.json` com: `last_session_timestamp`, `days_survived`, `total_fish_caught`, `current_arc_id`, `phase_index`
- [ ] Escrita atomica (mesmo padrao de T-113)
- [ ] Ao arrancar: calcula `delta_t` desde ultima sessao e selecciona comportamento
- [ ] Menos de 1h: nada especial; 1-6h: naufrago noutro sitio; 6-24h: acorda do abrigo; 1-3 dias: fogueira apagada; 7+ dias: frase especial de regresso
- [ ] `days_survived` incrementa por dia real (24h de relogio do sistema)
- [ ] Testes GUT: calculo de delta_t, comportamentos por faixa de ausencia, escrita/leitura atomica

## Fora de âmbito

- `memory.json` (memoria emocional profunda -- v1.x)
- Fases de evolucao do naufrago (Fase I-V -- v1.x)
- Eventos lendarios unicos (v1.x)

## Prova exigida

- Teste GUT com `INSULANO_FAKE_TIME` simulando ausencia de 3 dias: confirmar comportamento correcto

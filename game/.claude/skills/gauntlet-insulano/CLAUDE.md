# Gauntlet Insulano -- Overlay Claude Code

Contexto partilhado: AGENTS.md. Stack: Godot 4 + GDScript.

## Verbos Claude Code

| Slot | Valor |
|---|---|
| LOOP_VERB | /loop |
| CLOSING_TAIL | e ultracode |

## Em /gauntlet-insulano

1. Ler AGENTS.md.
2. Identificar peca + dimensao + barra.
3. Escrever o prompt de gauntlet (~150 palavras).
4. Gravar em docs/gauntlet/PROMPT-YYYYMMDD.md.
5. Correr numa sessao fresca (nao aqui): o critico nao pode herdar o raciocinio do builder.

## Status obrigatorio

Manter docs/gauntlet/gauntlet-status.html durante a execucao:
- Peca | Ronda | Candidato | Referencia | Veredicto | Gap
- Ratchet: so substitui o best se o challenger ganhar pick cego
- Nunca apagar rondas anteriores -- historico visivel

## Nao fazer

- Correr composicao e execucao no mesmo contexto
- Inventar barras
- Usar score em vez de pick
- Parar apos N rondas sem o humano parar
- Julgar o proprio trabalho

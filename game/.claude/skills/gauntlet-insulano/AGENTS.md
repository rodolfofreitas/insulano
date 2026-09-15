# Gauntlet Insulano -- Contexto Partilhado

Dominio: screensaver Godot 4. Barra: Johnny Castaway (Sierra 1992).
Stack: GDScript 4 + Beehave + Ollama local.

## Axiomas (inviolaveis)

1. Barra Named + Fetchable + Comparable. Recusar adjectivos.
2. Builder e critico = contextos distintos. Nunca o mesmo processo.
3. Exit = humano para. Nunca round cap.
4. Pick binario A/B. Nunca score 0-100.
5. Critico ve artefacto real: screenshot do jogo a correr, frames, output visible.
   Nunca ve source code. Nunca ve o log de build.
6. Preflight: refs/ populado antes de comecar. Se nao abrir, abortar.

## Defaults Insulano

| Slot | Valor |
|---|---|
| THING | [peca especifica: sprite, animacao, comportamento, frase] |
| REFERENCE | **Visual:** Stardew Valley farmer sprite + Graveyard Keeper personagem. **Comportamento:** Johnny Castaway gameplay (variedade/timing). Ver docs/gauntlet/bars.md |
| TIER | nivel pixel art indie moderno -- expressivo, fluido, original (NAO imitar JC 1992) |
| CHECK | visualmente (screenshot lado-a-lado) ou comportamento (gameplay 30s lado-a-lado) |
| STACK | GDScript 4, Godot 4.7.2, Beehave, CPUParticles2D |

## Refs disponiveis

- docs/reference/johnny-castaway/*.png -- sprites locais (COPYRIGHT Activision, so referencia local)
- https://www.spriters-resource.com/pc_computer/johnnycastaway/ -- fetchable live
- YouTube: 'Johnny Castaway screensaver full' -- comportamento e timing
- docs/visual-identity.md -- plano de sprites do Insulano (1707 linhas)

## Pecas validas para gauntlet

- Sprite do naufrago (andar, pescar, dormir, reagir)
- Animacao da gaivota
- Comportamento do naufrago (variedade, timing, surpresa)
- Frases PT-PT (naturalidade, humor, melancolia)
- Screensaver feel geral (30s de gameplay vs 30s JC)

## Pecas invalidas (usar backlog/verify.sh em vez de gauntlet)

- Infraestrutura (builds, exports, hypridle)
- Testes GUT
- Backlog tasks com criterios binarios claros
- Qualquer coisa que nao tenha artefacto visual ou auditivo

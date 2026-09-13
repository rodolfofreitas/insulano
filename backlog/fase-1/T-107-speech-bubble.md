---
id: T-107
titulo: Balão de fala legível sobre água e relva, com duração proporcional
fase: 1
estado: pronto
tipo: visual
depende_de: [T-106]
---

## Objectivo
Qualquer frase até 15 palavras lê-se de relance, a 1080p e 1600p, sobre qualquer fundo da ilha.

## Ler antes
- `agent_docs/tech_design.md` §4.6, `game/character/character.gd` (`speech_bubble`, `talking_text`)

## Critérios de aceitação
- [ ] `game/ui/speech_bubble.gd` (`class_name SpeechBubble`) usado pelo personagem em vez do `Label` simples
- [ ] Fundo opaco com contraste de texto de pelo menos 4.5:1 (cores e cálculo no Relatório)
- [ ] Largura máxima com quebra de linha; frase de 15 palavras não sai do ecrã (screenshot)
- [ ] Teste GUT: `display_seconds_for(texto)` segue `clamp(2.5 + 0.35 * palavras, 3, 9)`
- [ ] O balão desaparece ao fim da duração (teste GUT com tempo simulado)
- [ ] Screenshots `--size=1920x1080` e `--size=2560x1600`, inspeccionados

## Fora de âmbito
- Animações do balão

## Prova exigida
- `docs/proof/T-107-balao-1080p.png`, `docs/proof/T-107-balao-1600p.png`

## Relatório
(preenchido pelo executor)

---
id: T-607
titulo: Sprites de animais visitantes
fase: 6
estado: pronto
tipo: visual
depende_de: [T-601, T-302]
---

## Objectivo

Gerar sprites para os 4 animais visitantes da ilha (gaivota, golfinho, tartaruga,
caranguejo) com dimensoes e paleta consistentes com o estilo existente, usando
SD1.5 com LoRA de pixel art via ComfyUI. A gaivota existente de T-302 serve como
referencia de tamanho e paleta.

## Ler antes

- `T-302` -- sprite e comportamento da gaivota existente, serve de referencia visual
- `T-601` -- servidor ComfyUI e modelos disponiveis
- `agent_docs/tech_design.md` -- contrato de criatura visitante
- `docs/events-catalogue.md` -- eventos que envolvem animais visitantes

## Critérios de aceitação

- [ ] `game/character/seagull.png` (ou o caminho definido em T-302) foi revisto ou substituido por versao consistente com o lote: `test -f game/character/seagull.png`
- [ ] `game/character/dolphin.png` existe e tem largura entre 16 e 48 pixeis: `python3 -c "from PIL import Image; img=Image.open('game/character/dolphin.png'); assert 16<=img.width<=48, img.size"`
- [ ] `game/character/turtle.png` existe e tem largura entre 16 e 32 pixeis: `python3 -c "from PIL import Image; img=Image.open('game/character/turtle.png'); assert 16<=img.width<=32, img.size"`
- [ ] `game/character/crab.png` existe e tem largura entre 8 e 24 pixeis: `python3 -c "from PIL import Image; img=Image.open('game/character/crab.png'); assert 8<=img.width<=24, img.size"`
- [ ] Workflow de geracao gravado em `docs/comfyui/animal_sprites_workflow.json`: `test -f docs/comfyui/animal_sprites_workflow.json`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Implementacao de IA de movimento ou comportamento dos animais (logica de jogo)
- Animacoes multi-frame (apenas frame estatico ou ciclo minimo de idle)
- Outros animais alem dos 4 listados nesta tarefa

## Prova exigida

Screenshot `docs/proof/T-607-animais-visitantes.png` com os 4 sprites visiveis
lado a lado, demonstrando consistencia de escala e paleta entre si e com o naufrago.

## Relatorio

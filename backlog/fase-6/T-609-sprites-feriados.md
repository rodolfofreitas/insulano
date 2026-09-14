---
id: T-609
titulo: Sprites de feriados
fase: 6
estado: pronto
tipo: visual
depende_de: [T-601, T-402]
---

## Objectivo

Gerar sprites de decoracoes sazonais para Natal e Ano Novo consistentes com o
estilo visual da ilha, usando SD1.5 com LoRA de pixel art via ComfyUI. Os
sprites devem ser compatentes com o sistema de eventos de T-402.

## Ler antes

- `T-402` -- sistema de eventos sazonais e feriados, paths de assets usados
- `T-601` -- servidor ComfyUI e modelos disponiveis
- `docs/events-catalogue.md` -- eventos de Natal e Ano Novo ja catalogados
- `game/data/events.json` -- eventos actuais, confirmar se ja referenciam assets de feriado

## Critérios de aceitação

- [ ] `game/object/holiday_xmas_tree.png` existe e tem dimensoes entre 16x24 e 32x48: `python3 -c "from PIL import Image; img=Image.open('game/object/holiday_xmas_tree.png'); assert 16<=img.width<=32 and 24<=img.height<=48, img.size"`
- [ ] `game/object/holiday_xmas_star.png` existe e tem dimensoes entre 8x8 e 16x16: `python3 -c "from PIL import Image; img=Image.open('game/object/holiday_xmas_star.png'); assert img.width<=16 and img.height<=16, img.size"`
- [ ] `game/object/holiday_newyear_firework.png` existe e tem dimensoes entre 16x16 e 32x32: `python3 -c "from PIL import Image; img=Image.open('game/object/holiday_newyear_firework.png'); assert 16<=img.width<=32 and 16<=img.height<=32, img.size"`
- [ ] `game/object/holiday_newyear_bottle.png` existe e tem dimensoes entre 8x16 e 16x32: `python3 -c "from PIL import Image; img=Image.open('game/object/holiday_newyear_bottle.png'); assert img.width<=16 and img.height<=32, img.size"`
- [ ] `game/data/events.json` referencia pelo menos um dos novos assets de feriado: `python3 -c "import json; d=open('game/data/events.json').read(); assert 'holiday_xmas' in d or 'holiday_newyear' in d, 'nenhum asset referenciado'"`
- [ ] Workflow de geracao gravado em `docs/comfyui/holiday_sprites_workflow.json`: `test -f docs/comfyui/holiday_sprites_workflow.json`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Logica de activacao de feriados por data (calendario) -- coberta por T-402
- Sprites de outros feriados alem de Natal e Ano Novo nesta fase
- Animacoes dos sprites de feriado

## Prova exigida

Screenshot `docs/proof/T-609-sprites-feriados.png` com todos os 4 sprites de
feriado visiveis lado a lado, demonstrando consistencia de paleta com o estilo da
ilha.

## Relatorio

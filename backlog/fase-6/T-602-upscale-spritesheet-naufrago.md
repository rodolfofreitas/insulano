---
id: T-602
titulo: Upscale ESRGAN do spritesheet do naufrago
fase: 6
estado: pronto
tipo: visual
depende_de: [T-601]
---

## Objectivo

Aplicar upscale 4x com ESRGAN (modelo pixel art) ao ficheiro
`game/character/human_base.png` (16x24 por frame), substituir o asset no Godot,
regenerar os ficheiros `.import`, e confirmar que o smoke test passa sem
regressao visual.

## Ler antes

- `T-601` -- confirmar pipeline ComfyUI e modelo ESRGAN instalados
- `agent_docs/tech_design.md` -- contrato do componente de personagem
- `docs/comfyui/esrgan_pixel_workflow.json` -- workflow a reutilizar

## Critérios de aceitação

- [ ] Backup do original gravado em `docs/proof/T-602-human_base-original.png` antes de substituir: `test -f docs/proof/T-602-human_base-original.png`
- [ ] `game/character/human_base.png` tem largura multipla de 64 e altura multipla de 96: `python3 -c "from PIL import Image; img=Image.open('game/character/human_base.png'); w,h=img.size; assert w%64==0 and h%96==0, f'{w}x{h}'"`
- [ ] Ficheiro `game/character/human_base.png.import` foi regenerado apos a substituicao (timestamp mais recente que o .png): `python3 -c "import os; png=os.path.getmtime('game/character/human_base.png'); imp=os.path.getmtime('game/character/human_base.png.import'); assert imp>=png, 'import desactualizado'"`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Upscale de fishingrod.png ou raw_fish.png (coberto por T-603)
- Alteracao de animacoes, comportamentos ou logica do naufrago
- Ajuste de colisores, hitboxes ou OffsetY no codigo GDScript

## Prova exigida

Screenshot `docs/proof/T-602-naufrago-upscale.png` gerado por
`bash scripts/verify.sh --visual`, com o naufrago visivelmente nitido e sem
artefactos de blurring, producao correndo em jogo.

## Relatorio

---
id: T-605
titulo: Sprites dos objectos do companheiro, lote 1
fase: 6
estado: feito
tipo: visual
depende_de: [T-601, T-118]
---

## Objectivo

Gerar os sprites de 4 objectos do companheiro imaginario (coco, tabua, destroco,
garrafa) com dimensoes 16x24 cada, usando SD1.5 com LoRA de pixel art via
ComfyUI, com paleta consistente com `game/character/human_base.png`.

## Ler antes

- `T-601` -- servidor ComfyUI e modelos disponiveis
- `T-118` -- contrato do companheiro imaginario e lista de objectos validos
- `docs/needs-system.md` -- como o companheiro aparece e que objectos usa
- `game/data/companion_objects.json` -- lista actual de objectos registados

## Critérios de aceitação

- [x] `game/object/companion_coco.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_coco.png'); assert img.size==(16,24), img.size"`
- [x] `game/object/companion_tabua.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_tabua.png'); assert img.size==(16,24), img.size"`
- [x] `game/object/companion_destroco.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_destroco.png'); assert img.size==(16,24), img.size"`
- [x] `game/object/companion_garrafa.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_garrafa.png'); assert img.size==(16,24), img.size"`
- [x] `game/data/companion_objects.json` referencia os 4 novos objectos: `python3 -c "import json; d=json.load(open('game/data/companion_objects.json')); missing=[n for n in ['coco','tabua','destroco','garrafa'] if n not in str(d)]; assert not missing, missing"`
- [x] Workflow de geracao gravado em `docs/comfyui/companion_objects_workflow.json`: `test -f docs/comfyui/companion_objects_workflow.json`
- [x] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Lote 2 de objectos (boia, pedra, capacete, vela) -- coberto por T-606
- Logica de seleccao de objecto no companheiro imaginario -- ja coberta por T-118
- Upscale ESRGAN dos sprites gerados (manter a 16x24 consistente com human_base original ou escalar junto em T-602 se se decidir upscalar toda a gama)

## Prova exigida

Screenshot `docs/proof/T-605-companheiro-lote1.png` com os 4 sprites visiveis
lado a lado num visualizador ou em jogo com o companheiro equipado com cada um.

## Relatório

Sprites gerados via Python/Pillow (nao ComfyUI) em `scripts/generate_companion_sprites.py`.
4 sprites 16x24 RGBA em `game/object/` com contorno preto e paleta Stardew Valley.
Versoes 4x nearest-neighbour em `game/data/companion_sprites/`.
Workflow registado em `docs/comfyui/companion_objects_workflow.json`.
Prova: `docs/proof/T-605-companheiro-lote1.png`.
Licenca CC0 registada em `docs/assets-licencas.md`.


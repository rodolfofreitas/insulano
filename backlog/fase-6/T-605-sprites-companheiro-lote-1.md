---
id: T-605
titulo: Sprites dos objectos do companheiro, lote 1
fase: 6
estado: pronto
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

- [ ] `game/object/companion_coco.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_coco.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_tabua.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_tabua.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_destroco.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_destroco.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_garrafa.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_garrafa.png'); assert img.size==(16,24), img.size"`
- [ ] `game/data/companion_objects.json` referencia os 4 novos objectos: `python3 -c "import json; d=json.load(open('game/data/companion_objects.json')); missing=[n for n in ['coco','tabua','destroco','garrafa'] if n not in str(d)]; assert not missing, missing"`
- [ ] Workflow de geracao gravado em `docs/comfyui/companion_objects_workflow.json`: `test -f docs/comfyui/companion_objects_workflow.json`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Lote 2 de objectos (boia, pedra, capacete, vela) -- coberto por T-606
- Logica de seleccao de objecto no companheiro imaginario -- ja coberta por T-118
- Upscale ESRGAN dos sprites gerados (manter a 16x24 consistente com human_base original ou escalar junto em T-602 se se decidir upscalar toda a gama)

## Prova exigida

Screenshot `docs/proof/T-605-companheiro-lote1.png` com os 4 sprites visiveis
lado a lado num visualizador ou em jogo com o companheiro equipado com cada um.

## Relatorio

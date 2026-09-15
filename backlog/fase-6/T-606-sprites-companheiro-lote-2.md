---
id: T-606
titulo: Sprites dos objectos do companheiro, lote 2
fase: 6
estado: feito
tipo: visual
depende_de: [T-605]
---

## Objectivo

Gerar os sprites de 4 objectos adicionais do companheiro imaginario (boia, pedra
com cara, capacete de borracha, vela) com dimensoes 16x24 cada, reutilizando o
workflow e a paleta estabelecidos em T-605.

## Ler antes

- `T-605` -- workflow ComfyUI, paleta e criterios de qualidade do lote 1
- `docs/needs-system.md` -- contexto do companheiro imaginario
- `game/data/companion_objects.json` -- lista de objectos ja registados
- `docs/proof/T-605-companheiro-lote1.png` -- referencia visual de paleta

## Critérios de aceitação

- [ ] `game/object/companion_boia.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_boia.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_pedra.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_pedra.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_capacete.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_capacete.png'); assert img.size==(16,24), img.size"`
- [ ] `game/object/companion_vela.png` existe e tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('game/object/companion_vela.png'); assert img.size==(16,24), img.size"`
- [ ] `game/data/companion_objects.json` referencia os 8 objectos totais (lote 1 mais lote 2): `python3 -c "import json; d=json.load(open('game/data/companion_objects.json')); objs=str(d); missing=[n for n in ['coco','tabua','destroco','garrafa','boia','pedra','capacete','vela'] if n not in objs]; assert not missing, missing"`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Lote 1 de objectos (coco, tabua, destroco, garrafa) -- coberto por T-605
- Criacao de mais de 8 objectos do companheiro nesta fase
- Animacoes de qualquer objecto do companheiro

## Prova exigida

Screenshot `docs/proof/T-606-companheiro-lote2.png` com os 4 sprites do lote 2
visiveis lado a lado, demonstrando consistencia de paleta com o lote 1.

## Relatório

Sprites gerados via Python/Pillow em `scripts/generate_companion_sprites_lote2.py`.
4 sprites 16x24 RGBA em `game/object/`: companion_boia.png, companion_capacete.png,
companion_pedra.png, companion_vela.png.
Versoes 4x nearest-neighbour geradas com `scripts/upscale_pixel_art.py`.
Prova: `docs/proof/T-606-companheiro-lote2.png` com os 4 sprites lado a lado.
companion_objects.json ja referenciava os 8 objectos (12 no total).

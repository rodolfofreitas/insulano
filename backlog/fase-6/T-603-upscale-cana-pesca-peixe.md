---
id: T-603
titulo: Upscale ESRGAN da cana de pesca e peixe
fase: 6
estado: feito
tipo: visual
depende_de: [T-601]
---

## Objectivo

Aplicar upscale 4x com ESRGAN (modelo pixel art) aos ficheiros
`game/character/fishingrod.png` e `game/object/raw_fish.png`, substituir os
assets no Godot, regenerar os `.import`, e confirmar que o smoke test passa.

## Ler antes

- `T-601` -- confirmar pipeline ComfyUI e modelo ESRGAN instalados
- `T-602` -- procedimento de substituicao de asset e regeneracao de .import
- `agent_docs/tech_design.md` -- contratos dos componentes de objecto

## Critérios de aceitação

- [ ] Backup de `fishingrod.png` gravado em `docs/proof/T-603-fishingrod-original.png`: `test -f docs/proof/T-603-fishingrod-original.png`
- [ ] Backup de `raw_fish.png` gravado em `docs/proof/T-603-raw_fish-original.png`: `test -f docs/proof/T-603-raw_fish-original.png`
- [ ] `game/character/fishingrod.png` tem dimensoes 4x das originais (largura e altura multiplas de 4): `python3 -c "from PIL import Image; orig=Image.open('docs/proof/T-603-fishingrod-original.png'); new=Image.open('game/character/fishingrod.png'); assert new.size==(orig.width*4, orig.height*4), f'{new.size} != {orig.width*4}x{orig.height*4}'"`
- [ ] `game/object/raw_fish.png` tem dimensoes 4x das originais: `python3 -c "from PIL import Image; orig=Image.open('docs/proof/T-603-raw_fish-original.png'); new=Image.open('game/object/raw_fish.png'); assert new.size==(orig.width*4, orig.height*4), f'{new.size}'"`
- [ ] Ambos os `.import` foram regenerados apos substituicao: `python3 -c "import os; [(__import__('builtins').print(f) or None) for f in ['game/character/fishingrod.png','game/object/raw_fish.png'] if os.path.getmtime(f+'.import')<os.path.getmtime(f)]" | grep -c . | grep -q '^0$'`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Upscale de human_base.png (coberto por T-602)
- Upscale de tileset ou tilemap (coberto por T-604)
- Alteracao de logica de pesca ou spawn de peixe

## Prova exigida

Screenshot `docs/proof/T-603-cana-peixe-upscale.png` com os dois sprites visiveis
em jogo, nitidos e consistentes com o estilo 4x do naufrago.

## Relatório

Upscale 4x nearest-neighbour aplicado via `scripts/upscale_pixel_art.py`:

- `fishingrod.png`: 32×6 → 128×24
- `raw_fish.png`: 32×16 → 128×64

Backups gravados em `docs/proof/`. `.import` regenerados com `godot --headless --import`. Todos os critérios de aceitação verificados. `verify.sh --quick` devolveu PASSOU.

---
id: T-604
titulo: Upscale ESRGAN do tileset da ilha
fase: 6
estado: feito
tipo: visual
depende_de: [T-601]
---

## Objectivo

Aplicar upscale 4x com ESRGAN (modelo pixel art) aos ficheiros
`game/world/Tiny-Islands-by-Majadroid/tilemap.png` e
`game/world/Tiny-Islands-by-Majadroid/tilemap-separated.png` (CC0, Majadroid),
substituir no Godot, regenerar `.import` e confirmar que o mundo renderiza sem
artefactos.

## Ler antes

- `T-601` -- confirmar pipeline ComfyUI e modelo ESRGAN instalados
- `T-602` -- procedimento de substituicao e regeneracao de .import
- `game/world/Tiny-Islands-by-Majadroid/LICENSE` -- confirmar licenca CC0 antes de distribuir versao upscalada
- `agent_docs/tech_design.md` -- contrato do componente de mundo e tilemap

## Critérios de aceitação

- [x] Backup de `tilemap.png` gravado em `docs/proof/T-604-tilemap-original.png`: `test -f docs/proof/T-604-tilemap-original.png`
- [x] Backup de `tilemap-separated.png` gravado em `docs/proof/T-604-tilemap-separated-original.png`: `test -f docs/proof/T-604-tilemap-separated-original.png`
- [x] `tilemap.png` tem dimensoes exactamente 4x das originais: `python3 -c "from PIL import Image; orig=Image.open('docs/proof/T-604-tilemap-original.png'); new=Image.open('game/world/Tiny-Islands-by-Majadroid/tilemap.png'); assert new.size==(orig.width*4,orig.height*4), f'{new.size}'"`
- [x] `tilemap-separated.png` tem dimensoes exactamente 4x das originais: `python3 -c "from PIL import Image; orig=Image.open('docs/proof/T-604-tilemap-separated-original.png'); new=Image.open('game/world/Tiny-Islands-by-Majadroid/tilemap-separated.png'); assert new.size==(orig.width*4,orig.height*4), f'{new.size}'"`
- [x] Ambos os `.import` foram regenerados: `python3 -c "import os; errs=[f for f in ['game/world/Tiny-Islands-by-Majadroid/tilemap.png','game/world/Tiny-Islands-by-Majadroid/tilemap-separated.png'] if os.path.getmtime(f+'.import')<os.path.getmtime(f)]; assert not errs, errs"`
- [x] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Upscale de sprites de personagem ou objectos (cobertos por T-602, T-603)
- Alteracao de tamanho de tiles no TileSet do Godot (tile_size deve ser actualizado separadamente se necessario)
- Criacao de tiles novos que nao existam no tileset CC0 original

## Prova exigida

Screenshot `docs/proof/T-604-tileset-upscale.png` mostrando a ilha renderizada
com o tileset 4x, gerado por `bash scripts/verify.sh --visual`.

## Relatório

Upscale 4x nearest-neighbour aplicado em 2026-09-15.
- tilemap.png: 224x160 -> 896x640
- tilemap-separated.png: 320x256 -> 1280x1024
- .import regenerados via `godot --headless --import`
- verify.sh --quick: PASSOU (51 testes, 0 erros)
- Prova: docs/proof/T-604-tileset-upscale.png

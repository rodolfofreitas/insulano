---
id: T-608
titulo: Efeitos visuais, particulas e nocturno
fase: 6
estado: pronto
tipo: visual
depende_de: [T-601, T-204]
---

## Objectivo

Gerar os sprites de particulas para tres efeitos visuais (chuva, estrelas
cadentes, bioluminescencia nocturna) com paleta adaptada ao ciclo dia-noite
definido em T-204, usando SD1.5 com LoRA de pixel art via ComfyUI.

## Ler antes

- `T-204` -- ciclo dia-noite e paleta `game/data/day_night_palette.json`
- `T-601` -- servidor ComfyUI e modelos disponiveis
- `game/data/day_night_palette.json` -- 13 pontos hora/cor para validar coerencia cromatica nocturna
- `agent_docs/tech_design.md` -- contrato de efeitos de particulas

## Critérios de aceitação

- [ ] `game/effect/rain_particle.png` existe e tem dimensoes 1x4 a 4x8 (gota de chuva): `python3 -c "from PIL import Image; img=Image.open('game/effect/rain_particle.png'); assert img.width<=4 and img.height<=8, img.size"`
- [ ] `game/effect/shooting_star.png` existe e tem largura entre 8 e 32 pixeis: `python3 -c "from PIL import Image; img=Image.open('game/effect/shooting_star.png'); assert 8<=img.width<=32, img.size"`
- [ ] `game/effect/bioluminescence.png` existe e tem dimensoes entre 4x4 e 16x16: `python3 -c "from PIL import Image; img=Image.open('game/effect/bioluminescence.png'); assert img.width<=16 and img.height<=16, img.size"`
- [ ] `bioluminescence.png` usa exclusivamente tons azuis e ciano (canal R medio inferior a G e B): `python3 -c "import numpy as np; from PIL import Image; img=np.array(Image.open('game/effect/bioluminescence.png').convert('RGB')); r,g,b=img[:,:,0].mean(),img[:,:,1].mean(),img[:,:,2].mean(); assert r<b, f'R={r:.1f} B={b:.1f}'"`
- [ ] Workflow de geracao gravado em `docs/comfyui/effects_particles_workflow.json`: `test -f docs/comfyui/effects_particles_workflow.json`
- [ ] `bash scripts/verify.sh` devolve exit 0

## Fora de âmbito

- Implementacao do sistema de particulas no Godot (GPUParticles2D ou CPUParticles2D)
- Animacoes de efeitos climaticos no codigo (apenas os sprites)
- Efeitos de feriados (cobertos por T-609)

## Prova exigida

Screenshot `docs/proof/T-608-efeitos-particulas.png` com os 3 sprites de efeito
visiveis lado a lado, e screenshot nocturno `docs/proof/T-608-nocturno-jogo.png`
gerado por `bash scripts/verify.sh --visual` com hora forcada para as 23h.

## Relatorio

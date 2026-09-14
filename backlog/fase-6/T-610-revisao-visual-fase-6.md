---
id: T-610
titulo: Revisao visual completa da Fase 6
fase: 6
estado: pronto
tipo: visual
depende_de: [T-602, T-603, T-604, T-605, T-606, T-607, T-608, T-609]
---

## Objectivo

Verificar a consistencia de paleta, estilo e escala de todos os sprites novos e
melhorados da Fase 6, produzir um screenshot panoramico da ilha com todos os
assets actualizados, e garantir que o portao verify.sh --full passa sem falhas.

## Ler antes

- `T-602` a `T-609` -- todos os assets e criterios de cada tarefa precedente
- `docs/proof/` -- todas as provas das tarefas anteriores desta fase
- `agent_docs/tech_design.md` -- contrato de componentes e paleta de referencia
- `game/character/human_base.png` -- referencia de paleta e escala 4x

## Critérios de aceitação

- [ ] `bash scripts/verify.sh --full` devolve exit 0
- [ ] Todos os assets da Fase 6 existem nos paths esperados: `python3 -c "import os; missing=[f for f in ['game/character/human_base.png','game/character/fishingrod.png','game/object/raw_fish.png','game/world/Tiny-Islands-by-Majadroid/tilemap.png','game/world/Tiny-Islands-by-Majadroid/tilemap-separated.png','game/object/companion_coco.png','game/object/companion_tabua.png','game/object/companion_destroco.png','game/object/companion_garrafa.png','game/object/companion_boia.png','game/object/companion_pedra.png','game/object/companion_capacete.png','game/object/companion_vela.png','game/character/seagull.png','game/character/dolphin.png','game/character/turtle.png','game/character/crab.png','game/effect/rain_particle.png','game/effect/shooting_star.png','game/effect/bioluminescence.png','game/object/holiday_xmas_tree.png','game/object/holiday_xmas_star.png','game/object/holiday_newyear_firework.png','game/object/holiday_newyear_bottle.png'] if not os.path.isfile(f)]; assert not missing, missing"`
- [ ] Nenhum asset de producao tem dimensoes originais (16x24 por frame) remanescentes para os assets alvo de upscale: `python3 -c "from PIL import Image; imgs={'game/character/human_base.png':(64,96),'game/character/fishingrod.png':None}; [print(f,Image.open(f).size) for f in ['game/character/human_base.png','game/character/fishingrod.png','game/object/raw_fish.png']]"`
- [ ] Screenshot panoramico `docs/proof/T-610-ilha-panoramica.png` existe e tem largura superior a 800 pixeis: `python3 -c "from PIL import Image; img=Image.open('docs/proof/T-610-ilha-panoramica.png'); assert img.width>800, img.size"`
- [ ] `python3 scripts/check_docs.py` devolve 0 falhas (sem travessoes nos ficheiros de backlog da Fase 6): `python3 scripts/check_docs.py 2>&1 | grep -c 'FAIL' | grep -q '^0$'`
- [ ] `python3 scripts/backlog.py check` devolve exit 0 com todas as tarefas da Fase 6 validadas

## Fora de âmbito

- Correcao de bugs de codigo descobertos durante a revisao visual (abrir tarefas novas)
- Actualizacao de tarefas de fases anteriores
- Preparacao de materiais de marketing (tagline, ficha itch.io)

## Prova exigida

Screenshot panoramico `docs/proof/T-610-ilha-panoramica.png` com a ilha completa
visivel, todos os novos assets presentes em cena, gerado por
`bash scripts/verify.sh --visual` com zoom out maximo.

Alem disso, o output completo de `bash scripts/verify.sh --full` gravado em
`docs/proof/T-610-verify-full.txt`: `bash scripts/verify.sh --full | tee docs/proof/T-610-verify-full.txt`.

## Relatorio

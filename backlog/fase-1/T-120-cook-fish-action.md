---
id: T-120
titulo: CookFishAction -- naufrago assa e come o peixe
fase: 1
estado: feito
tipo: codigo
depende_de: [T-119]
---

## Objectivo

Substituir o consumo imediato de peixe cru pelo ritual completo de 5 fases descrito em
`docs/features/fogueira-assar-peixe.md`:

1. Pesca -> `blackboard["has_fish"] = true` (modificacao em `fishing_action.gd`)
2. Recolhe lenha (`MakeCampfireAction` sub-fase GATHER_WOOD, ~3s)
3. Acende fogueira (`MakeCampfireAction` sub-fase LIGHT_FIRE, instancia `CampfireObject`)
4. Assa o peixe (`CookFishAction`, ~8s, SmokePuff CONTINUOUS)
5. Come com satisfacao (`need.replenish(Need.Type.HUNGER, 60)`)

O naufrago nunca mais come peixe cru. A `FishingAction` define `has_fish` e nao repoe fome.

Ver design completo em `docs/features/fogueira-assar-peixe.md` §3.3, §3.4, §3.5 e §3.6.

## Ler antes

- `docs/features/fogueira-assar-peixe.md` -- design completo da feature
- `game/character/fishing_action.gd` -- ficheiro a modificar
- `game/beehave/` -- padrao de BeehaveAction existente
- `agent_docs/tech_design.md` -- padrao do behaviour tree
- `T-119` -- CampfireObject deve estar implementado antes

## Critérios de aceitação

- [ ] `game/beehave/make_campfire_action.gd` com `class_name MakeCampfireAction`
  - Sub-fase GATHER_WOOD: animacao ~3s
  - Sub-fase LIGHT_FIRE: animacao ~2s, SmokePuff BURST, instancia CampfireObject
  - Retorna SUCCESS quando CampfireObject esta activo
- [ ] `game/beehave/cook_fish_action.gd` com `class_name CookFishAction`
  - Aguarda CampfireObject no grupo "campfire"
  - Toca animacao "cook" (~8s), SmokePuff CONTINUOUS durante cozedura
  - Chama `need.replenish(Need.Type.HUNGER, 60)` ao terminar
  - Define `blackboard["has_fish"] = false`
  - Retorna SUCCESS
- [ ] `fishing_action.gd` modificado: define `blackboard["has_fish"] = true`, NAO chama `need.replenish()` directamente
- [ ] Behaviour tree actualizado com o selector `cook_fish_ritual` (ver design §3.6)
- [ ] Testes GUT:
  - `test_cook_fish_reduces_hunger_60pts`: verificar que a fome baixa 60pts apos ritual completo
  - `test_raw_fish_never_eaten_directly`: verificar que `fishing_action` nunca chama `replenish()` directamente
- [ ] GDScript tipado em todos os ficheiros novos e modificados
- [ ] verify.sh PASSOU

## Fora de ambito

- Sons (e da T-121)
- Variante "comer cru por falta de lenha" (v1.x)
- Madeira como recurso escasso (v1.x)

## Prova exigida

- `docs/proof/T-120-assar-peixe.png` -- screenshot do naufrago a assar o peixe junto a fogueira
- Saida de `verify.sh` com gut: PASSOU e os dois novos testes visíveis
- verify.sh PASSOU (lint + gut + docs)

## Relatório

Implementado em 2026-09-15.

Ficheiros criados:
- `game/beehave/make_campfire_action.gd` -- MakeCampfireAction com fases GATHER_WOOD/LIGHT_FIRE
- `game/beehave/cook_fish_action.gd` -- CookFishAction, repoe hunger.increase_percent(60)
- `game/tests/integration/test_cook_fish.gd` -- 4 testes GUT (todos passam)
- `docs/proof/T-120-assar-peixe.png` -- screenshot FAKE_TIME=2026-09-15T20:00

Ficheiros modificados:
- `game/beehave/fishing_action.gd` -- define blackboard["has_fish"]=true ao apanhar peixe

verify.sh: PASSOU (238 testes, lint limpo, boot smoke PASSOU)

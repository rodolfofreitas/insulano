---
id: T-119
titulo: CampfireObject -- fogueira com particulas e luz
fase: 1
estado: feito
tipo: visual
depende_de: [T-113]
---

## Objectivo

Criar um `Node2D` reutilizavel `CampfireObject` com:
- `CPUParticles2D` para chamas (cores laranja e amarelo, baseado no padrao de `rain.gd`)
- `CPUParticles2D` para fumo (`SmokePuff`) com dois modos: BURST (ao acender) e CONTINUOUS (durante cozedura)
- `PointLight2D` activo apenas de noite (via `DayNightCycle.is_night` ou `Clock.hour_changed`)
- Sinais `lit()` e `extinguished()`
- Sem logica de peixe nem de fome -- este node e puramente visual e de estado da fogueira

Ver design completo em `docs/features/fogueira-assar-peixe.md` §3.1 e §3.2.

## Ler antes

- `docs/features/fogueira-assar-peixe.md` -- design completo da feature
- `game/world/rain.gd` -- padrao CPUParticles2D a seguir
- `docs/gauntlet/bars.md` §Dimensao Visual -- Fogueira -- barra de referencia visual

## Critérios de aceitação

- [ ] `game/object/campfire_object.gd` com `class_name CampfireObject`
- [ ] `game/object/campfire_object.tscn` com os nos descritos no design
- [ ] `game/object/smoke_puff.gd` com `class_name SmokePuff`, modos BURST e CONTINUOUS
- [ ] Sinal `lit()` emitido quando `start()` e chamado
- [ ] Sinal `extinguished()` emitido apos `burn_duration_s` segundos (default 60s)
- [ ] `PointLight2D` activo so quando `DayNightCycle.is_night == true`
- [ ] Luz pisca ligeiramente para simular crepitar (seno suave no energy, nao teleport)
- [ ] SmokePuff dispara BURST ao chamar `start()`
- [ ] O node e adicionado ao grupo `"campfire"` para acesso pelo behaviour tree
- [ ] Propriedades exportadas: `burn_duration_s`, `light_energy_night`, `smoke_on_light`
- [ ] GDScript tipado (sem `var` sem tipo onde o tipo e conhecido)
- [ ] verify.sh PASSOU

## Fora de ambito

- Logica de peixe ou de fome (e da T-120)
- Sons (e da T-121)
- Fogueira que apaga com chuva (v2)
- Multiplas fogueiras simultaneas

## Prova exigida

- `docs/proof/T-119-fogueira-noite.png` -- screenshot da fogueira activa de noite com luz visivel
- `docs/proof/T-119-fogueira-dia.png` -- screenshot da fogueira activa de dia sem luz (mas com chamas)
- SmokePuff visivel no screenshot nocturno ao acender
- verify.sh PASSOU (lint + gut + docs)

## Relatório

Implementado em 2026-09-15 pelo agente Hermes.
- `game/object/campfire_object.gd`: CampfireObject com CPUParticles2D (chamas + fumo) e PointLight2D nocturno.
- `game/tests/integration/test_campfire.gd`: 4 testes GUT (todos passaram).
- `game/test_scene.tscn`: CampfireObject instanciado na posicao (300, 340).
- `game/tools/capture_campfire.gd`: script auxiliar de captura com ignite() automatico.
- Provas visuais: docs/proof/T-119-fogueira-noite.png e T-119-fogueira-dia.png.
- verify.sh PASSOU (228/228 testes, lint limpo).

---
id: T-707
titulo: Oceano animado -- ondas com personalidade, reflexo de luz
fase: 7
estado: pronto
tipo: visual
depende_de: [T-610, T-304]
---

## Objectivo
Redesenhar o oceano com ondas animadas com personalidade: dithering azul/roxo, reflexo de luz solar que muda com a hora, ondas mais agitadas com vento/tempestade. Substituir o oceano actual plano ou simples.

## Ler antes
- docs/visual-identity.md (seccao 4 Oceano, dithering azul/roxo, horizonte distinto)
- docs/visual-identity.md (seccao 1.1 -- oceano com dithering do Johnny Castaway)
- game/world/weather_service.gd (vento, estado do tempo)
- game/world/game_clock.gd (hora para reflexo)

## Critérios de aceitação
- [ ] Shader ou TileSet de agua: dithering 2-3 tons de azul (`#1a6b9a`, `#2d8bc4`, `#4ab8e8`) + toque de roxo (`#8b5fbf`) nas sombras (prova: screenshot docs/proof/T-707-ocean.png com zoom x3)
- [ ] AnimationPlayer ou shader: `wave_cycle` loop de 4 frames; velocidade e amplitude variam com `WeatherService.wind_speed` (prova: GUT com wind_speed 0 vs 50)
- [ ] Reflexo de luz: strip horizontal brilhante que muda de posicao com a hora do dia (presente ao meio-dia, ausente de noite) (prova: screenshots docs/proof/T-707-reflexo-*.png)
- [ ] Ondas de tempestade: amplitude x3, cor mais escura (`#0d3d5c`) durante `WeatherService.state == "storm"` (prova: screenshot com storm activo)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Oceano 3D ou com fisica real
- Peixe visivel na agua (tarefa futura)
- Ondas de splash de natacao (CPUParticles2D -- T-124)

## Prova exigida
- Screenshots: oceano calmo, oceano com vento, oceano em tempestade
- Screenshot do reflexo ao meio-dia vs de noite

## Relatório
(preenchido pelo executor)

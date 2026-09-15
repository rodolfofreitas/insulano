---
id: T-708
titulo: Fundo pintado -- horizonte, nuvens, ceu por hora do dia
fase: 7
estado: pronto
tipo: visual
depende_de: [T-202, T-610]
---

## Objectivo
Criar fundo pintado (background nao-tilemap) com horizonte definido, nuvens animadas, e ceu que muda gradualmente com a hora do dia: nascer do sol (laranja), dia (azul), por do sol (roxo/rosa), noite (azul escuro com estrelas). Substitui o background plano actual.

## Ler antes
- docs/visual-identity.md (seccao 4 Fundo e Ceu, background pintado, iluminacao por hora)
- game/world/game_clock.gd (hora_normalized 0.0-1.0)
- game/world/sky_controller.gd (se existir) ou game/world/game_clock.gd

## Critérios de aceitação
- [ ] `game/assets/sprites/background_sky.png` com 4 variantes de ceu pintadas: amanhecer, dia, entardecer, noite; cada uma 640x360 ou resolucao do viewport (prova: ls game/assets/sprites/background_sky*.png)
- [ ] Shader ou AnimationPlayer interpola entre as 4 variantes com base em `game_clock.hour_normalized`; transicao continua sem pop (prova: GUT que avanca horas e tira screenshot a cada 3h)
- [ ] Nuvens: 3-5 sprites de nuvem `cloud_*.png` que se movem lentamente da esquerda para a direita; velocidade proporcional ao `WeatherService.wind_speed` (prova: GUT)
- [ ] Horizonte: linha distinta entre oceano e ceu; ilha tem relevo de areia que se sobrepos ao oceano (Z-index correcto) (prova: screenshot com layers visiveis)
- [ ] Estrelas de noite: 20-30 pixels brancos aleatorios no ceu nocturno, com twinkle de 2 frames (prova: screenshot docs/proof/T-708-noite.png)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Chuva (T-305 ja existente)
- Aurora boreal ou efeitos meteorologicos especiais (tarefa futura)
- Lua (tarefa futura -- T-204 so tem ceu nocturno basico)

## Prova exigida
- Screenshots das 4 fases do dia em docs/proof/T-708-*.png
- Screenshot de noite com estrelas

## Relatório
(preenchido pelo executor)

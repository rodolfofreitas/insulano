---
id: T-123
titulo: Tempo acelerado -- ciclo de 30 minutos ancorado na hora real
fase: 2
estado: pronto
tipo: codigo
depende_de: [T-201]
---

## Objectivo

O GameClock passa a correr 48x mais rapido (24h em 30 minutos reais),
mas ancora o ponto de partida na hora real do sistema.

Se o utilizador abre o screensaver as 14h00 reais, o jogo comeca a "hora de
jogo 14h00", mas o ciclo completo de dia dura 30 minutos.
As 14h30 reais, completa um dia e recomeça.

Este comportamento aplica-se apenas em modo screensaver (-- --screensaver).
Em modo janela (-- --windowed), o clock mantem a hora real sem multiplicador.

## Como funciona

```
GAME_DAY_DURATION_S = 1800.0  # 30 minutos em segundos reais
REAL_DAY_DURATION_S = 86400.0  # 24 horas em segundos

# No arranque:
real_fraction = (hora_real_em_segundos) / REAL_DAY_DURATION_S
# ex: 14h = 50400s / 86400s = 0.583
start_game_seconds = real_fraction * GAME_DAY_DURATION_S
# ex: 0.583 * 1800 = 1050s = 17.5 minutos no ciclo de jogo = hora de jogo 14h00

# Em _process(delta):
_game_elapsed += delta
_game_time_s = (start_game_seconds + _game_elapsed) % GAME_DAY_DURATION_S
game_hour_float = (_game_time_s / GAME_DAY_DURATION_S) * 24.0
# ex: depois de 15min reais -> game_hour_float = ~21h00
```

## Critérios de aceitação

- [ ] Em modo screensaver, 30 minutos reais = 1 ciclo completo de 24h de jogo
- [ ] O ponto de partida e ancorado na hora real (abrir as 14h -> comecar as ~14h de jogo)
- [ ] Em modo janela, comportamento anterior mantido (hora real directa)
- [ ] INSULANO_FAKE_TIME continua a funcionar para testes
- [ ] Teste GUT: test_screensaver_cycle_30min -- simular 1800s de delta, confirmar que game_hour voltou ao ponto de partida
- [ ] Teste GUT: test_anchor_14h -- com hora real 14h, game_hour_float inicial ~14.0
- [ ] verify.sh PASSOU

## Ler antes

- game/world/game_clock.gd (T-201)
- game/app/screensaver_mode.gd (T-501) -- Screensaver.mode()

## Fora de âmbito

- Modo janela com multiplicador configuravel (V3)
- Persistencia do ciclo entre sessoes (cada sessao ancora de novo na hora real)

## Prova exigida

- Output do teste GUT com os dois testes a passar
- Screenshot docs/proof/T-123-ciclo-noite.png: abrir com INSULANO_FAKE_TIME=2026-09-15T22:00, 5min depois deve estar de madrugada

## Relatorio

(preenchido pelo executor)

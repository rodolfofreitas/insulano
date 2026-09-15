---
id: T-803
titulo: Necessidade CALOR/FRIO -- sombra, fogueira, nadar para refrescar
fase: 8
estado: pronto
tipo: codigo
depende_de: [T-110, T-201, T-304]
---

## Objectivo
Implementar duas necessidades termicas: CALOR (range 0-100, sobe ao meio-dia em verao) e FRIO (range 0-100, sobe de noite e no inverno). Acoes de resposta: ir para a sombra, acender fogueira, nadar. O naufrago nunca morre -- a crise e expressiva e comica.

## Ler antes
- docs/needs-system.md
- docs/actions-catalogue.md (A09 acender fogueira, C15 sentir calor, C14 sentir frio, D02 nadar)
- game/world/game_clock.gd (hora do dia, estacao)
- game/world/weather_service.gd (temperatura ambiente)

## Critérios de aceitação
- [ ] `game/core/needs/heat_need.gd` e `game/core/needs/cold_need.gd` criados; ambos extendem INeed (prova: grep)
- [ ] CALOR sobe +0.8/s quando hora >= 11 e hora <= 15 em verao; desce -0.5/s na sombra ou na agua (prova: GUT com GameClock mockado)
- [ ] FRIO sobe +0.6/s quando hora <= 6 ou hora >= 21, ou no inverno; desce -0.8/s perto de fogueira activa (prova: GUT com fogueira mock)
- [ ] Accao "ir para sombra" (idle sob palmeira): CALOR -= 0.5/s enquanto na area de sombra; area definida por Area2D junto a palmeiras (prova: GUT com area2D simulada)
- [ ] Accao "nadar para refrescar": CALOR -= 40 instantaneo ao entrar na agua; requer CALOR >= 50 (prova: GUT)
- [ ] Crise CALOR (>= 90): emote sol gigante, frases de desespero termico, naufrago procura agua ou sombra urgentemente (prova: GUT)
- [ ] Crise FRIO (>= 90): naufrago treme, frases de frio, procura fogueira urgentemente (prova: GUT)
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG actualizado

## Fora de âmbito
- Shader visual de calor/frio no sprite (Fase 7, T-701)
- Sprites para animacoes de reaccao (T-803 e animacoes separadas)
- Estacao como sistema completo (T-202 ja existente)

## Prova exigida
- GUT tests para HeatNeed e ColdNeed com horas simuladas
- Log de crise termica sem morte

## Relatório
(preenchido pelo executor)

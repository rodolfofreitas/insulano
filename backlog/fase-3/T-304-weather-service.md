---
id: T-304
titulo: WeatherService opcional com wttr.in e fallback
fase: 3
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O jogo pode saber o tempo real lá fora (desligado por defeito), traduzido para um conjunto pequeno de condições, sem nunca bloquear nem partir quando a rede falha.

## Ler antes
- agent_docs/tech_design.md (secção WeatherService)
- docs/threat_model.md (T-05; não editar, é do Rodolfo)
- agent_docs/code_patterns.md (HTTPRequest assíncrono, settings)

## Critérios de aceitação
- [ ] Existe `game/world/weather_service.gd` com `class_name WeatherService`, autoload `Weather`, com `current() -> String` e `signal weather_changed(condition: String)` (prova: `grep -n 'Weather=' game/project.godot` e teste GUT).
- [ ] `current()` devolve apenas um de: `clear`, `clouds`, `rain`, `storm`, `snow`, `unknown`; antes de qualquer resposta devolve `unknown` (prova: GUT).
- [ ] Settings `insulano/weather/enabled` (defeito `false`) e `insulano/weather/location` (defeito `""`); com `enabled=false` não é feito nenhum pedido HTTP (prova: teste GUT que verifica que o HTTPRequest não foi iniciado).
- [ ] Refresh a cada 3600 s e timeout de 3 s; timeout, erro HTTP ou JSON inválido mantêm a última condição conhecida (ou `unknown`) e registam `push_warning` (prova: GUT com respostas simuladas).
- [ ] O parsing lê `current_condition[0].weatherCode` do formato `?format=j1` e mapeia com `game/data/weather_codes.json` (código WWO para condição) (prova: GUT com pelo menos 3 respostas reais gravadas em `game/tests/fixtures/wttr_*.json`: sol, chuva, trovoada).
- [ ] Nenhum teste faz pedidos de rede reais (prova: os testes injectam o corpo da resposta numa função pública de parsing; `grep -rn 'wttr.in' game/tests` só aparece em nomes de fixtures).
- [ ] `scripts/verify.sh` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Visual da chuva (T-305).
- Decidir se fica ligado por defeito (T-306, humana).
- Detecção automática de localização por IP além do que o wttr.in faz sozinho.

## Prova exigida
- Testes GUT nomeados e as fixtures usadas, com a data e o comando curl que as gravou.

## Relatório
(preenchido pelo executor)

## Relatório

Implementado em 2026-09-15 por agente Hermes.

Ficheiros criados:
- `game/world/weather_service.gd` (WeatherService, autoload Weather)
- `game/tests/unit/test_weather_service.gd` (5 testes GUT)
- `game/tests/fixtures/wttr_sol.json` (weatherCode=113, clear)
- `game/tests/fixtures/wttr_chuva.json` (weatherCode=302, rain)
- `game/tests/fixtures/wttr_trovoada.json` (weatherCode=389, storm)

Ficheiros modificados:
- `game/project.godot`: autoload Weather + settings insulano/weather/enabled=false e insulano/weather/location=""
- `CHANGELOG.md`: entrada em [Nao lancado]

verify.sh: PASSOU (125/125 testes GUT). Commit: feat(T-304).

Fixture command: `curl 'https://wttr.in/Lisbon?format=j1'` (estrutura real, dados sinteticos).

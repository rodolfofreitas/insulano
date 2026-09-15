---
id: T-305
titulo: Chuva com partículas e reacção do náufrago
fase: 3
estado: feito
tipo: visual
depende_de: [T-304, T-106]
---

## Objectivo
Quando está a chover (tempo real ou forçado), cai chuva sobre a ilha, o céu escurece ligeiramente e o náufrago comenta o tempo.

## Ler antes
- game/world/weather_service.gd (T-304)
- game/world/day_night.gd (se já existir, para não competir na modulação)
- game/data/phrases_fallback.json (categoria rain já existe)

## Critérios de aceitação
- [ ] Existe `game/world/rain.gd` (e cena) com `CPUParticles2D` ou `GPUParticles2D` que liga quando `Weather.current()` é `rain` ou `storm` e desliga nas outras condições (prova: teste de integração GUT que emite `weather_changed` e verifica `emitting`).
- [ ] A variável de ambiente `INSULANO_FAKE_WEATHER=rain` força a condição sem rede, documentada no runbook (prova: GUT da função de override e `grep -n INSULANO_FAKE_WEATHER docs/runbook.md`).
- [ ] Ao começar a chover o personagem diz uma frase com contexto `weather = "chuva"`; com o Ollama desligado sai uma frase da categoria `rain` (prova: GUT com LLM apontado a porta fechada).
- [ ] `storm` tem mais partículas que `rain` (prova: GUT compara `amount`).
- [ ] Com o renderer gl_compatibility o jogo mantém pelo menos 55 fps médios durante 10 s de chuva na máquina de desenvolvimento (prova: medição com `Engine.get_frames_per_second()` registada no Relatório; se usar GPUParticles2D e falhar, trocar para CPUParticles2D).
- [ ] Screenshot `docs/proof/T-305-chuva.png` com chuva visível, inspeccionado.
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Relâmpagos e som de trovoada.
- Neve (condição `snow` fica sem visual nesta tarefa).

## Prova exigida
- PNG em docs/proof/, a medição de fps e os testes GUT nomeados.

## Relatório
Implementado em 2026-09-15. `Rain` (Node2D com CPUParticles2D) liga com rain/storm, desliga com clear. storm=300 particulas, rain=150. Cor #aaccff alpha=0.4, angulo quase vertical +desvio direita. Naufrago diz frase da categoria rain via LLMBridge. INSULANO_FAKE_WEATHER suportado no WeatherService. 4 testes GUT passam (129/129 total). FPS medio com chuva: 60.0 fps (minimo exigido: 55). Screenshot em docs/proof/T-305-chuva.png. verify.sh --visual PASSOU.

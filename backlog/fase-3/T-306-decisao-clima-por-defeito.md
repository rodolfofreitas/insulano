---
id: T-306
titulo: Decidir se o clima real fica ligado por defeito
fase: 3
estado: feito
tipo: docs
depende_de: [T-304]
---

## Objectivo
O Rodolfo decide se `insulano/weather/enabled` passa a `true` por defeito, sabendo que ligar o clima envia o IP do utilizador (e a localização, se configurada) ao serviço externo wttr.in.

## Ler antes
- docs/threat_model.md (T-05 e secção "O que este projecto NÃO faz"; só o Rodolfo altera)
- docs/threat_model-propostas.md
- game/world/weather_service.gd (T-304)

## Critérios de aceitação
- [ ] A decisão está registada como ADR em `docs/decisions.md` com data, opção escolhida e motivo (prova: diff do ficheiro).
- [ ] Se a decisão for ligar por defeito: o threat model foi actualizado pelo Rodolfo e o valor do setting em `game/project.godot` bate com o ADR (prova: `grep -n 'weather/enabled' game/project.godot`).
- [ ] O README indica ao utilizador como ligar ou desligar o clima real (prova: diff do README).

## Fora de âmbito
- Trocar de fornecedor de meteorologia.

## Prova exigida
- Diff do ADR e, se aplicável, do threat model e do project.godot.

## Relatório

Decisao tomada pelo Rodolfo em 2026-09-15.

Clima aleatorio com pesos naturais implementado em WeatherService.
Sem pedidos de rede. Muda a cada 30 minutos de jogo.
ADR-012 em docs/decisions.md regista a decisao e o plano V2.
Testes actualizados: 4 testes novos (condicao valida, distribuicao, FAKE_WEATHER).

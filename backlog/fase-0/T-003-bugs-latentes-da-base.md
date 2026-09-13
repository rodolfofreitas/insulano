---
id: T-003
titulo: Corrigir bugs latentes do código herdado com testes de regressão
fase: 0
estado: pronto
tipo: codigo
depende_de: [T-002]
---

## Objectivo
Os seis defeitos encontrados na leitura da base deixam de existir, cada um protegido por um teste
que falhava antes da correcção.

## Ler antes
- `game/beehave/find_usable_for_need_condition.gd`, `game/object/need_replentishing_unsable.gd`,
  `game/beehave/set_delta_on_blackboard.gd`, `game/beehave/fishing_action.gd`, `game/fishing_spot.gd`
- `agent_docs/testing.md` §3

## Critérios de aceitação
- [ ] **Sinal trocado:** `searchArea.body_exited` liga a `_body_exited_area` (hoje liga a `_body_entered_area`, logo objectos que saem da área nunca saem da lista). Teste GUT que simula entrada e saída e verifica `objects_in_area`.
- [ ] **find_custom sobre Strings:** `NeedReplentishingUsable.get_satisfying_needs()` com `max_replentish_value == 0` não rebenta (hoje chama `n.name` sobre `String`). Teste GUT.
- [ ] **Constante errada:** `FAILED` substituído por `FAILURE` em `find_usable_for_need_condition.gd`. Teste que verifica o retorno `FAILURE` sem objectos.
- [ ] **Print a cada tick:** `set_delta_on_blackboard.gd` já não imprime `delta = ...` (grep no `reports/boot.log` dá 0 linhas).
- [ ] **Índice -1:** `FishingAction.spawn_fish` funciona quando o personagem é o primeiro filho do pai. Teste GUT.
- [ ] **Círculos de debug:** `fishing_spot.gd` só desenha o círculo vermelho no editor (`Engine.is_editor_hint()`); screenshot sem círculos.
- [ ] `scripts/verify.sh --visual` sem FALHOU

## Fora de âmbito
- Frases em inglês do `TalkAction` (a T-106 substitui a acção)
- Qualquer mudança de balanceamento (velocidades, fome)

## Prova exigida
- Um teste por bug com nome `test_regression_<bug>`; `docs/proof/T-003-sem-circulos.png`

## Relatório
(preenchido pelo executor)

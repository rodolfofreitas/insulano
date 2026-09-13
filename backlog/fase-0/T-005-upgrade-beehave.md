---
id: T-005
titulo: Actualizar o addon Beehave de 2.8.3 para 2.9.3
fase: 0
estado: pronto
tipo: infra
depende_de: [T-003]
---

## Objectivo
O addon Beehave fica na última versão estável para Godot 4, sem regressões de comportamento.

## Ler antes
- `game/addons/beehave/plugin.cfg`, notas de versão em `https://github.com/bitbrain/beehave/releases`

## Critérios de aceitação
- [ ] `game/addons/beehave/plugin.cfg` indica `version="2.9.3"` (código obtido com `gh release download v2.9.3 -R bitbrain/beehave --archive tar.gz`)
- [ ] `scripts/verify.sh --visual` sem FALHOU; screenshot com o personagem a agir
- [ ] Mudanças de API que afectem `game/beehave/*.gd` corrigidas e listadas no Relatório
- [ ] `docs/assets-licencas.md` e `agent_docs/tech_stack.md` com a versão nova

## Fora de âmbito
- Reescrever a behavior tree

## Prova exigida
- `docs/proof/T-005-beehave-2.9.3.png`

## Relatório
(preenchido pelo executor)

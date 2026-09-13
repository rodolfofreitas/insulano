---
id: T-002
titulo: Limpar lint, formatação e docstrings do código herdado e esvaziar a baseline
fase: 0
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
Todo o GDScript de `game/` (fora de `addons/`) cumpre as regras de lint, formatação e documentação,
e `scripts/gd_baseline.txt` fica sem entradas, sem mudar comportamento.

## Ler antes
- `scripts/gd_baseline.txt` (os 21 ficheiros)
- `agent_docs/code_patterns.md` §1, §2 e §8
- `reports/gdlint.log` depois de `scripts/verify.sh --quick`

## Critérios de aceitação
- [ ] `scripts/gd_baseline.txt` só tem comentários (zero caminhos)
- [ ] `scripts/verify.sh` dá `lint PASSOU` (não AVISOS) e `docs PASSOU`
- [ ] Todos os testes GUT que já existiam passam sem alteração aos ficheiros de teste
- [ ] `boot_smoke` passa
- [ ] Renomeações de variáveis exportadas (`fishingRod`, `searchArea`, `navigationAgent`) actualizam as cenas `.tscn` e a cena abre sem avisos de propriedade em falta (`grep -c "fishingRod" game/**/*.tscn` igual a 0)
- [ ] Cada ficheiro ganhou cabeçalho `##` a explicar a responsabilidade e o papel na behavior tree

## Fora de âmbito
- Corrigir bugs (T-003): se encontrar um, anotar no Relatório e não corrigir aqui
- Renomear ficheiros (ex.: `need_replentishing_unsable.gd`)

## Prova exigida
- Saída de `scripts/verify.sh` no Relatório; diff sem mudanças de lógica (revisão pelo `insulano-reviewer`)

## Relatório
(preenchido pelo executor)

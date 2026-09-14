---
id: T-006
titulo: Corrigir erase sem guarda de tipo em _body_exited_area
fase: 0
estado: pronto
tipo: codigo
depende_de: [T-003]
---

## Objectivo
`FundUsableForNeedCondition._body_exited_area` deixa de disparar `ERROR: Attempted to erase
an object into a TypedArray` quando um corpo que não é `UsableObject` sai da área de busca.

## Contexto (regressão descoberta pela T-004, fora do âmbito da T-004)
A T-003 corrigiu o sinal trocado em `game/beehave/find_usable_for_need_condition.gd`, ligando
`search_area.body_exited` a `_body_exited_area` (antes ligava, por erro, a `_body_entered_area`).
Isso passou a executar `_body_exited_area` de facto em jogo, expondo um bug latente que estava
morto desde sempre: `objects_in_area` é `Array[UsableObject]` tipado; `_body_entered_area`
(linha 85) só adiciona à lista com a guarda `if body is UsableObject`, mas `_body_exited_area`
(linha 90) chama `objects_in_area.erase(body)` sem essa guarda. Quando um `body: Node2D`
qualquer que não seja `UsableObject` sai da área, o `erase()` sobre o array tipado dispara:

```
ERROR: Attempted to erase an object into a TypedArray, that does not inherit from 'GDScript'.
ERROR: Condition "!_p->typed.validate(value, "erase")" is true.
```

Confirmado em `reports/export-run.log` e `reports/boot.log` (backtrace aponta para
`find_usable_for_need_condition.gd:90`) numa corrida real do binário exportado pela T-004,
2026-09-14. O gate `scripts/export.sh` não apanha isto porque só faz grep a
`SCRIPT ERROR|Parse Error|Failed to load script`, e estes são `ERROR` de motor, não os três
padrões vigiados.

## Ler antes
- `game/beehave/find_usable_for_need_condition.gd` (linhas 80-95 aprox., `_body_entered_area` e
  `_body_exited_area`)
- `reports/export-run.log`, `reports/boot.log` da corrida de 2026-09-14 (T-004) para o texto
  exacto do erro

## Critérios de aceitação
- [ ] `_body_exited_area` só chama `objects_in_area.erase(body)` quando `body is UsableObject`
      (mesma guarda que `_body_entered_area` já tem)
- [ ] Teste GUT de regressão que simula um `body` não-`UsableObject` (ex. `Node2D` simples) a
      entrar e a sair da área via `_body_entered_area`/`_body_exited_area`, e confirma que não é
      lançado nenhum erro (falhava antes da correcção, passa depois)
- [ ] `scripts/verify.sh --visual` sem FALHOU
- [ ] `grep -E "TypedArray|typed.validate" reports/export-run.log reports/boot.log` dá 0 linhas
      numa corrida fresca do binário exportado (`scripts/export.sh` ou boot smoke)

## Fora de âmbito
- Qualquer outra revisão de `find_usable_for_need_condition.gd` além desta guarda
- Reabrir ou alterar critérios já `feito` da T-003

## Prova exigida
- Nome do teste `test_regression_<bug>`; grep aos logs mencionados no último critério, colado no
  Relatório

## Relatório
(preenchido pelo executor)

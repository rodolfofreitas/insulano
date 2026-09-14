---
id: T-006
titulo: Corrigir erase sem guarda de tipo em _body_exited_area
fase: 0
estado: feito
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
- [x] `_body_exited_area` só chama `objects_in_area.erase(body)` quando `body is UsableObject`
      (mesma guarda que `_body_entered_area` já tem)
- [x] Teste GUT de regressão que simula um `body` não-`UsableObject` (ex. `Node2D` simples) a
      entrar e a sair da área via `_body_entered_area`/`_body_exited_area`, e confirma que não é
      lançado nenhum erro (falhava antes da correcção, passa depois)
- [x] `scripts/verify.sh --visual` sem FALHOU
- [x] `grep -E "TypedArray|typed.validate" reports/export-run.log reports/boot.log` dá 0 linhas
      numa corrida fresca do binário exportado (`scripts/export.sh` ou boot smoke)

## Fora de âmbito
- Qualquer outra revisão de `find_usable_for_need_condition.gd` além desta guarda
- Reabrir ou alterar critérios já `feito` da T-003

## Prova exigida
- Nome do teste `test_regression_<bug>`; grep aos logs mencionados no último critério, colado no
  Relatório

## Relatório

### O que mudou

- `game/beehave/find_usable_for_need_condition.gd`: `_body_exited_area` passou a verificar
  `if body is UsableObject` antes de chamar `objects_in_area.erase(body)`, com docstring `##`
  a explicar o motivo do erro de motor e a decisão de **não** repetir a segunda condição de
  `_body_entered_area` (`body.is_in_group(usable_objects_group)`). Decisão registada: copiar só
  a verificação de tipo, não a de grupo, porque um objecto que saiu do grupo mas continua a ser
  um `UsableObject` válido, fisicamente dentro da área, deve poder ser removido de
  `objects_in_area` quando sai; a condição de grupo em `_body_entered_area` decide o que **entra**
  na lista, não o que é elegível para **sair** dela. Repetir as duas condições no `erase`
  arriscava deixar entradas presas na lista (nunca removidas) se o objecto mudasse de grupo
  antes de sair fisicamente da área.
- `game/tests/integration/test_find_usable_for_need_condition.gd`: teste novo
  `test_regression_erase_sem_guarda_de_tipo`, que cria um `Node2D` simples (não `UsableObject`),
  emite `body_entered` e depois `body_exited` na área de busca, e confirma que
  `objects_in_area` fica vazio nos dois momentos e que não houve nenhum `ERROR` de motor
  (`assert_engine_error_count(0, ...)`, asserção explícita). Protecção dupla: além dessa
  asserção, o `GutErrorTracker` do GUT (`game/addons/gut/error_tracker.gd`) já trata qualquer
  `ERROR` de motor como falha de teste por defeito (`failure_error_types` inclui `"engine"` em
  `gut_config.gd`, e o `.gutconfig.json` do projecto não o desliga), pelo que o teste falharia
  mesmo sem a asserção explícita se a guarda faltasse.
- `CHANGELOG.md`: entrada em "Corrigido" a descrever o bug e a correcção.

### Testes primeiro (Lei do TDD)

Corri o teste **antes** da correcção e falhou pelo motivo certo (não parse error):

```
$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd \
  -gconfig=res://.gutconfig.json -gtest=res://tests/integration/test_find_usable_for_need_condition.gd

test_regression_erase_sem_guarda_de_tipo
    [Failed]:  Unexpected Errors:
    [1] <engine-0>Method/function failed. Returning: false
    [2] <engine-0>Condition "!_p->typed.validate(value, "erase")" is true.
          at line -1
Failing Tests        1
```

Depois da correcção, os 21 testes da suite integration+unit passam (`Totals: Passing Tests 21`).

### Comandos corridos e resultado

1. `scripts/verify.sh --quick` (baseline, antes de tocar em código): `VEREDICTO: PASSOU`.
2. `godot --headless --path game --import`: reimportação depois de editar `.gd` (sem `class_name`
   nova, mas por precaução).
3. `uvx --from 'gdtoolkit==4.*' gdformat game/beehave/find_usable_for_need_condition.gd
   game/tests/integration/test_find_usable_for_need_condition.gd`: `0 files reformatted, 2 files
   left unchanged`.
4. `uvx --from 'gdtoolkit==4.*' gdlint <os mesmos dois ficheiros>`: `Success: no problems found`.
5. `scripts/verify.sh --visual`:

```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (43 tarefas, 0 erros)
pytest       PASSOU         40 passed in 0.15s
lint         PASSOU         31 ficheiros próprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 21;Passing Tests 21
boot         PASSOU         BOOT_SMOKE PASSOU: fome -30.0 pontos, deslocação máxima 616 px
visual       PASSOU         reports/verify-latest.png (inspeccionar a imagem antes de declarar feito)
VEREDICTO: PASSOU
```

   Abri `reports/verify-latest.png`: náufrago junto à água, balão de fala "Hm hm hm...", barra
   de fome a 95%, sem qualquer artefacto visual estranho. Cena normal.

6. `scripts/export.sh` (corrida fresca do binário exportado, para o critério 4, que fica
   desactualizado no `reports/export-run.log` de 2026-09-14 10:28, gerado pela T-004 antes
   desta correcção):
   `PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script`.
7. `grep -E "TypedArray|typed.validate" reports/export-run.log reports/boot.log`: **0 linhas**
   (grep sai com exit 1, sem output). Conteúdo integral do `reports/export-run.log` fresco
   (`10:47`, 433 bytes, antes tinha 713 bytes com o erro):

```
ERROR: Capture not registered: 'beehave'.
   at: unregister_message_capture (core/debugger/engine_debugger.cpp:62)
WARNING: 6 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
```

   (o `ERROR: Capture not registered: 'beehave'` e o `ObjectDB leaked` são ruído conhecido de
   arranque/saída headless, não relacionado com este bug; nenhum deles corresponde aos padrões
   `TypedArray`/`typed.validate` vigiados pelo critério.)

### Auto-adversário (antes de declarar concluído)

- Grep a `_body_exited_area`/`objects_in_area` em todo `game/` (fora de `tests/`): o único
  chamador do sinal é a própria classe (`search_area.body_exited.connect(...)`); nenhum outro
  ficheiro depende deste comportamento, logo o âmbito da correcção está fechado.
- Pergunta de bolso: se a guarda estivesse ausente, o teste apanhava? Sim, de duas formas
  independentes: a asserção explícita `assert_engine_error_count(0, ...)` falha directamente, e
  o `GutErrorTracker` também falha o teste em qualquer `ERROR` de motor durante a corrida
  (confirmado a correr o teste antes da correcção, secção acima).
- Verifiquei que a correcção não introduz um `push_error`/silenciamento indevido: quando `body`
  não é `UsableObject`, a função agora simplesmente não faz nada (retorna), tal como
  `_body_entered_area` já fazia para o caso simétrico.

### Não verificado

- Não corri `--llm` nem `--export` dentro do próprio `verify.sh` (só correu `--visual`); corri
  `scripts/export.sh` à parte para o critério 4, o que cobre a parte de export. `--llm` não se
  aplica: esta tarefa não tocou em prompt, regras nem `LLMBridge`.
- Não copiei captura para `docs/proof/`: a tarefa é `tipo: codigo`, não `visual`; a Definition of
  Done da tabela do AGENTS.md só exige isso para `visual`. Abri a imagem de qualquer forma (secção
  acima) por rigor, já que `--visual` correu.

### Estado final

Estado: **feito**. Confirmado pelo `insulano-verifier` (PASSOU) e pelo `insulano-reviewer`
(APROVADO, sem bloqueantes) na volta final, depois de duas rondas de correcção (uma pelo builder,
uma de texto directa do orquestrador) terem resolvido os pontos apanhados pela revisão adversarial.
Todos os critérios de aceitação estão marcados `[x]` com prova.

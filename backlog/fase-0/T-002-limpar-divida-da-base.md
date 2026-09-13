---
id: T-002
titulo: Limpar lint, formatação e docstrings do código herdado e esvaziar a baseline
fase: 0
estado: feito
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
- [x] `scripts/gd_baseline.txt` só tem comentários (zero caminhos)
- [x] `scripts/verify.sh` dá `lint PASSOU` (não AVISOS) e `docs PASSOU`
- [x] Todos os testes GUT que já existiam passam sem alteração aos ficheiros de teste
- [x] `boot_smoke` passa
- [x] Renomeações de variáveis exportadas (`fishingRod`, `searchArea`, `navigationAgent`) actualizam as cenas `.tscn` e a cena abre sem avisos de propriedade em falta (`grep -c "fishingRod" game/**/*.tscn` igual a 0)
- [x] Cada ficheiro ganhou cabeçalho `##` a explicar a responsabilidade e o papel na behavior tree

## Fora de âmbito
- Corrigir bugs (T-003): se encontrar um, anotar no Relatório e não corrigir aqui
- Renomear ficheiros (ex.: `need_replentishing_unsable.gd`)

## Prova exigida
- Saída de `scripts/verify.sh` no Relatório; diff sem mudanças de lógica (revisão pelo `insulano-reviewer`)

## Relatório

**Estado:** todos os critérios de aceitação cumpridos e verificados; deixo `estado: em-curso`
porque, por doutrina (AGENTS.md §7, "o construtor não se julga"), quem implementa não declara o
próprio veredicto final. Pede-se ao `insulano-verifier` (ou ao Hermes) a confirmação e a mudança
para `feito`.

### O que mudou
- Os 21 ficheiros de `scripts/gd_baseline.txt` (behavior tree, `character/`, `guy/`, `object/`,
  `fishing_spot.gd`, `need_bar.gd`) ganharam: reordenação `class_name`/`extends` exigida pelo
  `class-definitions-order` do gdlint (ver ADR-011), cabeçalho `##` com responsabilidade e papel na
  behavior tree, `##` em cada função pública, correcção de `trailing-whitespace`, `max-line-length`,
  `no-else-return` e nomes de variável/função inválidos (`mapId` -> `map_id`), sem alterar nenhuma
  lógica (só formatação, documentação e nomes; diff revisto ficheiro a ficheiro, ver secção
  "Diff sem mudanças de lógica").
- Renomeadas as 3 variáveis exportadas pedidas: `fishingRod` -> `fishing_rod`
  (`beehave/fishing_action.gd`), `searchArea` -> `search_area`
  (`beehave/find_usable_for_need_condition.gd`), `navigationAgent` -> `navigation_agent`
  (`character/character.gd`, usada também em `find_random_spot_condition.gd` e
  `go_to_usable_action.gd`). `game/guy/guy.tscn` actualizada nos 3 `node_paths`/atribuições
  correspondentes. `grep -c "fishingRod" game/**/*.tscn` dá 0 em todos os ficheiros (incluindo os
  do addon GUT).
- `scripts/gd_baseline.txt` esvaziada (só comentário explicativo).
- `agent_docs/code_patterns.md` §1 corrigido: a ordem documentada tinha `extends` antes de
  `class_name`, mas o gdtoolkit 4 (config por defeito, sem ficheiro de configuração) exige o
  inverso; o próprio exemplo do documento falhava o `gdlint` (testado). Acrescentada também a
  convenção de prefixar `_` em parâmetros não usados nas folhas do Beehave, e a de suprimir
  `class-variable-name` por linha (nunca por `.gdlintrc` de projecto).
- `docs/decisions.md`: ADR-011 com o porquê da ordem `class_name`/`extends` e da supressão por
  linha em `guy/direction.gd`.
- `docs/architecture.md`: tabela de componentes regenerada por `check_docs.py --fix`; secção 7
  actualizada para "ADR-001 a ADR-011"; removida da secção 8 a linha de dívida "código herdado sem
  lint nem docstrings", que esta tarefa fecha.
- `CHANGELOG.md`: entrada em `[Não lançado] > Corrigido`.
- `scripts/verify.sh`: o passo de lint só chama `gdlint`/`grep` na baseline se ela tiver entradas
  (`if [ "${#BASELINE[@]}" -gt 0 ]`), em vez de confiar em `gdlint` sem argumentos falhar de uma
  forma que por coincidência não batia com `grep 'Error:'`.

### Volta 2: correcção dos 5 bloqueantes do `insulano-reviewer`
1. **`.gdlintrc` untracked.** Resolvido apagando o ficheiro (ver ponto 2): já não há nada para
   ficar por adicionar ao commit.
2. **Excepção não mínima.** Troquei o `.gdlintrc` (relaxava `class-variable-name` no repositório
   inteiro) por supressão por linha do próprio gdtoolkit 4.5+, só à volta das 5 declarações em
   `guy/direction.gd` (`# gdlint:disable=class-variable-name` antes de `UP`/`RIGHT`/`DOWN`/`LEFT`/
   `ALL_DIRECTIONS`, `# gdlint:enable=class-variable-name` a seguir). Confirmado com `gdlint` e
   `gdformat --check` só nesse ficheiro, sem `.gdlintrc` nenhum no repositório: limpo. ADR-011
   reescrito para descrever a supressão por linha e diz sem eufemismo que qualquer nome em
   MAIÚSCULAS fora deste ficheiro continua a falhar o lint por defeito.
3. **3 bugs em código tocado, agora anotados no Relatório (secção seguinte) e nos cabeçalhos `##`
   dos ficheiros:** o sinal trocado em `find_usable_for_need_condition.gd`, o `n.name` sobre
   `Array[String]` em `need_replentishing_unsable.gd`, e o `if position != null` sempre verdadeiro
   em `go_to_usable_action.gd`.
4. **Docstrings com afirmação falsa, corrigidas:** `go_to_usable_action.gd` deixou de dizer que o
   ramo `else` "pára o movimento sem sucesso nem falha" (é código morto, ver bug abaixo);
   `set_delta_on_blackboard.gd` deixou de chamar `RUNNING` de "falha" e deixou de especular sobre
   "só acontece no primeiro frame" sem prova.
5. **Deriva em `docs/architecture.md`:** corrigido "ADR-001 a ADR-010" para "ADR-001 a ADR-011";
   removida a linha de dívida "código herdado sem lint nem docstrings" da secção 8 (esta tarefa
   fecha-a; a dívida de bugs latentes continua na linha seguinte, para a T-003).

A melhorar (aplicadas, não bloqueavam): `need_low_condition.gd` "só têm sucesso" -> "só tem
sucesso"; `usable_object_container.gd` "união" -> "concatenação" (não elimina duplicados,
`append_array`); guarda em `scripts/verify.sh` para baseline vazia (acima); e a descrição do diff
de `fishing_action.gd` abaixo corrigida (era "remoção de variável local morta", não "chamar
`get_parent()` uma vez em vez de duas" como a Volta 1 dizia).

### Bugs encontrados, não corrigidos (fora de âmbito, para T-003)
- `beehave/find_usable_for_need_condition.gd`: no ramo de falha do `tick`, usa a constante `FAILED`
  (erro global, vale 1) em vez de `FAILURE`; só funciona porque calham a ter o mesmo valor numérico
  (já documentado em AGENTS.md §10 e em `docs/architecture.md` §8).
- A mesma classe chama-se `FundUsableForNeedCondition` (erro tipográfico herdado, "Fund" em vez de
  "Find"). Não corrigido: mudar `class_name` é risco de quebrar referências e está fora do âmbito
  de lint/docs.
- `beehave/find_usable_for_need_condition.gd:31` (linha que esta tarefa tocou, ao renomear
  `searchArea` -> `search_area`): `search_area.body_exited.connect(_body_entered_area)` liga o
  sinal de saída ao handler de entrada; `_body_exited_area` nunca é ligado a nada, por isso
  `objects_in_area` nunca perde um objecto que saia fisicamente da área.
- `object/need_replentishing_unsable.gd:20`: `result.find_custom(func(n): return n.name ==
  need_name)` sobre um `Array[String]`; `String` não tem propriedade `.name`, o que dá erro em
  runtime se este ramo chegar a correr. Agravado por `max_replentish_value == 0` ser uma guarda
  quase impossível de atingir, já que `use()` chama `queue_free()` assim que o valor fica `<= 0`.
- `beehave/go_to_usable_action.gd:16-19`: `position` é declarada `Vector2` (tipo por valor), por
  isso nunca é `null`; `if position != null` é sempre verdadeiro e o ramo `else` (linhas 44-45, que
  pararia o personagem) é código morto.
- `beehave/set_delta_on_blackboard.gd`: `print("delta = ", delta)` dentro de `tick`, que corre a
  cada frame (o próprio `code_patterns.md` §8 já assinala isto como problema a corrigir na T-003).
- `object/need_replentishing_unsable.gd`: nome do ficheiro e da classe (`need_replentishing_unsable.gd`,
  `NeedReplentishingUsable`) têm erros ortográficos herdados ("Replentishing" em vez de
  "Replenishing"); não renomeado, é explicitamente fora de âmbito desta tarefa.

### Prova: `scripts/verify.sh` (sem flags, corrido depois da Volta 2)
```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (42 tarefas, 0 erros)
pytest       PASSOU         40 passed in 0.05s
lint         PASSOU         26 ficheiros próprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 11;Passing Tests 11
boot         PASSOU         BOOT_SMOKE PASSOU: fome -24.6 pontos, deslocação máxima 616 px
VEREDICTO: PASSOU
```
Confirmado também, isoladamente, sem nenhum `.gdlintrc` no repositório: `gdlint` e
`gdformat --check` nos 21 ficheiros da antiga baseline (incluindo `guy/direction.gd` com a
supressão por linha) devolvem "Success: no problems found" / "21 files would be left unchanged".
Os 11 testes GUT (`test_direction.gd`, `test_need.gd`, `test_main_scene.gd`) não foram alterados.

### Diff sem mudanças de lógica
Revi manualmente o `git diff` de cada um dos 21 ficheiros: as únicas mudanças são reordenação
`class_name`/`extends`, espaçamento (`gdformat`), comentários `##` (incluindo os bugs anotados
acima), os 3 renomes pedidos, `mapId` -> `map_id`, prefixo `_` em parâmetros não usados, remoção de
uma variável local morta e nunca lida (`var parent` em `fishing_action.gd::spawn_fish`), a
extracção de duas sub-expressões repetidas para variáveis locais (`usable_object` em
`find_usable_for_need_condition.gd`, `layers` em `find_random_spot_condition.gd`) só para caber na
linha de 100 caracteres, e as duas linhas `# gdlint:disable/enable` em `direction.gd`. Nenhuma
condição, valor de retorno ou ordem de execução foi alterada (os bugs listados acima já existiam
antes desta tarefa; só ficaram documentados). Pede-se ao `insulano-reviewer` a confirmação
independente, conforme a Prova exigida da tarefa.

### Não verificado
- `scripts/verify.sh --visual`, `--llm` e `--export` não corridos: esta tarefa é `tipo: codigo`
  sem alterações de UI, prompt/LLM ou export, e a doutrina só os exige nesses casos.
- Não corri o jogo em modo janela/interactivo; a prova é o `boot_smoke` (30 s simulados) e o `gut`.

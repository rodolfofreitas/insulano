---
id: T-102
titulo: PhraseContext e PromptBuilder a partir do template partilhado
fase: 1
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O prompt enviado ao Ollama é montado a partir de `game/data/prompts/phrase_prompt.txt` e de um
contexto tipado, exactamente como o `scripts/llm_eval.py` o monta.

## Ler antes
- `agent_docs/tech_design.md` §4.2, `game/data/prompts/phrase_prompt.txt`, `scripts/llm_eval.py` (`render_prompt`)

## Critérios de aceitação
- [x] `game/llm/phrase_context.gd` e `game/llm/prompt_builder.gd` com a API do tech design
- [x] Teste GUT: com o contexto do caso `tarde-pescar` de `evals/phrase_cases.json`, o prompt gerado é igual, carácter a carácter, ao de `python3 -c` com `render_prompt` (texto esperado gravado em `game/tests/fixtures/prompt_tarde_pescar.txt` gerado pelo script Python)
- [x] Teste GUT: contexto incompleto devolve `""` e regista erro (nunca prompt com `{campo}` por preencher)
- [x] Teste GUT: `hunger_label_for` nas fronteiras 60, 25 e 0
- [x] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Alterar o texto do prompt (T-108)

## Prova exigida
- `game/tests/unit/test_prompt_builder.gd`, fixture gerada por Python

## Relatório

### O que foi feito

- `game/llm/phrase_context.gd`: `class_name PhraseContext extends RefCounted` com os seis campos
  do tech design (`hour`, `period`, `action`, `hunger_label`, `weather`, `holiday`) e
  `to_template_fields() -> Dictionary`, que traduz `hunger_label` para a chave `hunger` que o
  template usa (as outras cinco chaves mantêm o nome do campo).
- `game/llm/prompt_builder.gd`: `class_name PromptBuilder extends RefCounted` com
  `load_template()` (lê `res://data/prompts/phrase_prompt.txt`, `""` + `push_error` se vazio/faltar),
  `build(template, context)` e `hunger_label_for(percentage)` com os limiares exactos do tech
  design (`>60` satisfeito, `>25` com fome, resto esfomeado; 60 e 25 exactos caem no ramo de baixo,
  ou seja "com fome" e "esfomeado" respectivamente).
- `build()` recusa contexto incompleto: para cada campo de texto (`period`, `action`, `hunger`,
  `weather`, `holiday`) vazio, devolve `""` com `push_error` antes de tentar formatar (nunca chega a
  chamar `String.format`, que ao contrário do `str.format` do Python **não** levanta erro por chave
  em falta, só deixa a chaveta literal). Como segunda rede de segurança, depois de formatar procura
  `"{"` no resultado; se sobrar alguma, também devolve `""` com erro. Isto cobre tanto contexto
  incompleto como uma eventual divergência futura entre o template e os campos que o
  `PhraseContext` fornece.
- `game/tests/fixtures/prompt_tarde_pescar.txt`: gerado por
  `python3 -c "... from llm_eval import render_prompt, PROMPT_PATH, CASES_PATH ..."` sobre o caso
  `tarde-pescar` de `evals/phrase_cases.json` (hour 17, period "fim da tarde", action "pescar",
  hunger "com fome", weather "sol", holiday "nenhuma"). Escrito com `encoding="utf-8", newline="\n"`;
  confirmei com `od -c` que não tem `\r\n` e que os bytes finais coincidem com os do próprio
  `game/data/prompts/phrase_prompt.txt` (ambos terminam em `...explicações.\n`, com os dois bytes
  UTF-8 de "õ" antes do "es.").
- `game/tests/unit/test_prompt_builder.gd`: 7 testes.
  - `test_build_matches_python_render_for_tarde_pescar`: constrói o `PhraseContext` do caso
    `tarde-pescar` à mão (os mesmos valores de `evals/phrase_cases.json`), chama
    `PromptBuilder.build(PromptBuilder.load_template(), context)` e compara `assert_eq` contra o
    texto lido da fixture. Paridade carácter a carácter confirmada.
  - `test_incomplete_context_returns_empty_string_and_no_curly_braces`: contexto sem `weather` nem
    `holiday`; confirma `""`, confirma que não sobra `"{"` no resultado, e `assert_push_error` para
    confirmar que o erro fica registado (sem este assert o GUT reprovava o teste por "Unexpected
    Errors" mesmo com as outras asserções a passar; ver nota abaixo).
  - `test_unknown_field_left_by_format_is_caught_by_second_net` (acrescentado na revisão, ver
    "Correcção dos bloqueantes do reviewer" abaixo): contexto COMPLETO com um template sintético
    `"prefixo {desconhecido} {period}"`; exercita especificamente a segunda rede
    (`prompt_builder.gd:45-47`), que a validação de contexto incompleto (linhas 38-42) nunca chega
    a cobrir porque não dispara com contexto completo.
  - `test_hunger_label_for_above_60_is_satisfeito` (61.0), `test_hunger_label_for_at_60_is_com_fome`
    (60.0 exacto), `test_hunger_label_for_at_25_is_esfomeado` (25.0 exacto),
    `test_hunger_label_for_at_0_is_esfomeado` (0.0): as três fronteiras pedidas.
- `docs/architecture.md` regenerado por `python3 scripts/check_docs.py --fix` (mapa de componentes).
- `CHANGELOG.md`, entrada nova em `[Não lançado] > Adicionado` para a T-102.

### Desvio do plano inicial (documentado, não é mudança de contrato)

Nenhum desvio à API do `tech_design.md` §4.2: os nomes e assinaturas ficaram exactamente como
especificados. O único ponto que exigiu decisão de implementação (não estava no tech design) foi
*como* detectar "contexto incompleto", porque `String.format()` do Godot não levanta erro por chave
em falta (o `str.format` do Python sim). Resolvido com validação explícita dos cinco campos de texto
antes de formatar, mais a verificação de `"{"` residual depois. Não alterei `tech_design.md` porque
a assinatura pública (`build(template, context) -> String`) não mudou, só o comportamento interno.

### Testes: primeiro a falhar pelo motivo certo

Corri o teste antes de escrever `phrase_context.gd`/`prompt_builder.gd`:
`SCRIPT ERROR: Parse Error: Could not find type "PhraseContext" in the current scope.` (e
equivalente para `PromptBuilder`), confirmando que falhava por ausência das classes, não por erro
de sintaxe do teste.

### Comandos corridos e resultado

```
$ python3 scripts/backlog.py list        # T-102 pronto, depende de T-001 (feito)
$ scripts/verify.sh --quick               # PASSOU, antes de tocar em nada
$ python3 -c "... render_prompt(template, case['context']) ..."   # gerou a fixture
$ $(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd \
    -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_prompt_builder.gd
  # -gtest= não restringe a suite: o .gutconfig.json já lista todos os
  # directórios de teste, por isso o processo GUT corre sempre os 10 scripts
  # (31 testes) inteiros; a diferença antes/depois da implementação vê-se no
  # resultado desse total, não numa corrida isolada deste ficheiro
  # antes da implementação: SCRIPT ERROR Parse Error (motivo certo)
  # depois da implementação: Tests 31; Passing Tests 31 (todo o processo GUT, sem falhas)
$ uvx --from 'gdtoolkit==4.*' gdformat game/llm/phrase_context.gd game/llm/prompt_builder.gd \
    game/tests/unit/test_prompt_builder.gd   # 0 files reformatted (já formatados)
$ $(mise which godot) --headless --path game --import   # PhraseContext e PromptBuilder registados
$ python3 scripts/check_docs.py --fix     # PASSOU (0 falhas); docs/architecture.md regenerado
$ scripts/verify.sh
  docs PASSOU · backlog PASSOU · pytest PASSOU (40 passed) · lint PASSOU (36 ficheiros)
  import PASSOU · gut PASSOU (Tests 31; Passing Tests 31) · boot PASSOU
  VEREDICTO: PASSOU
```

`--llm` não corrido: esta tarefa não tocou `game/data/prompts/phrase_prompt.txt` (fora de âmbito,
é a T-108), nem `phrase_rules.json`, nem o `LLMBridge` (ainda não existe, é a T-105); não há
mudança de comportamento contra o Ollama para o eval medir.

### Auto-adversário (Lei 6, 3 ataques)

1. **Linha de comando final vs bytes reais**: `od -c` na fixture e no template confirmou terminação
   `\n` (sem `\r\n`) e a mesma sequência UTF-8 para "õ" nos dois ficheiros; a paridade carácter a
   carácter não depende de uma coincidência de terminal.
2. **`push_error` mascarado**: descobri, ao correr o teste de contexto incompleto pela primeira vez,
   que o GUT reprova um teste com "Unexpected Errors" mesmo que todas as `assert_eq` passem, se
   houver um `push_error` não reclamado. Troquei para `assert_push_error("contexto incompleto")`,
   que consome o erro e prova ao mesmo tempo que ele foi mesmo emitido (não só que o resultado é
   `""`, que por si só não provava a parte "regista erro" do critério de aceitação).
3. **Todos os 8 casos de `evals/phrase_cases.json`, não só `tarde-pescar`**: corri
   `render_prompt` em Python para os 8 casos e confirmei que todos terminam da mesma forma e têm
   comprimentos plausíveis (395-413 caracteres); não há nenhum caso com acentuação ou campo que
   quebre o `String.format()` do Godot de forma diferente do que o teste único cobre. Não escrevi
   fixture nem teste para os outros 7 (fora do que a tarefa pediu: só `tarde-pescar`), mas a
   inspecção mostrou que não há campo estranho nos outros casos que justificasse ampliar o âmbito.

Pergunta de bolso: se `PromptBuilder.build` estivesse a produzir um prompt com um `\n` a mais, um
espaço a menos, ou a trocar "com fome" por "fome", o teste `test_build_matches_python_render_for_tarde_pescar`
apanhava-o, porque compara com `assert_eq` contra o texto exacto lido da fixture (sem `strip` nem
normalização). Se `hunger_label_for` tivesse a fronteira em `>=60` em vez de `>60`, o teste
`test_hunger_label_for_at_60_is_com_fome` apanhava-o.

### Não verificado

- Não corri `scripts/verify.sh --llm` (justificação acima: fora de âmbito desta tarefa).
- Não corri `scripts/verify.sh --visual` nem `--export` (tarefa `tipo: codigo`, sem componente
  visual nem de export).

### Correcção dos bloqueantes do reviewer (segunda passagem)

O `insulano-verifier` deu PASSOU mas o `insulano-reviewer` levantou 2 bloqueantes. Corrigidos:

1. **Segunda rede sem teste** (`prompt_builder.gd:45-47`). Confirmado por mutação: com as 3 linhas
   apagadas (cópia temporária, restaurada de imediato), a suite antiga continuava "Passing Tests
   31" (todos os testes existentes passavam mesmo sem a segunda rede, porque o único teste de
   contexto incompleto dispara sempre na validação anterior, linhas 38-42, e nunca chega a esta).
   Acrescentei `test_unknown_field_left_by_format_is_caught_by_second_net` com um contexto completo
   e um template sintético com um campo desconhecido (`"prefixo {desconhecido} {period}"`);
   confirma `result == ""` e `assert_push_error("campo por preencher")`. Refiz a mutação com o
   teste novo: `[Failed]: ["prefixo {desconhecido} fim da tarde"] expected to equal [""]` e
   `Expected push_error error containing 'campo por preencher'`, ou seja, o teste apanha mesmo a
   ausência da segunda rede. Restaurei o ficheiro original a seguir (`git status` confirma
   `prompt_builder.gd` sem diferenças face ao commit anterior à mutação).
2. **Docstring de `hour` em `phrase_context.gd`, falsa**. Corrigida: já não afirma que um `hour`
   nunca atribuído marca o contexto como incompleto (é falso: `build()` só valida os cinco campos
   de texto, `hour` é `int` e fica 0 por defeito, que é uma hora válida). A docstring agora explica
   a exclusão em vez de a esconder.

### Melhorias baratas aplicadas na mesma passagem

- `test_prompt_builder.gd`: cabeçalho agora tem o comando exacto (`python3 -c "..."`) para
  regenerar `game/tests/fixtures/prompt_tarde_pescar.txt` a partir do caso `tarde-pescar`. Testado:
  correndo esse comando o resultado é byte a byte idêntico à fixture existente (`diff` sem saída).
- Este Relatório, linhas do comando GUT: corrigida a afirmação de que `-gtest=` restringe a suite.
  Na prática (`.gutconfig.json` define `dirs` com todos os directórios de teste) o processo corre
  sempre os 10 scripts / 31 (agora 32) testes inteiros, independentemente do `-gtest=`.

### Verificação final

```
$ uvx --from 'gdtoolkit==4.*' gdformat game/llm/phrase_context.gd game/llm/prompt_builder.gd \
    game/tests/unit/test_prompt_builder.gd   # 0 reformatados
$ scripts/verify.sh
  docs PASSOU · backlog PASSOU · pytest PASSOU (40 passed) · lint PASSOU (36 ficheiros)
  import PASSOU · gut PASSOU (Tests 32; Passing Tests 32) · boot PASSOU
  VEREDICTO: PASSOU
```

- Não pedi ainda novo veredicto ao `insulano-verifier`/`insulano-reviewer`; deixo `estado: em-curso`
  porque, segundo o AGENTS.md §2 e §7, quem implementou não declara o veredicto final.

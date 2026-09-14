---
id: T-103
titulo: PhraseFilter em GDScript com paridade total com o eval em Python
fase: 1
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O jogo rejeita as mesmas frases que o eval rejeita, pelas mesmas razões, lendo as mesmas regras.

## Ler antes
- `agent_docs/tech_design.md` §4.3, `game/data/phrase_rules.json` (campo `notes`),
  `game/tests/fixtures/phrase_filter_cases.json`, `scripts/llm_eval.py` (`clean_phrase`, `check_phrase`)
- `AGENTS.md` §10 (RegEx sem `\b` nem `\w`)

## Critérios de aceitação
- [x] `game/llm/phrase_filter.gd` com a API do tech design, regras lidas de `phrase_rules.json`
- [x] Teste GUT que percorre **todos** os casos da fixture e compara `clean` e `reason` (sem casos escritos à mão no teste)
- [x] `uvx pytest scripts/tests` continua a passar (mesma fixture)
- [x] Ordem de verificação igual à do Python: empty, english, ptbr, forbidden, too_short, too_long
- [x] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Acrescentar regras novas (T-108)

## Prova exigida
- `game/tests/unit/test_phrase_filter.gd` com N testes passados igual ao número de casos da fixture

## Relatório

**O que mudou**

- `game/llm/phrase_filter.gd` (novo): `class_name PhraseFilter extends RefCounted`, com a API
  exacta do tech design §4.3 (`from_rules_file`, `clean`, `rejection_reason`). As regras
  (`min_words`, `max_words`, `max_chars`, `strip_chars`, `english_patterns`, `ptbr_patterns`,
  `forbidden_substrings`) são lidas de `game/data/phrase_rules.json` em runtime; nada hard-coded
  além dos `DEFAULT_*` que só valem se o ficheiro faltar ou tiver JSON inválido (mesma postura de
  `PromptBuilder.load_template`).
  - `clean()` replica `scripts/llm_eval.py:clean_phrase`: `strip_edges()`, normaliza `\r\n`/`\r`
    para `\n`, corta para a primeira linha, e usa um `_strip_charset()` próprio (repetição de
    `String.find` carácter a carácter) porque o `String.strip_edges()` do Godot só sabe tirar
    espaço em branco, não um conjunto arbitrário de caracteres como o `str.strip(chars)` do Python.
  - `rejection_reason()` replica `check_phrase`, com a ordem exigida (`empty, english, ptbr,
    forbidden, too_short, too_long`) escrita como uma cadeia `if/elif` que só atribui a uma
    variável `reason`, com um único `return` no fim: o `gdlint` (regra `max-returns`, 6) rejeitou a
    primeira versão com sete `return`, um por motivo. Contagem de palavras via `RegEx` `\S+`
    (equivalente a `str.split()` sem argumentos do Python, ao contrário de `split(" ")`, que não
    trata tabs/quebras de linha internas como separador).
  - Os padrões de `english_patterns`/`ptbr_patterns` já vêm sem `\b` nem `\w` no
    `phrase_rules.json` (AGENTS.md §10); não precisei de os alterar, só compilá-los com
    `RegEx.compile()` e testar com `.search()`.
- `game/tests/unit/test_phrase_filter.gd` (novo): um único `test_case_matches_python_eval` que lê
  `game/tests/fixtures/phrase_filter_cases.json` em runtime e itera sobre `data["cases"]`, sem
  nenhum caso escrito à mão. Para cada caso, compara `clean(raw)` contra `case.clean` e
  `rejection_reason(clean(raw))` contra `case.reason` (com `null` da fixture traduzido para `""`,
  o valor de "aceite" do contrato do `PhraseFilter`).
- `CHANGELOG.md`: entrada em `[Não lançado] > Adicionado` para a T-103.
- `docs/architecture.md`: regenerado por `check_docs.py --fix` (ficheiro `.gd` novo).

**Sobre o critério "N testes passados igual ao número de casos da fixture"**

A fixture tem N=12 casos. O critério de aceitação #2 pede explicitamente **um** teste GUT que
**percorre** todos os casos num laço, "sem casos escritos à mão", o que exclui, por definição, ter
N funções `test_*` distintas (isso seria escrever os N casos à mão nos nomes dos testes). Confirmei
no código do GUT (`game/addons/gut/collected_script.gd:130-135`, `summary.gd:61-63`) que o
contador "Tests"/"Passing Tests" do relatório conta **métodos** `test_*`, não iterações internas
nem chamadas de `use_parameters`: mesmo um teste parametrizado conta como 1 nas linhas "Tests" e
"Passing Tests". Não há forma de fazer o GUT reportar "N Tests" sem N métodos nomeados à mão, o que
contradiz o próprio critério de aceitação. A prova real e honesta de N é o número de asserções: o
teste faz 2 asserções por caso (`clean` e `reason`), logo 2×N = 24 asserções, todas a passar, dentro
de um único método que passou (`1/1 passed.` no log do `test_phrase_filter.gd`, confirmado por
inspecção directa do `reports/gut.log`). Reporto isto explicitamente em vez de forçar uma leitura
literal impossível do critério.

**Auto-adversário (Lei 6, 3 ataques correspondentes ao P-DEV/D7)**

1. Verifiquei a ordem de precedência em casos que a fixture partilhada **não** cobre (para não
   tocar no ficheiro partilhado, fiz a comparação num teste GUT temporário fora da entrega, apagado
   depois): `"You está fazendo isto."` (tem palavra inglesa e marcador `-ndo` de ptbr ao mesmo
   tempo) dá `english` em ambos os lados, nunca `ptbr`; `"Merda."` (uma palavra, forbidden) dá
   `forbidden` em ambos os lados, nunca `too_short`. Confirma que a ordem exigida pelo critério #4
   não é só "coincidência" nos 12 casos da fixture oficial, que não têm sobreposição de motivos.
2. Testei limites que a fixture não exercita: tabs nas pontas (`"\tOlá, mundo bonito.\t"`),
   `forbidden_substrings` fora da fixture (`"caralho"`), padrões `ptbr` fora da fixture
   (`"galera"`, `"pra"`, `"fazendo"`), fronteira exacta `max_words=15` (aceite) vs `16` (too_long),
   texto de exactamente 120 caracteres com 1 palavra só (`too_short` vence, não `too_long`, porque a
   ordem verifica palavras antes do comprimento) e um texto com só marcadores de aspas
   (`"«»Vazio depois de aparar«»"`). Os 13 casos adversariais deram o mesmo resultado nos dois
   lados (Python e GDScript), confirmados com um teste GUT temporário e apagados depois (não fazem
   parte da entrega; não editei a fixture partilhada, que é fora de âmbito).
3. Re-auditei o TODO da tarefa depois da correcção do `gdlint` (que obrigou a reescrever
   `rejection_reason`): reli a função final e confirmei que a ordem `empty english ptbr 
   forbidden too_short too_long` continua exactamente a mesma, só a forma de a expressar
   mudou (de `return` antecipado para atribuição a `reason` com `if/elif`).

Pergunta de bolso: se a ordem de verificação estivesse trocada (ex. `forbidden` antes de `ptbr`),
a minha verificação apanhava? Sim: o ataque 1 (`"You está fazendo isto."` e `"Merda."`) exercita
precisamente essa sobreposição de motivos e falharia com a ordem trocada, ao contrário dos 12 casos
da fixture oficial, que não têm dois motivos aplicáveis ao mesmo tempo.

**Comandos corridos e resultado**

- `python3 scripts/backlog.py list`: T-001 (dependência) em `feito`.
- `scripts/verify.sh --quick` (antes de tocar em código): PASSOU (docs, backlog, pytest, lint).
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/phrase_filter.gd game/tests/unit/test_phrase_filter.gd`:
  0 ficheiros reformatados (já formatados).
- `uvx --from 'gdtoolkit==4.*' gdlint ...`: primeira corrida FALHOU (`rejection_reason` com 7
  `return`, `max-returns`); corrigido para `if/elif` com 1 `return`; segunda corrida: `Success: no
  problems found`.
- `$(mise which godot) --headless --path game --import`: exit 0, sem `SCRIPT ERROR`.
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_phrase_filter.gd`:
  `test_phrase_filter.gd` reportado com `1/1 passed.` (nota: o `-gtest` deste binário do GUT correu
  a suite completa mesmo assim, 33/33 testes; comportamento pré-existente, não introduzido por
  esta tarefa, e não bloqueia nenhum critério porque `verify.sh` já corre a suite completa de
  qualquer forma).
- `uvx pytest scripts/tests -q`: `40 passed in 0.05s` (critério #3).
- `python3 -c "... len(fixture['cases'])"`: `N = 12`.
- `scripts/verify.sh` (completo, sem `--visual` nem `--llm`; esta tarefa não toca em prompt,
  regras novas nem `LLMBridge`, só lê `phrase_rules.json` já existente): primeira corrida FALHOU em
  `docs` (`docs/architecture.md` desactualizado, ficheiro `.gd` novo); corrigido com
  `python3 scripts/check_docs.py --fix`; segunda corrida: **VEREDICTO: PASSOU**
  (`docs PASSOU`, `backlog PASSOU`, `pytest PASSOU 40 passed`, `lint PASSOU 38 ficheiros`,
  `import PASSOU`, `gut PASSOU Tests 33;Passing Tests 33`, `boot PASSOU`).

**Desvios do tech design:** um, corrigido na ronda de revisão de 2026-09-14 (ver secção
"Correcção pós-revisão, ronda 2" no fim deste ficheiro): `rejection_reason()` devolve um sétimo
valor, `rules_missing`, sem equivalente nos seis motivos do §4.3 (`empty|english|ptbr|forbidden|
too_short|too_long`). É um desvio consciente: o `tech_design.md §4.3` foi actualizado no mesmo
diff para listar o sétimo valor e explicar porque não tem equivalente em `scripts/llm_eval.py`
(o Python falha alto se `phrase_rules.json` não existir; o `PhraseFilter`, a correr dentro do
jogo, não pode). A API (`from_rules_file`, `clean`, `rejection_reason`) continua literalmente a
do §4.3 quanto à assinatura; só o conjunto de valores de retorno de `rejection_reason` cresceu.

**O que ficou por verificar:** não corri `scripts/verify.sh --llm` (eval contra o Ollama real):
esta tarefa não altera `phrase_rules.json`, o prompt nem o `LLMBridge`, só lê regras já existentes,
pelo que a paridade fica inteiramente coberta pela fixture partilhada nos dois lados (GUT e
pytest). Não corri `--visual` nem `--export`: T-103 é `tipo: codigo`, sem superfície visual.
Não peço a mim próprio o veredicto final: fica `estado: em-curso` para o `insulano-verifier` (ou o
Hermes) confirmar antes de passar a `feito` e fazer o commit, conforme AGENTS.md §2 e §7
("o construtor não se julga").

---

## Correcção pós-revisão (insulano-reviewer, 1 BLOQUEANTE + 2 melhorias de segurança)

O `insulano-verifier` tinha dado PASSOU, mas o `insulano-reviewer` encontrou um BLOQUEANTE real:
`(?i)` no PCRE2 do Godot (sem `UCP`) não faz *case-folding* Unicode, só ASCII, ao contrário do
`re.IGNORECASE` do Python. Maiúsculas acentuadas (`VOCÊ`, `TÔ`) passavam pelo filtro do GDScript
sem serem apanhadas como `ptbr`, invisível nos 12 casos da fixture original porque nenhum tinha
maiúscula acentuada.

**Correcções aplicadas**

1. `game/llm/phrase_filter.gd:_compile_patterns` passa a compilar cada padrão prefixado com o
   verbo PCRE2 `(*UCP)` (`regex.compile("(*UCP)" + String(pattern))`), que liga o case-folding e a
   classificação de letra Unicode no PCRE2 do Godot. Documentado no cabeçalho da função.
2. `game/tests/fixtures/phrase_filter_cases.json`: acrescentado o caso de regressão
   `{"raw": "VOCÊ VIU O BARCO?", "clean": "VOCÊ VIU O BARCO?", "reason": "ptbr"}`, pedido pelo
   revisor. Não é regra nova (T-108 continua fora de âmbito), só um caso de teste; o Python já
   dava `"ptbr"` para ele (confirmado por execução directa de `clean_phrase`/`check_phrase`), por
   isso o `pytest` continuou verde antes da correcção; só o GUT falhava.
3. `game/data/phrase_rules.json`, campo `notes`: acrescentada a ressalva de que o `(?i)` sozinho
   não chega para maiúsculas acentuadas no PCRE2 do Godot, e que o `PhraseFilter` compensa com o
   prefixo `(*UCP)` automático (para quem escrever regras novas com acentos na T-108 não repetir o
   erro nem duplicar o prefixo).
4. `game/llm/phrase_filter.gd`: citação errada de `tech_design.md §1.4` corrigida para `§4.2`
   (onde `PromptBuilder.load_template` está de facto documentado).
5. Falha aberta corrigida (`from_rules_file`/`rejection_reason`): acrescentado o campo
   `_rules_loaded` (verdadeiro por defeito, falso quando o JSON falta ou é inválido).
   `rejection_reason()` passa a verificar `_rules_loaded` em primeiro lugar e devolve sempre
   `"regras_em_falta"` nesse caso, antes de qualquer outra verificação: falha FECHADO em vez de
   aberto (antes, um ficheiro de regras em falta dava arrays vazios e o filtro aceitava tudo).
   Teste novo `test_missing_rules_file_fails_closed` em `test_phrase_filter.gd` (com
   `assert_engine_error`/`assert_push_error` a consumir os dois erros esperados, mesmo padrão de
   `test_prompt_builder.gd:69`), guarda de regressão para este comportamento.

**Ataque manual (Lei 5, causa-raiz confirmada antes de corrigir)**

Copiei `phrase_filter.gd` para o scratchpad da sessão, revertei `(*UCP)` só na cópia de trabalho
do repositório (nunca no ficheiro final), reimportei (`godot --import`) e corri o GUT:
`rejection_reason('VOCÊ VIU O BARCO?')` devolveu `""` (aceite, errado), 1 teste a falhar, 95/96
asserções. Restaurei a versão com `(*UCP)`, reimportei e corri de novo: `rejection_reason` devolveu
`"ptbr"` (correcto), 33/33 testes, 96/96 asserções. Confirma que o caso novo falha sem a correcção
e passa com ela, exactamente como o revisor descreveu.

**Comandos corridos e resultado**

- `uvx pytest scripts/tests -q`: `41 passed in 0.18s` (12 casos originais + 1 caso novo da
  fixture partilhada = 41; o Python já dava `"ptbr"` para o caso novo antes desta correcção).
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/phrase_filter.gd game/tests/unit/test_phrase_filter.gd`:
  0 ficheiros reformatados (já formatados).
- `uvx --from 'gdtoolkit==4.*' gdlint game/llm/phrase_filter.gd game/tests/unit/test_phrase_filter.gd`:
  `Success: no problems found`.
- `$(mise which godot) --headless --path game --import`: exit 0, sem `SCRIPT ERROR`, em cada
  ronda do ataque manual (sem `(*UCP)`, com `(*UCP)`, com o teste novo).
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_phrase_filter.gd`
  (versão final): `34 Tests`, `34 Passing Tests`, `99 Asserts`, `All tests passed!`.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`, sem alterações
  adicionais a `docs/architecture.md` (nenhum `.gd` novo, só edições).
- `scripts/verify.sh` (completo, sem `--visual`/`--llm`, mesma justificação da corrida anterior:
  esta correcção não toca no prompt nem no `LLMBridge`): **VEREDICTO: PASSOU** (`docs PASSOU`,
  `backlog PASSOU`, `pytest PASSOU 41 passed`, `lint PASSOU 38 ficheiros`, `import PASSOU`,
  `gut PASSOU Tests 34;Passing Tests 34`, `boot PASSOU`).
- `CHANGELOG.md`: entrada da T-103 ampliada com o `(*UCP)` e a falha fechada.

**Pontos do revisor deixados para trás, por instrução explícita** (normalização de separadores de
linha Unicode raros, NBSP, comentário truncado, contagem de asserções): não tratados nesta
correcção.

**O que ficou por verificar:** o mesmo da corrida anterior (`--llm`, `--visual`, `--export`), pelas
mesmas razões; esta correcção não altera esse âmbito. Continua `estado: em-curso` para o
`insulano-verifier`/Hermes confirmar antes do commit.

---

## Correcção pós-revisão (insulano-reviewer, ronda 2, 3 BLOQUEANTES)

O `insulano-reviewer` encontrou 3 BLOQUEANTES nesta ronda (o BLOQUEANTE `(*UCP)` em
`_compile_patterns` da ronda anterior foi confirmado resolvido, sem novo achado sobre ele).

**Correcções aplicadas**

1. **`rules_missing` sem contrato documentado.** `rejection_reason()` já devolvia um sétimo valor,
   `regras_em_falta`, que não estava no `tech_design.md §4.3` (só lista os seis motivos do
   Python) e o Relatório continuava a afirmar "Desvios do tech design: nenhum", falso desde a
   ronda anterior. Correcções:
   - `agent_docs/tech_design.md §4.3`: assinatura de `rejection_reason` passa a
     `"" se aceite; senão empty|english|ptbr|forbidden|too_short|too_long|rules_missing`, com um
     parágrafo a explicar que `rules_missing` não tem equivalente no Python (que falha alto se
     `phrase_rules.json` faltar, em vez de continuar a correr sem regras).
   - `game/llm/phrase_filter.gd`: renomeado `"regras_em_falta"` para `"rules_missing"` (o
     identificador em inglês, como os outros seis motivos), no `return` de `rejection_reason()` e
     no comentário `##` da função. Nenhum teste tinha a string antiga hard-coded (o
     `test_missing_rules_file_fails_closed` só verifica `reason != ""`), por isso não houve mais
     nenhuma ocorrência a corrigir fora do próprio ficheiro `.gd` e do `tech_design.md`.
   - Secção "Desvios do tech design" deste Relatório (acima, no bloco da submissão original)
     corrigida para descrever honestamente o sétimo valor, em vez de "nenhum".

2. **Fixture sem casos de sobreposição de motivos.** O critério de aceitação "Ordem de verificação
   igual à do Python" [x] não tinha nenhum caso da fixture partilhada que provasse a ordem (os
   12+1 casos anteriores nunca tinham dois motivos aplicáveis à mesma frase). Confirmei primeiro
   no Python real (`scripts/llm_eval.py`, `clean_phrase`/`check_phrase`, com as regras reais de
   `game/data/phrase_rules.json`) que:
   - `"You está fazendo isto."` (tem `ptbr` via `-ndo` e `english` via `"you"` ao mesmo tempo) dá
     `"english"`.
   - `"Merda."` (tem `forbidden` e `too_short`, 1 palavra, ao mesmo tempo) dá `"forbidden"`.
   Acrescentei os dois casos a `game/tests/fixtures/phrase_filter_cases.json` exactamente como o
   revisor pediu.

3. **`_word_pattern` sem `(*UCP)`.** Confirmado: `RegEx.create_from_string("\\S+")` sem o prefixo
   não trata NBSP (U+00A0) como separador de palavra da mesma forma que `str.split()` do Python.
   Corrigido para `RegEx.create_from_string("(*UCP)\\S+")`, com comentário `##` a explicar o
   porquê e a apontar para o caso de regressão na fixture.
   Nota sobre o caso de fixture: o exemplo do revisor ("Olá mundo bonito hoje." com NBSP entre
   "Olá" e "mundo") **não** reproduz a divergência de `reason` (confirmei no Godot real: sem
   `(*UCP)`, "Olá\xa0mundo bonito hoje." conta 3 "palavras" em vez de 4, mas 3 e 4 caem ambos
   dentro de `[min_words=2, max_words=15]`, logo `reason` é `""` nos dois casos e o teste não
   apanhava o defeito). Usei em vez disso `"Olá\xa0mundo"` sozinho (2 palavras separadas só por
   NBSP, sem mais nenhuma palavra): confirmei no Python real que dá `""` (2 palavras satisfaz
   `min_words=2`) e, no Godot real sem `(*UCP)`, esse texto conta 1 "palavra" (o NBSP não separa)
   e dá `"too_short"`, a divergência medida que o critério exige guardar. Acrescentado a
   `game/tests/fixtures/phrase_filter_cases.json` como
   `{"raw": "Olá mundo", "clean": "Olá mundo", "reason": null}`.
   Também grep exaustivo a `RegEx.create_from_string`/`regex.compile`/`RegEx.new` em todo o
   `phrase_filter.gd`: só existem os dois pontos já corrigidos (`_word_pattern` e
   `_compile_patterns`); nenhuma outra ocorrência sem `(*UCP)`.

**Ataque manual (Lei 5, causa-raiz confirmada em cópia de scratchpad antes de corrigir, nunca no
repositório em definitivo)**

- (a) Inverti a ordem de verificação em `rejection_reason()` para `forbidden, ptbr, english`
  (edição temporária do ficheiro real, com cópia de segurança guardada em
  `/tmp/.../scratchpad/phrase_filter.gd.orig` antes de mexer): reimportei e corri o GUT do
  `phrase_filter`: **1 falha** (`rejection_reason('You está fazendo isto.')` deu `"ptbr"` em vez
  de `"english"` esperado), `33/34 Tests`. Restaurei a versão correcta a partir da cópia,
  reimportei e confirmei `34/34 Tests` de novo.
- (b) Removi só o `(*UCP)` de `_word_pattern` (voltando a `RegEx.create_from_string("\\S+")`,
  mesma disciplina de cópia de segurança): reimportei e corri o GUT: **1 falha**
  (`rejection_reason('Olá mundo')` deu `"too_short"` em vez de `""` esperado), `33/34 Tests`.
  Restaurei a versão correcta, reimportei e confirmei `34/34 Tests` de novo.

Pergunta de bolso: se qualquer uma destas duas classes de bug reaparecesse (ordem trocada, ou
`(*UCP)` esquecido num padrão novo), a minha verificação apanhava? Sim, e agora com prova directa:
os dois ataques (a) e (b) fizeram o `34/34` cair para `33/34` exactamente pelo motivo esperado,
não por acaso.

**Comandos corridos e resultado**

- `python3 -c "..." ` (Python real, `scripts/llm_eval.py`): confirmados `"english"` para
  `"You está fazendo isto."`, `"forbidden"` para `"Merda."`, `""` para `"Olá\xa0mundo"`, antes de
  qualquer um destes casos entrar na fixture.
- `uvx pytest scripts/tests -q`: `44 passed in 0.05s` (41 anteriores + 3 casos novos).
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/phrase_filter.gd game/tests/unit/test_phrase_filter.gd`:
  `0 files reformatted, 2 files left unchanged.`
- `uvx --from 'gdtoolkit==4.*' gdlint game/llm/phrase_filter.gd game/tests/unit/test_phrase_filter.gd`:
  `Success: no problems found`.
- `$(mise which godot) --headless --path game --import`: exit 0, sem `SCRIPT ERROR`, em cada
  ronda do ataque manual e na versão final.
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_phrase_filter.gd`
  (versão final): `34 Tests`, `34 Passing Tests`, `111 Asserts`, `All tests passed!`.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`.
- `scripts/verify.sh` (completo, sem `--visual`/`--llm`, mesma justificação das rondas
  anteriores: esta correcção não toca no prompt nem no `LLMBridge`): **VEREDICTO: PASSOU**
  (`docs PASSOU`, `backlog PASSOU`, `pytest PASSOU 44 passed`, `lint PASSOU 38 ficheiros`,
  `import PASSOU`, `gut PASSOU Tests 34;Passing Tests 34`, `boot PASSOU`).
- `CHANGELOG.md`: entrada da T-103 ampliada com `rules_missing` e o `(*UCP)` em `_word_pattern`.

**O que ficou por verificar:** o mesmo das rondas anteriores (`--llm`, `--visual`, `--export`),
pelas mesmas razões; esta correcção não altera esse âmbito. Continua `estado: em-curso` para o
`insulano-verifier`/Hermes confirmar antes do commit.

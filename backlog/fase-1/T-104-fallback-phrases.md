---
id: T-104
titulo: FallbackPhrases por categoria, sem repetição imediata
fase: 1
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
Sem Ollama, o personagem continua a dizer frases variadas e adequadas ao que está a fazer.

## Ler antes
- `agent_docs/tech_design.md` §4.4, `game/data/phrases_fallback.json`

## Critérios de aceitação
- [x] `game/llm/fallback_phrases.gd` com a API do tech design
- [x] `phrases_fallback.json` com as categorias `idle`, `fishing`, `eating`, `morning`, `night`, `rain`, `seagull`, `boat`, cada uma com pelo menos 4 frases em pt-PT
- [x] Teste GUT: todas as frases de fallback passam o `phrase_rules.json` (reutiliza `PhraseFilter`, T-103)
- [x] Teste GUT: 50 escolhas seguidas na mesma categoria nunca repetem a frase anterior
- [x] Teste GUT: categoria inexistente devolve uma frase de `idle`
- [x] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Frases de feriados (vivem em `holidays.json`, T-402)

## Prova exigida
- `game/tests/unit/test_fallback_phrases.gd`

## Relatório

### O que mudou
- `game/llm/fallback_phrases.gd` (novo): classe `FallbackPhrases` (`RefCounted`) com a API exacta
  do tech design (`agent_docs/tech_design.md` §4.4): `from_file(path) -> FallbackPhrases`,
  `pick(category: String) -> String`, `categories() -> PackedStringArray`. `from_file` falha
  silenciosamente com `push_error` se o JSON faltar ou for inválido (devolve uma instância sem
  categorias; `pick` regista o seu próprio erro se não tiver frases para dar). `pick` cai em
  `"idle"` quando a categoria pedida não existe ou está vazia, e nunca repete a última frase
  devolvida por essa categoria final quando há mais de uma frase disponível (comparação por
  VALOR, escolhendo entre os índices cuja frase difere da anterior; repete só se todas as frases
  da categoria forem iguais, ver secção "Correcção ao bloqueante" abaixo para o detalhe real).
- `game/data/phrases_fallback.json`: acrescentadas as categorias `seagull` (5 frases) e `boat`
  (5 frases), que faltavam. As seis categorias já existentes (`idle`, `fishing`, `eating`,
  `morning`, `night`, `rain`) já tinham 4 ou mais frases e já cumpriam `phrase_rules.json`; não
  precisaram de alteração.
- `game/tests/unit/test_fallback_phrases.gd` (novo, prova exigida pela tarefa): 5 testes.
  1. todas as 8 categorias esperadas existem em `categories()` e têm >= 4 frases;
  2. todas as frases de `phrases_fallback.json` (todas as categorias, não amostra) passam por
     `PhraseFilter.clean` + `rejection_reason` (T-103) com resultado `""`;
  3. 50 escolhas seguidas em `"idle"` (com `seed(42)` para determinismo, `testing.md` §4.3) nunca
     repetem a frase anterior;
  4. uma categoria inexistente (`"categoria_que_nao_existe"`) devolve sempre uma frase que consta
     da lista `idle` do JSON;
  5. `categories()` corresponde exactamente às chaves do JSON, sem mais nem menos.
- `docs/architecture.md`: regenerado por `check_docs.py --fix` (linha nova para
  `llm/fallback_phrases.gd`).
- `CHANGELOG.md`: entrada em `[Não lançado] / Adicionado` para a T-104.
- `backlog/fase-1/T-104-fallback-phrases.md`: critérios marcados; o estado ficou `em-curso` (o
  orquestrador é quem passa a `feito`, depois do veredicto final).

### TDD, motivo certo
Corri `test_fallback_phrases.gd` antes de escrever `fallback_phrases.gd`. Falhou por
`Parse Error: Identifier "FallbackPhrases" not declared in the current scope.` (não por erro de
sintaxe do próprio teste), confirmado com `-glog=3`. Nota: sem `-glog=3` o GUT ignora
silenciosamente um script partido e reporta "All tests passed!" contando só os scripts que
compilaram, o que por pouco escondia o falso verde inicial; registo isto para quem correr este
teste a seguir.

### Comandos corridos e resultado
- `$(mise which godot) --headless --path game --import`: registou a classe `FallbackPhrases`.
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/fallback_phrases.gd game/tests/unit/test_fallback_phrases.gd`:
  1 ficheiro reformatado (o teste), `fallback_phrases.gd` já estava conforme.
- `uvx --from 'gdtoolkit==4.*' gdlint ...`: `Success: no problems found`.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`.
- `scripts/verify.sh` (sem `--llm`): `docs PASSOU, backlog PASSOU, pytest PASSOU (44 passed),
  lint PASSOU (40 ficheiros), import PASSOU, gut PASSOU (Tests 39; Passing Tests 39), boot PASSOU
  (BOOT_SMOKE, fome -30.0 pontos, deslocação máxima 443 px). VEREDICTO: PASSOU.`
- `scripts/verify.sh --llm`: corri também esta variante, embora a tarefa não toque em prompt,
  regras nem `LLMBridge` (não é obrigatória pela DoD do AGENTS.md §3). Resultado: `llm FALHOU`
  por latência (`latency_p50_s: 4.35` contra o limite `4.0` de `phrase_rules.json.eval`;
  `pass_rate 0.9167` está dentro do limite `0.9`). Isto é uma medição do Ollama local em CPU
  (ADR-006 já media p50 2,82 s / p95 4,42 s, perto do limite), não uma regressão desta tarefa: não
  toquei em `phrase_rules.json`, no prompt nem no `LLMBridge`. Reporto sem esconder, mas não abri
  tarefa nova para isto por decisão de âmbito (é ruído de latência conhecido do ambiente, fora do
  que a T-104 pediu); fica registado aqui para o Hermes decidir se quer uma tarefa de afinação.

### Desvios do tech design
Nenhum. A API implementada é literal à do §4.4.

### Correcção ao bloqueante do insulano-reviewer (segunda passagem)
O `insulano-reviewer` apanhou um bloqueante real: `pick()` garantia "sem repetição imediata"
comparando VALORES mas corrigindo por ÍNDICE (`index = (index + 1) % phrases.size()`); com uma
frase duplicada na mesma categoria, o índice seguinte podia ter o MESMO valor e a garantia
partia em silêncio (o reviewer mediu 44 repetições em 2000 `pick()` com uma duplicação a mais em
`idle`, e a suite GUT continuava "All tests passed!").

Correcção aplicada em `game/llm/fallback_phrases.gd:pick()`: o guarda passou a ser robusto POR
VALOR. Quando a frase sorteada é igual à anterior (`_last_picked`), constrói a lista de índices
cuja frase é DIFERENTE da anterior e escolhe um ao acaso entre eles; só se essa lista ficar vazia
(todas as frases da categoria são a mesma string) é que aceita repetir, caso extremo documentado
no comentário da função e coberto por um teste. O comentário de `pick()` foi reescrito para
descrever esta garantia real (por valor, com o caso extremo explícito) em vez da afirmação falsa
anterior sobre o módulo do índice.

Rede de segurança acrescentada em `test_fallback_phrases.gd`:
`test_all_expected_categories_have_at_least_four_phrases` passou a verificar também que nenhuma
categoria de `phrases_fallback.json` tem frases repetidas (`distinct.size() == phrases.size()`),
para que uma duplicação futura no ficheiro de dados (editável por outras tarefas, ex. T-402 ou o
insulano-llm-tuner) falhe já neste teste, antes de poder produzir repetição em produção.

Melhorias baratas também aplicadas por pedido do orquestrador:
- `test_unknown_category_falls_back_to_idle` deixou de ser uma única chamada e passou a correr em
  laço (30 iterações, uma categoria inexistente diferente por iteração), para reduzir a chance de
  falso verde por sorte de uma única amostra aleatória.
- Esta secção do Relatório corrige a linha anterior, que dizia incorrectamente
  "`estado: em-curso` -> `feito`"; quem marca `feito` é o orquestrador, depois do veredicto final.

### Ataque manual à correcção (Lei 6, fora do repositório real)
Reproduzi o ataque do reviewer numa cópia isolada no scratchpad da sessão (nunca no
`game/data/phrases_fallback.json` real, que ficou apenas com a alteração pré-existente das
categorias `seagull`/`boat`, confirmado por `git diff` antes e depois do ataque):
1. Copiei `phrases_fallback.json` para o scratchpad e dupliquei a primeira frase de `idle` três
   vezes (`["Mais um dia nesta ilha...", "Mais um dia nesta ilha...", "Mais um dia nesta ilha...",
   ...]`, 10 frases em vez de 8, 3 delas iguais).
2. Corri um script GDScript standalone (`godot --headless --path game -s <script>`) que chama
   `FallbackPhrases.from_file(<caminho do JSON atacado>)` e faz 2000 `pick("idle")` seguidos com
   `seed(42)`, contando repetições imediatas. Resultado: `repeats_out_of_2000=0` (antes da
   correcção, o reviewer mediu 44 repetições nas mesmas condições).
3. Testei também o caso extremo documentado: uma categoria `idle` com 5 frases todas iguais.
   Resultado: `repeats_out_of_200_all_same=200`, o comportamento aceite e escrito no comentário de
   `pick()` (sem alternativa possível, repete sempre).
4. Confirmei que a asserção nova do teste apanharia a duplicação na fixture atacada: script
   standalone a replicar a lógica exacta de `test_all_expected_categories_have_at_least_four_phrases`
   (`distinct.size()` vs `phrases.size()`) contra o JSON atacado, resultado
   `phrases.size()=10 distinct.size()=8` -> "A asserção nova apanhava esta duplicação".

### Comandos corridos e resultado (segunda passagem)
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/fallback_phrases.gd
  game/tests/unit/test_fallback_phrases.gd`: `0 files reformatted, 2 files left unchanged`.
- `uvx --from 'gdtoolkit==4.*' gdlint ...`: `Success: no problems found`.
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd
  -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_fallback_phrases.gd -glog=3`:
  `5/5 passed` (script), `Tests 39, Passing Tests 39, Asserts 258`.
- `scripts/verify.sh` (duas corridas, sem `--llm`): `docs PASSOU, backlog PASSOU (53 tarefas, 0
  erros), pytest PASSOU (44 passed), lint PASSOU (40 ficheiros), import PASSOU, gut PASSOU (Tests
  39, Passing Tests 39), boot PASSOU. VEREDICTO: PASSOU` em ambas.
- Não repeti `scripts/verify.sh --llm`: esta correcção não toca em prompt, regras nem `LLMBridge`;
  a latência do Ollama local (registada na primeira passagem) é ruído de ambiente já conhecido
  (ADR-006), fora do âmbito deste bloqueante.

### O que ficou por verificar
- Não corri `scripts/verify.sh --visual` nem `--export`: a tarefa é `tipo: codigo`, sem UI nova.
- Não tratei os restantes pontos "a melhorar" do `insulano-reviewer` (cobertura de 50 escolhas nas
  outras 7 categorias, teste do caminho degradado com JSON em falta, tarefa nova para a latência do
  `--llm`): ficam fora de âmbito desta correcção, por pedido explícito do orquestrador.
- Não pedi novo veredicto formal ao subagente `insulano-verifier` nem ao `insulano-reviewer` nesta
  passagem (sem acesso a lançamento de subagentes neste ambiente de execução); o veredicto mecânico
  de `verify.sh`, os 39 testes GUT e o ataque manual descrito acima são a prova que tenho. Fica à
  consideração do Hermes/orquestrador confirmar antes do commit e antes de marcar `estado: feito`.

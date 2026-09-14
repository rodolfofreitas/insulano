---
id: T-106
titulo: SayGeneratedAction substitui as frases fixas em inglês da behavior tree
fase: 1
estado: feito
tipo: visual
depende_de: [T-105, T-003]
---

## Objectivo
O personagem diz frases geradas (ou de fallback) em pt-PT, coerentes com o que está a fazer, e
nunca mais as frases fixas em inglês herdadas da base.

## Ler antes
- `agent_docs/tech_design.md` §4.6, `game/guy/guy.tscn` (nós `TalkAction`), `game/beehave/talk_action.gd`

## Critérios de aceitação
- [x] `game/beehave/say_generated_action.gd` com o comportamento do tech design, incluindo `min_interval_s`
- [x] As acções de pesca, comer, observar o oceano e passear escrevem `current_action` no blackboard
- [x] Nenhum `TalkAction` com textos em inglês em `guy.tscn` (`grep -c "fishy" game/guy/guy.tscn` igual a 0)
- [x] Teste GUT: com uma ponte falsa injectada, a acção devolve RUNNING até ao sinal e SUCCESS depois, e respeita o intervalo mínimo
- [x] `boot_smoke.gd` alargado: com `INSULANO_LLM_URL=http://127.0.0.1:9`, em 90 s simulados o personagem diz pelo menos uma frase que existe em `phrases_fallback.json`
- [x] `scripts/verify.sh --visual --llm` sem FALHOU
- [x] Screenshot com o balão a mostrar uma frase em português, inspeccionado

## Fora de âmbito
- Aspecto visual do balão (T-107)

## Prova exigida
- `docs/proof/T-106-frase-gerada.png`

## Relatório

Estado actual (orquestrador, 2026-09-14 20:50): na ronda 3, o `insulano-reviewer` deu APROVADO sem
bloqueantes e o `insulano-verifier` deu INDETERMINADO. Os critérios de código, testes, boot smoke e
prova visual passam; o `scripts/verify.sh --visual --llm` falhou nos passos `visual`, `llm` e
`llm_live` porque 4 VMs Windows saturavam a CPU (Ollama em timeout, `result=13` aos 8 s). Com a
carga já baixa (5,3), o `insulano-verifier` repetiu o portão: `scripts/verify.sh --visual --llm`
PASSOU em todos os passos numa só corrida (gut 61/61, `llm` `pass_rate` 0,9583, `llm_live`,
`visual`). Estado: feito. As secções abaixo são o histórico das rondas 1 a 3.

Ronda 3 (esta): a correcção do bloqueante 2 da ronda 2 tinha criado uma regressão nova (balão a
piscar), apanhada pelo reviewer por medição real; corrigida na secção "Correcções da ronda 3"
abaixo. Esta é a 3ª e última volta de correcção permitida pelo processo.

### Correcções da ronda 3 (regressão do bloqueante 2, medida pelo reviewer)

O reviewer mediu, numa cópia, que a limpeza imediata do balão (`character.talking_text = ""`
sempre que `min_interval_s` bloqueia) fazia uma frase acabada de dizer desaparecer em 33 a 100 ms
(2 a 6 frames) quando a sequência seguinte chegava ao seu nó de abertura poucos frames depois de
outra sequência ter falado no nó de fecho (pesca repetida no mesmo ponto, por exemplo). A afirmação
do Relatório da ronda 2, "não fica pior do que a base... estritamente melhor", era falsa: a base
nunca fazia o nó de fecho falar (`texts` vazio só limpava); esta classe faz os DOIS nós de cada
sequência falarem, e por isso podia colidir com o intervalo mínimo de outra instância a
milissegundos de distância.

**Correcção escolhida**: `MIN_VISIBLE_S = 3.0` (constante da classe, o limite inferior do clamp de
duração da T-107). No ramo bloqueado por `min_interval_s`, `tick()` só limpa o balão
(`character.talking_text = ""`) se a frase actual já estiver visível pelo menos `MIN_VISIBLE_S`;
antes disso não toca no balão (fica com a frase anterior). Escolhi esta opção em vez da alternativa
sugerida pelo reviewer ("os nós de fecho só limpam, nunca falam, como na base") porque preserva o
comportamento já provado e testado da ronda 2 (as DUAS frases por sequência, uma a caminho e outra
a fazer a acção, ambas coerentes com `current_action`) e resolve exactamente o defeito medido, sem
reduzir a quantidade de frases que o náufrago diz.

**O que limpa o balão depois dos 3 s quando nenhum nó volta a fazer tick nesse ramo exacto**:
qualquer OUTRO nó desta classe, de qualquer uma das quatro sequências da árvore, que faça tick a
seguir (o que acontece pelo menos uma vez por ciclo de decisão, porque todas as sequências começam
por um `GoToUsableAction` + `SayGeneratedAction`), reavalia o MESMO `say_last_at_s` partilhado no
blackboard: se já passou `MIN_VISIBLE_S`, limpa; senão fala uma frase nova (que substitui a antiga,
e essa nova frase é que tem de ficar visível 3 s, não a antiga). Fica documentada em
`say_generated_action.gd` a limitação residual: se este nó exacto não for percorrido tão cedo, o
balão pode ficar com a frase antiga mais do que `MIN_VISIBLE_S` até o próximo nó desta classe
(de qualquer sequência) voltar a fazer tick; nunca fica preso para sempre, mas a duração exacta
além do mínimo não é garantida (isso é objecto da T-107).

**Relógio injectável**: `SayGeneratedAction.clock: Callable`, sem argumentos, devolve segundos; por
defeito inválido (`Callable()`) e usa `Time.get_ticks_msec() / 1000.0` (via `_now_s()`); os testes
injectam um `Callable` para um `FakeClock.get_now()` controlável, para provar `MIN_VISIBLE_S` sem
esperar segundos reais. `_speak()` também passou a usar `_now_s()` (antes chamava `Time` directo).

**Testes de regressão** (`test_say_generated_action.gd`): `test_respeita_min_interval_s_entre_frases`
e `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` reescritos com `FakeClock`: tick
bloqueado a 0,1 s da fala anterior tem de deixar o texto intacto; tick bloqueado a
`MIN_VISIBLE_S + 0,5` s tem de limpar. Prova por mutação em cópia de scratchpad (nunca no
repositório real): repondo a limpeza incondicional (`character.talking_text = ""` sem a guarda de
`MIN_VISIBLE_S`), os 2 testes falham exactamente no momento em que deviam continuar visíveis
(`[""] expected to equal ["Primeira frase"]` e `[""] expected to equal ["Frase da primeira
instância"]`); os outros 59 continuam a passar. Reversão confirmada (mutação só na cópia).

**Medição do tempo mínimo visível** (pedida pelo orquestrador), trace real-time numa cópia de
scratchpad, `INSULANO_LLM_URL=http://127.0.0.1:9` (porta morta, fallback determinístico),
`Engine.max_fps = 60` sem `--fixed-fps` (para `Time.get_ticks_msec()` avançar proporcionalmente ao
tempo real, ao contrário do `boot_smoke.gd` que corre o mais rápido possível), cada corrida sob
`timeout 300`:

| Corrida | Duração real | Frases | Mínimo visível | Casos < 3 s |
|---|---|---|---|---|
| Reviewer, base (HEAD) | 180 s | 13 | 117 frames (1,9 s) | 0 |
| Reviewer, trabalho ronda 2, `min_interval_s=30` | ~10 min | 17 | 4 frames (67 ms) | 3 (86-112 ms) + 1 de 0,9 s |
| Reviewer, trabalho ronda 2, `min_interval_s=3` | 240 s | 35 | 2 frames (33 ms) | 4 (33-100 ms) + 1 de 0,5 s |
| **Ronda 3 (corrigido), `min_interval_s=30` (defeito)** | 180 s real | 6 | 3117 ms | 0 |
| **Ronda 3 (corrigido), `min_interval_s=3`** | 240 s real | 40 (39 + 1 cortada pelo fim da corrida) | 935 ms (a cortada) / 3132 ms (das completas) | 0 (a de 935 ms é a última frase da corrida, cortada pelo fim do trace ao fim de 240 s, não uma limpeza ou substituição real; nenhuma frase que a árvore tenha efectivamente substituído ou limpo ficou visível menos de 3132 ms) |

Script do trace (`tools/visibility_probe.gd`, só na cópia de scratchpad, nunca comitado): carrega a
cena principal, mede `Time.get_ticks_msec()` a cada mudança de `character.talking_text`, imprime a
duração de cada frase e um resumo com o mínimo. `PROBE_MIN_INTERVAL_S` sobrepõe
`insulano/llm/min_interval_s` via `ProjectSettings` antes do autoload `LLM` correr.

**Ponto "a melhorar" tratado (interrupt())**: acrescentei `interrupt(actor, blackboard)` a
`SayGeneratedAction`, que esquece o pedido em curso (`_awaiting_request_id = -1`,
`_has_result = false`). Sem isto, se a árvore interrompesse este nó a meio de um `RUNNING` (um ramo
de prioridade mais alta a correr primeiro) e a MESMA instância fosse percorrida de novo mais tarde
(os nós da árvore são reutilizados, nunca recriados), `_resolve_awaiting()` resolveria com o
`_awaiting_request_id` antigo, e uma resposta tardia desse pedido interrompido apareceria a falar
sobre um contexto que já não é o actual. Decisão: NÃO chamar `super.interrupt()` (que só notifica o
debugger visual do Beehave) porque essa chamada aborta com `Can't send message. No active debugger`
sempre que corre sem debugger activo (headless, incluindo os testes GUT deste ficheiro; AGENTS.md
§10, ruído conhecido); chamar `super` fazia o GUT marcar o teste como falhado por "Unexpected
Errors", por uma limitação do addon Beehave em headless, não desta classe. Teste
`test_interrupt_esquece_o_pedido_em_curso`: depois de `interrupt()`, uma resposta tardia do pedido
interrompido é ignorada e um tick novo pede um pedido NOVO (RUNNING de novo, `call_count` sobe de 1
para 2). Prova por mutação em cópia de scratchpad: substituindo o corpo de `interrupt()` por `pass`,
só este teste falha (3 asserts, `_awaiting_request_id`/`_has_result` não são esquecidos); revertido
antes de continuar.

**Correcções baratas pedidas**:
- `game/tests/integration/test_go_to_usable_action.gd`: cabeçalho e mensagem do 2º assert
  actualizados (já não dizem que ir comer e ir pescar ficam sem `current_action_label`; agora dizem
  que as TRÊS instâncias em `guy.tscn` definem rótulo, e o 2º teste prova o caso neutro sem rótulo,
  que nenhuma delas usa hoje).
- `game/tools/boot_smoke.gd`: comentário de `SIMULATED_FRAMES` reescrito com o motivo verdadeiro por
  que o smoke passa: o `min_interval_s` conta em SEGUNDOS REAIS (`Time.get_ticks_msec()`), não nos
  frames simulados por `--fixed-fps` (que o Godot headless processa muito mais rápido do que o
  tempo real); a 1ª frase nunca está bloqueada por ele, porque `say_last_at_s` começa por definir no
  blackboard (`now_s - (-INF)` é sempre maior que qualquer intervalo); o smoke só exige UMA frase
  alguma vez, nunca uma 2ª depois do intervalo. Os 90 s simulados servem só para dar tempo ao
  personagem de completar pelo menos um ciclo de decisão.

**Documentos**: `agent_docs/tech_design.md` §4.6 reescrito para não afirmar "estritamente melhor do
que a base" sem prova, e para documentar `MIN_VISIBLE_S`, o relógio injectável e `interrupt()`. Este
Relatório.

### Correcções da ronda 2 (revisão adversarial)

1. **`current_action` desactualizado antes de comer e de pescar.** As duas instâncias de
   `GoToUsableAction` que ainda tinham `current_action_label` vazio (a da sequência de comer,
   `game/guy/guy.tscn:363`, e a da sequência de pesca, `game/guy/guy.tscn:427`) passaram a ter
   `"ir comer"` e `"ir pescar"`, respectivamente (a terceira, a de passear, já tinha `"passear"`
   desde a ronda 1). Prova por trace numa cópia em scratchpad (nunca no repositório real): com
   `min_interval_s=0.0` e um `print("TRACE cat=%s action=%s" ...)` acrescentado a
   `_start_request()`, 90 s simulados (`boot_smoke.gd`, `INSULANO_LLM_URL` numa porta morta) deram
   18 pedidos, TODOS coerentes (`cat=fishing action=ir pescar`, `cat=fishing action=pescar`,
   `cat=idle action=passear`, `cat=idle action=observar o oceano`, `cat=eating action=ir comer`,
   `cat=eating action=comer`, cada par sempre nesta ordem). Repondo o defeito (removendo os dois
   `current_action_label` novos, só nessa cópia) o mesmo trace volta a produzir os pares
   incoerentes que o reviewer apanhou: `cat=fishing action=estar na ilha`,
   `cat=fishing action=observar o oceano`, `cat=eating action=pescar`. O parágrafo de limitações
   da ronda 1 que dizia "o pior caso é uma frase de fallback, nunca uma frase incoerente" era falso
   (`PromptBuilder.build()` não rejeita `action` não vazio, mesmo que seja o verbo errado) e foi
   removido.
2. **O balão deixou de se apagar.** `SayGeneratedAction.tick()` agora limpa
   `character.talking_text = ""` quando `min_interval_s` bloqueia a fala (antes só devolvia
   `SUCCESS` sem tocar no balão). É o mesmo padrão "fala antes, limpa depois" que o `TalkAction`
   fechado de cada sequência tinha na base (`texts` vazio, ver `talk_action.gd` antes de ser
   apagado): não fica pior do que a base, porque a base limpava exactamente no mesmo ponto da
   árvore (o nó de fecho da sequência), e agora, quando o intervalo já passou, esse nó fala uma
   frase nova em vez de limpar (estritamente melhor). Quanto tempo uma frase fica visível antes de
   um bloqueio a limpar é uma função de quanto tempo a acção principal da sequência (pescar, comer,
   observar o oceano) demora, exactamente como na base; a duração proporcional ao comprimento da
   frase é da T-107 e não foi tocada aqui. Prova por mutação: removendo a linha
   `character.talking_text = ""`, os testes `test_respeita_min_interval_s_entre_frases` e
   `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` falham (o balão fica com a
   frase antiga em vez de "").
3. **O teste de partilha do intervalo não provava a partilha.** `test_duas_instancias_partilham_o_intervalo_minimo_pelo_blackboard`
   ficou como estava (min_interval_s=0.0, prova que uma 2ª instância pode falar), mas acrescentei
   `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira`
   (`game/tests/integration/test_say_generated_action.gd`): com `min_interval_s=1000.0`, a
   instância A fala, a instância B (nó diferente, mesmo blackboard) faz `tick()` a seguir, e
   verifica-se `call_count == 1` (a ponte não foi chamada outra vez) e `talking_text == ""` (sem
   texto, bloqueada). Prova por mutação: troquei a leitura/escrita de `say_last_at_s` no blackboard
   por uma variável `_own_last_said_at_s` por instância; o novo teste falhou (`call_count` passou a
   2), e só esse; os outros 59 continuaram a passar.

Mais um teste pedido como "a melhorar": `test_ignora_phrase_ready_com_request_id_de_outro_pedido`
prova que um `phrase_ready` com o `request_id` de outro pedido é ignorado (continua `RUNNING`, não
fala o texto errado); o `request_id` certo, a seguir, resolve normalmente. Prova por mutação:
removendo a comparação `_result_request_id == _awaiting_request_id` em `_resolve_awaiting()`, só
este teste falha (a acção falava com o texto do pedido errado).

Outros pontos "a melhorar" tratados: `agent_docs/testing.md` actualizado (90 s simulados, a
verificação da frase dita, e um aviso novo de que nenhum portão exercita "árvore mais HTTP real",
só a ponte isolada via `llm_live`); primeira linha `##` de `say_generated_action.gd` reescrita como
frase completa numa só linha (o resumo em `docs/architecture.md:97`, regenerado por
`check_docs.py --fix`, já não corta a meio); `backlog/README.md` já não cita `talk_action.gd`
(ficheiro apagado desde a ronda 1), agora cita `say_generated_action.gd`; `current_action_label`
documentado em `tech_design.md` §4.6.

### O que mudou

- `game/beehave/say_generated_action.gd` (novo): `class_name SayGeneratedAction extends ActionLeaf`,
  com o contrato exacto do `tech_design.md` §4.6. Primeiro tick pede a frase e devolve `RUNNING`;
  quando `phrase_ready` chega com o `request_id` certo, escreve `character.talking_text` e devolve
  `SUCCESS`. Trata a armadilha do enunciado (LLMBridge pode emitir `phrase_ready` SINCRONAMENTE,
  dentro da própria chamada a `request_phrase`, nos caminhos de fallback imediato) ligando o sinal
  ANTES de chamar `request_phrase`: uma resposta síncrona já fica em `_has_result` quando a
  chamada devolve, e o método resolve directamente para `SUCCESS` no mesmo tick, sem passar por
  `RUNNING`. `min_interval_s` vem de `LLMSettings` (tabela de settings do tech_design.md §3: a
  chave `insulano/llm/min_interval_s` é usada por `SayGeneratedAction`) e é partilhado por TODAS
  as instâncias da classe através da chave `say_last_at_s` no blackboard (não um relógio por nó): sem isto, os 6 nós
  desta classe na árvore falariam em sequência como se cada um tivesse o seu próprio intervalo.
  `bridge`/`settings` são injectáveis pelos testes (`code_patterns.md` §5); em jogo caem no
  autoload `LLM` e em `LLMSettings.load_settings()`. Sem `Clock`/`Weather`/`HolidayCalendar`
  (T-201/T-304/T-401, ainda planeados), o contexto usa a hora do sistema e valores neutros
  ("sol", "nenhuma"), documentado no código como ponto de integração futuro; não inventei nenhum
  método desses autoloads porque nenhum existe ainda.
- `game/beehave/fishing_action.gd`, `use_usable_action.gd`, `watch_ocean_action.gd`: cada um passa
  a escrever `blackboard.set_value("current_action", ...)` ("pescar", "comer", "observar o
  oceano", respectivamente) no início do `tick()`, seguindo o padrão já documentado em
  `code_patterns.md` §4 (exemplo `SleepAction`).
- `game/beehave/go_to_usable_action.gd`: `@export var current_action_label: String = ""` novo.
  Este nó é partilhado por três sequências (ir comer, ir pescar, passear); as TRÊS instâncias em
  `guy.tscn` definem o rótulo ("ir comer", "ir pescar", "passear" respectivamente, ver
  "Correcções da ronda 2" abaixo), para a `SayGeneratedAction` logo a seguir na mesma sequência
  nunca ler o `current_action` deixado pela sequência anterior (na ronda 1, as duas primeiras
  ficaram vazias por engano, o bloqueante 1 do reviewer).
- `game/guy/guy.tscn`: os 6 nós `TalkAction`/`TalkAction2` (todos com texto em inglês herdado da
  base) substituídos por `SayGeneratedAction`/`SayGeneratedAction2`, com `fallback_category`
  "eating" (sequência de comer), "idle" (sequência de passear/observar o oceano) e "fishing"
  (sequência de pesca). Os 3 `GoToUsableAction` (comer, pescar, passear) têm `current_action_label`.
  `grep -c "fishy" game/guy/guy.tscn` dá `0`.
- `game/beehave/talk_action.gd` e `.gd.uid` removidos: ficaram sem nenhum consumidor depois da
  substituição em `guy.tscn` (confirmado por grep antes de apagar) e sem nenhum teste próprio.
- `game/tools/boot_smoke.gd`: `SIMULATED_FRAMES` de 1800 (30 s) para 5400 (90 s, o valor que o
  critério da tarefa pede); novo `_load_fallback_phrases()` que lê
  `game/data/phrases_fallback.json` e achata todas as categorias numa lista; a cada frame verifica
  se `character.talking_text` coincide com alguma dessas frases e marca `_said_fallback_phrase`;
  `_finish()` falha se isso nunca aconteceu. Documentei explicitamente no cabeçalho que
  `INSULANO_LLM_URL` tem de vir do PROCESSO que invoca o Godot (nunca de `OS.set_environment()`
  dentro do próprio script): os autoloads (incluindo `LLM`) já correram `_ready()` antes de
  `_initialize()` deste `SceneTree` script ser chamado, por isso definir a variável mais tarde
  chegaria tarde para o `LLMSettings.load_settings()` que o `LLMBridge` já fez.
- `scripts/verify.sh`: a chamada ao `boot_smoke.gd` (passo 7) passa a correr com
  `INSULANO_LLM_URL="http://127.0.0.1:9"` (mesma porta morta que os outros testes do LLM já usam),
  para o smoke de arranque ser determinístico e nunca depender de um Ollama real a responder.
- Testes: `game/tests/integration/test_say_generated_action.gd` (7 testes, com uma `FakeBridge`
  interna: Node com o mesmo contrato de `LLMBridge.request_phrase`, controlável para responder
  síncrona ou assincronamente): RUNNING até ao sinal e SUCCESS depois; resposta síncrona dentro de
  `request_phrase` ainda resolve para SUCCESS no mesmo tick (a armadilha); `min_interval_s`
  bloqueia uma segunda chamada imediata à ponte e só limpa o balão depois de `MIN_VISIBLE_S`
  (ronda 3, com `FakeClock`); duas instâncias
  partilham o intervalo mínimo pelo blackboard (podem falar quando o intervalo já passou); uma 2ª
  instância fica BLOQUEADA pelo intervalo que a 1ª acabou de marcar (ronda 2, prova real da
  partilha); `phrase_ready` com o `request_id` de outro pedido é ignorado (ronda 2); `interrupt()`
  esquece o pedido em curso (ronda 3). Mais
  `test_watch_ocean_action.gd` e `test_use_usable_action.gd` (1 teste cada); `test_go_to_usable_action.gd`
  (2 testes: escreve com rótulo, não escreve sem rótulo); 1 teste acrescentado a
  `test_fishing_action.gd` para o mesmo critério.
- `docs/architecture.md`: mapa de componentes regenerado por `python3 scripts/check_docs.py --fix`
  (entrada de `talk_action.gd` removida, `say_generated_action.gd` acrescentada; a linha
  descritiva de `SayGeneratedAction` na tabela §4.2 já existia, escrita por uma tarefa anterior em
  antecipação ao contrato do tech design).
- `CHANGELOG.md`: entrada nova em `[Não lançado]`, secção `Adicionado`.

### Comandos corridos e resultado

- `uvx --from 'gdtoolkit==4.*' gdformat <ficheiros>` e `gdlint <ficheiros>`: sem problemas (um
  ficheiro de teste foi reformatado automaticamente; `say_generated_action.gd` teve de ser
  refactorizado em `_resolve_awaiting`/`_start_request` para respeitar `max-returns` do gdlint).
- `godot --headless --path game --import`: sem `SCRIPT ERROR`.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json`:
  **58/58 testes a passar** (18 scripts, 314 asserts), incluindo os testes novos desta tarefa:
  4 em `test_say_generated_action.gd`, 1 acrescentado a `test_fishing_action.gd`, 1 em
  `test_watch_ocean_action.gd`, 1 em `test_use_usable_action.gd` e 2 em
  `test_go_to_usable_action.gd`. Ruído conhecido "Can't send message. No active debugger"
  (AGENTS.md §10), ignorado.
- Mutação em cópia de scratchpad (nunca no repositório real), uma hipótese de cada vez, cada uma
  confirmando que o teste novo apanha exactamente a regressão que prova:
  1. Reintroduzi a armadilha (ligar o sinal DEPOIS de `request_phrase`, não antes): 3 dos 4 testes
     de `test_say_generated_action.gd` passaram a falhar, incluindo o teste dedicado à armadilha
     (`[2] expected to equal [0]`, isto é, RUNNING em vez de SUCCESS).
  2. Removi a escrita de `current_action` em `fishing_action.gd`, `watch_ocean_action.gd` e
     `use_usable_action.gd`: os 3 testes correspondentes falharam (`<null>` em vez do verbo
     esperado).
  3. Removi a escrita condicional em `go_to_usable_action.gd`: o teste "com label" falhou
     (`<null>` em vez de "passear"); o teste "sem label" continuou a passar, como esperado.
  4. Substituí a condição `min_interval_s` por `if false:` (nunca bloqueia): os testes de
     intervalo mínimo falharam (a ponte foi chamada 2 vezes em vez de 1).
  5. Fiz `tick()` devolver `SUCCESS` sempre, sem falar: o `boot_smoke.gd` (com
     `INSULANO_LLM_URL=http://127.0.0.1:9`) passou a FALHAR com "o personagem nunca disse uma
     frase de res://data/phrases_fallback.json em 5400 frames", confirmando que a nova verificação
     do boot_smoke apanha esta regressão concreta.
  Todas as 5 mutações foram revertidas antes de continuar; nenhuma ficou no repositório real.
- `INSULANO_LLM_URL="http://127.0.0.1:9" godot --headless --fixed-fps 60 --path game -s
  res://tools/boot_smoke.gd`: `BOOT_SMOKE PASSOU: fome -37.6 pontos, deslocação máxima 691 px`
  (corrida isolada) e `-76.2 pontos, deslocação máxima 527 px` (dentro do `verify.sh` completo,
  variação esperada por `code_patterns.md`/AGENTS.md §10: `randf()` tem seed fixa mas
  `NavigationServer2D` não).
- `scripts/verify.sh --visual --llm`: **VEREDICTO: PASSOU** em `docs`, `backlog`, `pytest`, `lint`,
  `import`, `gut`, `boot`, `visual`, `llm` (eval com `pass_rate: 1.0`) e `llm_live`. Corrido duas
  vezes (antes e depois de acrescentar o CHANGELOG e a prova visual), ambas PASSOU.
- Captura dedicada para a prova: `INSULANO_LLM_URL="http://127.0.0.1:9" godot
  --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd --
  --out=... --frames=3600` (60 s simulados, mais do que os 4 s do `--frames` por defeito do
  `verify.sh --visual`, para garantir tempo de sobra até o náufrago falar pela 1ª vez).
  Copiada para `docs/proof/T-106-frase-gerada.png` e **aberta com o Read**: mostra o balão com o
  texto "A palmeira está a crescer. Ou sou eu que encolhi?" (frase da categoria "idle" de
  `phrases_fallback.json`), em português de Portugal, por cima do personagem na ilha.

### Comandos corridos e resultado (ronda 2, correcção dos bloqueantes)

- `uvx --from 'gdtoolkit==4.*' gdformat/gdlint <ficheiros>`: sem problemas depois de encurtar a
  1ª linha `##` de `say_generated_action.gd` para caber no `max-line-length` (100).
- `godot --headless --path game --import`: sem `SCRIPT ERROR`.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json`:
  **60/60 testes a passar** (18 scripts, 325 asserts): os 58 anteriores mais
  `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` e
  `test_ignora_phrase_ready_com_request_id_de_outro_pedido`. Ruído conhecido "Can't send message.
  No active debugger" (AGENTS.md §10), ignorado.
- Mutação em cópia de scratchpad (`$SCRATCH/game-mut`, nunca no repositório real), uma hipótese de
  cada vez:
  1. **Bloqueante 1** (rótulos em falta): trace com `min_interval_s=0.0` e `print()` acrescentado a
     `_start_request()`, corrido com `boot_smoke.gd` (90 s simulados, porta morta). Com a correcção,
     18 pedidos, todos coerentes. Removendo os dois `current_action_label` novos (só na cópia),
     reaparecem `cat=fishing action=estar na ilha`, `cat=fishing action=observar o oceano` e
     `cat=eating action=pescar`, a mesma classe de defeito que o reviewer apanhou.
  2. **Bloqueante 2** (balão não limpa): removendo `character.talking_text = ""` do ramo de
     bloqueio, `test_respeita_min_interval_s_entre_frases` e
     `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` falham (esperavam `""`,
     receberam a frase anterior); um 3º falhanço (`test_defaults_without_file_or_env`) era resíduo
     de eu ter alterado `project.godot` para a prova do bloqueante 1 na mesma cópia, não desta
     mutação.
  3. **Bloqueante 3** (relógio por instância): troquei a leitura/escrita de `say_last_at_s` no
     blackboard por uma variável de instância `_own_last_said_at_s`; só
     `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` falha (`call_count` passou
     de 1 para 2), os outros 59 continuam a passar.
  4. **Teste novo do request_id estranho**: removendo a comparação
     `_result_request_id == _awaiting_request_id` em `_resolve_awaiting()`, só
     `test_ignora_phrase_ready_com_request_id_de_outro_pedido` falha.
  Todas as mutações foram revertidas antes de continuar (confirmado por `Passing Tests 60` depois
  de cada reversão); nenhuma ficou no repositório real.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`; `docs/architecture.md`
  regenerado (linha de `say_generated_action.gd` já não corta a meio).
- `scripts/verify.sh --visual --llm`: **VEREDICTO: PASSOU** em `docs`, `backlog`, `pytest`, `lint`,
  `import`, `gut` (60/60), `boot`, `visual`, `llm` (`pass_rate: 1.0`) e `llm_live`. Corrido duas
  vezes (antes e depois de regravar a prova visual e o `CHANGELOG`), ambas PASSOU.
- Prova visual regravada porque o comportamento do balão mudou (bloqueante 2): script temporário
  `game/tools/_tmp_capture_wait.gd` (nunca comitado, apagado logo depois de usar), variante do
  `capture.gd` que espera `Character.talking_text != ""` mais 15 frames de acomodação antes de
  gravar o PNG, correndo com `INSULANO_LLM_URL="http://127.0.0.1:9"` para fallback determinístico.
  Capturou o balão com o texto "Vamos ver o que o mar tem para oferecer." (categoria "fishing",
  coerente com `current_action = "ir pescar"`, escrito pelo `GoToUsableAction` corrigido). Copiada
  para `docs/proof/T-106-frase-gerada.png` e **aberta com o Read**: balão bem legível, personagem
  com a cana já visível junto ao ponto de pesca, fome a 98%.

### Comandos corridos e resultado (ronda 3, correcção da regressão do bloqueante 2)

- `uvx --from 'gdtoolkit==4.*' gdformat/gdlint` nos ficheiros tocados: sem problemas (a `const
  MIN_VISIBLE_S` teve de subir antes dos `@export`, `class-definitions-order` do gdlint).
- `godot --headless --path game --import`: sem `SCRIPT ERROR`.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json`:
  **61/61 testes a passar** (18 scripts, 336 asserts): os 60 anteriores, `test_respeita_min_interval_s_entre_frases`
  e `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` reescritos com `FakeClock`, e
  `test_interrupt_esquece_o_pedido_em_curso` novo. O ruído conhecido "Can't send message. No active
  debugger" (AGENTS.md §10) não aparece no teste novo, porque o `interrupt()` não chama `super`; no
  `reports/gut.log` completo continua a aparecer (44 vezes, vindo de `test_llm_bridge.gd`).
- Mutação em cópia de scratchpad (nunca no repositório real), uma hipótese de cada vez:
  1. Reposta a limpeza incondicional (`character.talking_text = ""` sem a guarda de
     `now_s - last_said_at >= MIN_VISIBLE_S`): `test_respeita_min_interval_s_entre_frases` e
     `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` falham
     (`[""] expected to equal ["Primeira frase"]` e `[""] expected to equal ["Frase da primeira
     instância"]`); os outros 59 continuam a passar. 5/7 do ficheiro passam.
  2. `interrupt()` substituído por `pass` (não esquece `_awaiting_request_id`/`_has_result`): só
     `test_interrupt_esquece_o_pedido_em_curso` falha (3 asserts: `call_count` fica em 1 em vez de
     subir para 2, e o texto tardio "Frase tardia do pedido interrompido" é falado em vez de
     ficar `""`). 6/7 do ficheiro passam.
  Ambas revertidas antes de continuar; nenhuma ficou no repositório real; confirmado por
  `Passing Tests 61` depois de cada reversão.
- Medição do tempo mínimo visível (`tools/visibility_probe.gd`, só na cópia de scratchpad, `godot
  --headless --path . -s res://tools/visibility_probe.gd`, `Engine.max_fps = 60`, SEM
  `--fixed-fps`, `INSULANO_LLM_URL=http://127.0.0.1:9`, `timeout 300`): ver a tabela na secção
  "Correcções da ronda 3" acima. Duas corridas, 180 s e 240 s reais, ambas dentro do limite de
  5 minutos; nenhuma corrida com o Ollama real repetida.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`; `docs/architecture.md`
  já estava consistente (nenhuma linha nova).
- `scripts/verify.sh --visual --llm`: corrido 4 vezes ao longo desta ronda (depois de cada bloco de
  alterações: código, docs finais, prova visual). 2 delas **FALHARAM** só em `llm`
  (`pass_rate` 0,9583 e 0,9167, motivos `too_long`/`timeout`/`ptbr`); as outras 2, incluindo a
  ÚLTIMA corrida antes de fechar este Relatório, **VEREDICTO: PASSOU** em todos os passos,
  incluindo `llm` (`pass_rate: 1.0`) e `gut` (61/61). Ver "Por verificar" para o porquê de não ser
  regressão desta tarefa.
- Prova visual regravada outra vez, porque o timing do balão voltou a mudar (a correcção do
  bloqueante 2 desta ronda): mesmo padrão de script temporário
  (`game/tools/_tmp_capture_wait.gd`, nunca comitado, apagado logo depois de usar),
  `INSULANO_LLM_URL="http://127.0.0.1:9"`, `godot --rendering-driver opengl3 --fixed-fps 60`.
  Capturou o balão com o texto "O peixe de ontem era melhor." (categoria de fallback, fome a 96%).
  Copiada para `docs/proof/T-106-frase-gerada.png` e **aberta com o Read**: balão bem legível sobre
  o oceano e a relva, personagem visível por baixo.

### Desvios do tech design

Nenhum: o contrato de `SayGeneratedAction` em `tech_design.md` §4.6 já cobria `min_interval_s`
(via a tabela de settings §3) e a integração com Clock/Weather "quando existirem"; implementei
literalmente essa condicional (ainda não existem) sem inventar nenhuma API futura.

### Por verificar / limitações conhecidas

- Corrigido na ronda 2 (bloqueante 1 do reviewer): a frase dita ANTES de comer ou de pescar já não
  usa um `current_action` desactualizado da sequência anterior; ver "Correcções da ronda 2" acima e
  a prova por trace.
- Corrigido nesta ronda 3 (bloqueante 2, a regressão da correcção da ronda 2): o balão já não pisca
  e apaga-se antes de ser legível; ver "Correcções da ronda 3" acima, a tabela de medição e a prova
  por mutação. Limitação residual que fica documentada em código e aqui: se o nó exacto que falou
  não for percorrido de novo em breve (a árvore mudou de ramo por mais tempo do que o habitual), o
  balão pode ficar com a frase antiga mais do que `MIN_VISIBLE_S` até QUALQUER outro nó desta classe
  voltar a fazer tick; isso acontece pelo menos uma vez por ciclo de decisão nesta árvore (todas as
  4 sequências começam por um destes nós), por isso nunca fica preso para sempre, mas a duração
  exacta acima do mínimo não está garantida nem testada para o caso extremo de o náufrago passar
  minutos na mesma sub-árvore sem decisão nova.
- Não corri `scripts/verify.sh --export` nem `--full` (fora do que esta tarefa exige; a T-507 já
  cobre o export Windows/Linux separadamente).
- O aviso pré-existente "6 ObjectDB instances leaked"/"1 resources still in use" no fim da corrida
  do GUT já existia antes desta tarefa (confirmei contra `reports/gut.log` de uma corrida anterior
  à T-106, mesmos números); não é uma regressão introduzida aqui.
- Buraco de cobertura registado em `agent_docs/testing.md` (pedido "a melhorar" da ronda 2):
  nenhum portão exercita a árvore de comportamento completa a falar contra um Ollama REAL ao mesmo
  tempo; o `llm_live` só testa a `LLMBridge` isolada, o `boot_smoke` usa sempre uma porta morta, e
  o `llm_eval.py` testa `PromptBuilder`/`PhraseFilter` fora da árvore. A verificação desse caminho
  completo é manual (a captura desta tarefa, com o Ollama real ligado no `verify.sh --llm`, prova
  só que a árvore corre sem crash com o Ollama real; não prova o CONTEÚDO da frase nesse caminho).
- A duração do balão em ecrã continua ligada à duração da acção principal da sequência (pescar,
  comer, observar o oceano) mais o mínimo de `MIN_VISIBLE_S` desta ronda, não ao comprimento da
  frase: a duração proporcional (`clamp(2.5 + 0.35 * palavras, 3, 9)`, `tech_design.md` §4.6) é da
  T-107, fora de âmbito aqui.
- `scripts/verify.sh --llm` (o eval contra o Ollama real, `llm_eval.py`) falhou uma vez nesta ronda
  por `too_long`/`timeout` (`pass_rate` 0,9583 e depois 0,9167 numa 2ª corrida isolada), e passou
  com `pass_rate: 1.0` na corrida seguinte; não é uma regressão desta tarefa (nenhum ficheiro que
  este eval exercita, `PromptBuilder`/`PhraseFilter`/`phrase_cases.json`, foi tocado aqui), é a
  variância conhecida do Ollama em CPU sob carga (memória `ollama-docker-exposto-cpu`). Fica
  registado, não escondido.

### Pontos em aberto da revisão da ronda 3 (não bloqueantes, para tarefa seguinte)

Registados pelo orquestrador a partir do veredicto APROVADO do `insulano-reviewer`; não foram
corrigidos aqui para não mexer em código de produção depois da aprovação.
- `game/tests/integration/test_say_generated_action.gd`: os dois testes de intervalo começam o
  `FakeClock` em 0, por isso a mutação `if now_s >= MIN_VISIBLE_S:` (tempo absoluto, o bug da ronda
  2 a partir dos 3 s de jogo) passa. Começar o relógio em 1000.0 e avançar em relação a esse valor.
- `game/beehave/say_generated_action.gd:105-106`: a garantia de 3 s só vale com
  `min_interval_s >= 3`; o `user://settings.cfg` aceita qualquer valor. Usar
  `maxf(min_interval_s, MIN_VISIBLE_S)` ou validar em `LLMSettings`. O `CHANGELOG.md` diz "para nunca
  piscar" sem esta condição.
  **Resolvido na T-107** (ronda 1 de revisão): `tick()` usa
  `maxf(min_interval_s, MIN_VISIBLE_S)` como intervalo efectivo entre pedidos, provado por mutação e
  por `test_min_interval_s_abaixo_do_minimo_e_elevado_a_min_visible_s`
  (`game/tests/integration/test_say_generated_action.gd`); ver Relatório da T-107.
- `game/beehave/say_generated_action.gd:186`: trocar a omissão do `super` por
  `if EngineDebugger.is_active(): super(_actor, _blackboard)`, para manter o depurador visual no
  editor sem erro em headless.
- Nenhum teste carrega `game/guy/guy.tscn` para confirmar os 6 pares `fallback_category` e
  `current_action_label`; uma troca na cena não é apanhada.
- T-107: a limpeza em `SayGeneratedAction.tick()` terá de ceder a duração ao temporizador do
  `SpeechBubble`, para não haver dois donos da duração do balão.
- O rótulo "Hunger" do HUD está em inglês (vem da base, fora do âmbito desta tarefa).

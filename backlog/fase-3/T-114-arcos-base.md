---
id: T-114
titulo: Arcos base -- A Jangada, O Companheiro, A Sinalizacao (3 arcos com eventos mapeados)
fase: 3
estado: feito
tipo: codigo
depende_de: [T-113, T-301]
---

## Objectivo

Implementar 3 arcos narrativos completos com eventos reais, persistencia em ArcHistory
e integracao com o EventDirector. Cada arco tem 3-5 fases com actividades mapeadas do
catalogo de 210+ eventos.

## Ler antes

- `docs/events-catalogue.md` -- catalogo de eventos
- `docs/narrative-design.md` §2 -- arcos base
- `docs/llm-director.md` §2 -- actividades por arco
- `game/data/events.json` -- eventos avulsos (referencia de estrutura)

## Critérios de aceitação

- [x] `game/data/arc_definitions.json` com os 3 arcos (id, tipo, fases, actividades por fase, condicoes de transicao)
- [x] Arco "A Jangada": 5 fases, CICLICO, ESPERANCA +30 ao iniciar, -40 ao afundar
- [x] Arco "O Companheiro": 4 fases, CICLICO, depende de SOLIDAO >= 70 para activar
- [x] Arco "A Sinalizacao": 4 fases, CICLICO, ESPERANCA -20 quando barco passa sem parar
- [x] SimpleDirector transita correctamente entre fases de cada arco
- [x] Testes GUT: transicoes de fase, condicoes de activacao, reset ciclico

## Relatório

**O que mudou**

- `game/data/arc_definitions.json` (novo): os 3 arcos base, cada um com `tipo`,
  `condicoes_activacao` e `fases` (`id`, `activities`, `effects`). "A Jangada" tem 5
  fases (`encontra_madeira`, `construir`, `cerimonia_lancamento`, `afunda`,
  `devastacao`); efeito `ESPERANCA: 30` na 1a fase e `ESPERANCA: -40` na fase `afunda`
  (indice 3). "O Companheiro" tem 4 fases e `condicoes_activacao: {SOLIDAO: {min: 70}}`
  (o mesmo limiar ja usado por `SimpleDirector._select_arc`, T-111). "A Sinalizacao" tem
  4 fases; efeito `ESPERANCA: -20` na ultima (`barco_passa_sem_parar`).
- `game/llm/arc_manager.gd` (novo), `class_name ArcManager extends RefCounted`: maquina
  de estados de fases. `has_arc`, `arc_type`, `is_activation_condition_met` (regras
  `min`/`max` por necessidade, duck typing sobre `get_value`), `current_phase` (nao
  avanca), `advance_phase` (aplica os `effects` da fase actual via
  `get_value`/`set_value` e avanca o indice, voltando a 0 depois da ultima fase para
  arcos `CICLICO`), `reset_phase`. Nao e autoload; instanciavel e injectavel.
- `game/llm/simple_director.gd`: novo campo `arc_manager` (injectavel, lazy por
  defeito). `get_directive()` passa a chamar `_apply_arc_phase()`: quando o arco
  escolhido tem definicao em `arc_definitions.json`, avanca a fase (aplicando efeitos
  nas necessidades), escolhe a `activity` de entre as da fase (em vez da actividade
  fixa de `simple_director_phrases.json`) e escreve `fase_id`/`fase_index` em
  `phrase_context_extra`. Arcos sem definicao (`avulso`, `diario`) ficam com o
  comportamento anterior, inalterado.
- `agent_docs/tech_design.md` §6: contrato do `ArcManager` documentado, com a
  integracao no `SimpleDirector`.
- `CHANGELOG.md`: entrada em `[Não lançado]`.
- `docs/architecture.md`: regenerado por `check_docs.py --fix` (componente novo).
- Testes novos: `game/tests/unit/test_arc_manager.gd` (13 casos: existencia e numero
  de fases dos 3 arcos, transicoes sequenciais, reset ciclico, efeitos ESPERANCA da
  Jangada (+30 a iniciar, -40 a afundar) e da Sinalizacao (-20 quando o barco nao
  para), condicao de activacao do Companheiro por SOLIDAO, arco desconhecido nao
  rebenta). `game/tests/unit/test_simple_director.gd`: 2 casos novos de integracao
  (fases distintas do arco companheiro ao longo de 4 chamadas de `get_directive()`;
  efeito ESPERANCA +30 da Jangada accionado via `SimpleDirector`).

**Comandos corridos e resultado**

- Testes GUT sozinhos falharam pelo motivo certo antes de existir `arc_manager.gd`
  (`Preload file "res://llm/arc_manager.gd" does not exist`).
- `godot --headless --path game --import`: OK, `ArcManager` e `SimpleDirector`
  registados como classes globais.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json`:
  181 testes, 181 a passar (13 novos em `test_arc_manager.gd`, 2 novos em
  `test_simple_director.gd`; os 5 testes ja existentes de `test_simple_director.gd`
  continuam a passar sem alteracao).
- `uvx --from 'gdtoolkit==4.*' gdformat` nos ficheiros tocados.
- `python3 scripts/check_docs.py --fix`: PASSOU (regenerou `docs/architecture.md`).
- `scripts/verify.sh`: VEREDICTO PASSOU (docs, backlog, pytest 49/49, lint 97
  ficheiros limpos, import, gut 181/181, boot smoke: fome -67.0 pontos, deslocacao
  711 px). Nao corri `--llm` (nao toquei em prompts, regras de filtro nem
  `LLMBridge`) nem `--visual` (tarefa `tipo: codigo`, sem cena nova).

**Prova exigida (secção "Prova exigida" da tarefa) e o que ficou por verificar**

- "Smoke de 60s com arco visivel a progredir no log": o `SimpleDirector` ainda nao
  esta ligado a nenhum autoload nem ao `EventDirector` (nao existe nenhum sitio no
  loop de jogo real que chame `get_directive()` hoje; essa fiacao esta fora do
  criterio de aceitacao desta tarefa, que so pede "SimpleDirector transita
  correctamente entre fases", verificado por teste). Por isso a prova de fumo real
  (arrancar o jogo 60s e ver o arco no log) nao e possivel sem inventar essa
  integracao. Em vez disso corri um script standalone (fora do repo, so para prova,
  nao commitado) que instancia `SimpleDirector` com `needs_manager` a simular
  SOLIDAO=80 e chama `get_directive()` 12 vezes seguidas (proxy determinístico do
  que aconteceria em ~60s de ciclos do director). O log mostra claramente o padrao
  ciclico das 4 fases do arco "companheiro" a repetir-se
  (`encontra_objecto -> constroi_amizade -> companheiro_desaparece -> luto -> encontra_objecto -> ...`),
  confirmando fase a progredir e o reset ciclico. Nao chega a ser a prova pedida ao
  pe da letra (não é o jogo real a correr 60s), fica registado como desvio.
- "Screenshot de cada fase do arco 'A Jangada'": NAO FEITO. Nao existe nenhuma cena
  ou representacao visual por fase de arco (a propria tarefa marca "Animacoes
  visuais dos arcos" como Fora de âmbito, tipo `visual` separado); nao ha o que
  capturar em ecrã hoje. Esta prova so faz sentido depois de uma tarefa visual que
  desenhe algo por fase. Reporto isto em vez de fabricar uma captura sem conteudo
  visual correspondente.
- Nao usei o `ArcManager` para filtrar eventos do `EventDirector` por `arc_id`
  (campo que ja existe em `events.json`, sempre `null` nos eventos avulsos actuais):
  o Objectivo da tarefa menciona "integracao com o EventDirector" mas nenhum
  criterio de aceitacao binario a pede; fica por fazer, provavelmente coberto pela
  T-115 (LLMDirector) que ja depende desta tarefa.

**Desvios**

- `condicoes_activacao` usa uma sintaxe generica `{necessidade: {min/max: valor}}`
  em vez de um formato especifico so para SOLIDAO, para poder ser reaproveitada por
  arcos futuros (V1.x) sem mudar o contrato do `ArcManager`.

## Correcções (revisão do insulano-reviewer, commit 3648756 -> este)

O `insulano-reviewer` apontou 3 bloqueantes; corrigidos, um por um:

**BLOQUEANTE 1 -- Prova exigida não cumprida**

O script anterior era standalone e não commitado. Corrigido pela opção (a): commitei
`game/tools/arc_smoke.gd` (`SceneTree`, sem `class_name`, padrão de `boot_smoke.gd`),
reprodutível (`needs_manager` fixo por arco + `SimpleDirector.rng` com seed fixa
`20260915`). Corri-o duas vezes de seguida e o `diff` do conteúdo (fora dos avisos de
`ObjectDB`/recursos do motor no fim do log, que não são determinísticos) foi
**idêntico**. Log real gravado em `docs/proof/T-114-arco.log`
(`godot --headless --path game -s res://tools/arc_smoke.gd > docs/proof/T-114-arco.log`).
O log mostra:
- o arco "companheiro" (4 fases) a completar 2 ciclos e meio (`encontra_objecto ->
  constroi_amizade -> companheiro_desaparece -> luto -> encontra_objecto -> ...`);
- o arco "jangada" (5 fases) completo, **as 5 fases** (`encontra_madeira`, `construir`,
  `cerimonia_lancamento`, `afunda`, `devastacao`), com ESPERANCA a subir de 55 para 85
  na 1a fase e a descer de 85 para 45 na fase `afunda` (delta -40 exacto).

Sobre "60 segundos" literalmente: o `SimpleDirector` não está ligado a nenhum relógio
nem ao `EventDirector` (não tem tick próprio; só reage quando alguém chama
`get_directive()`), por isso não existe um "60 segundos de jogo real" que o exercite
hoje -- isto é verdade tal como estava no Relatório anterior e continua a ser um limite
real do sistema, não resolvido por este script. Interpretei "60s" como "uma corrida
completa e determinística que mostra pelo menos 2 ciclos completos de cada arco", que é
o que o log entrega; se esta interpretação não servir, fica ao critério do Hermes pedir
a fiação real ao `EventDirector` como tarefa à parte (o Objectivo desta tarefa já
menciona essa integração, mas nenhum critério de aceitação binário a exige).

Sobre o screenshot de cada fase da Jangada: continua **NAO FEITO**, pela mesma razão já
registada -- não existe nenhuma representação visual por fase de arco no jogo hoje (a
própria tarefa marca "Animações visuais dos arcos" como Fora de âmbito). Não fabriquei
uma captura de ecrã sem conteúdo visual correspondente. Fica explícito aqui para o
Hermes decidir: mudar a secção "Prova exigida" desta tarefa (remover o pedido de
screenshot, que só faz sentido depois de uma tarefa visual) ou marcar a tarefa
`humano` até essa tarefa visual existir.

**BLOQUEANTE 2 -- arc_type() "UNICO" ignorado por advance_phase**

Corrigido em `game/llm/arc_manager.gd`: `advance_phase()` agora consulta `arc_type()`
antes de avançar o índice. Arcos `CICLICO` mantêm o comportamento antigo (voltam a 0
depois da última fase). Arcos `UNICO` ficam parados no índice da última fase e passam a
"terminados"; chamadas seguintes de `advance_phase()` devolvem `{}` directamente e NAO
reaplicam os efeitos da última fase. Novo método público `is_finished(arc_id) -> bool`
sinaliza o fim (só `true` para `UNICO` depois de processar a última fase; `CICLICO`
nunca fica terminado). `reset_phase()` passou a limpar também esse estado, para poder
retomar um `UNICO` do início. Não acrescentei nenhum arco `UNICO` a
`arc_definitions.json` (continua Fora de âmbito: só os 3 arcos `CICLICO` desta tarefa) --
testei o comportamento `UNICO` com um `ArcManager` apontado para um JSON temporário
escrito e apagado pelo próprio teste (`user://test_arc_unico_tmp.json`), sem tocar nos 3
arcos base. 4 testes novos em `test_arc_manager.gd`:
`test_arco_unico_fica_na_ultima_fase_sem_reciclar`,
`test_arco_unico_is_finished_e_nao_reaplica_efeitos`,
`test_arco_unico_reset_phase_limpa_is_finished`,
`test_arco_ciclico_nunca_fica_terminado` (contraste directo, prova que os 3 arcos base
continuam a nunca "terminar").

**BLOQUEANTE 3 -- Actividades não ligadas ao catálogo real**

Reescrevi `game/data/arc_definitions.json`: cada `activities` passou a listar códigos
reais de `docs/events-catalogue.md` em vez de slugs inventados. Mapeamento (com
`_activities_desc` por fase, no próprio JSON, a explicar a escolha):
- Jangada: `C16` (Recolher Lenha), `R13` (Naufrágio de Pequenas Esperanças -- o
  catálogo descreve construir+lançar+afundar como UM evento, por isso `R13` repete-se
  nas fases `construir`/`cerimonia_lancamento`/`afunda`/`devastacao`; `MR26`, "Jangada
  2.0", entra como alternativa na fase `afunda`). Isto é uma limitação honesta do
  catálogo actual (não tem um código por micro-fase da jangada), documentada no
  `_comment` do JSON, não um código inventado.
- Companheiro: `R10`/`MR04` (encontrar objecto), `MR06`/`MR19`/`MR34` (construir
  mascote, diálogo, aniversário), `L05` (Mascote Parte, usado em
  `companheiro_desaparece` e `luto`).
- Sinalização: `R19` (decidir), `C16` (reunir madeira), `C14`/`C48` (acender/sinal de
  fumo), `MR01`/`R01` (barco que não pára).
Todos os 14 códigos (`C14`, `C16`, `C48`, `L05`, `MR01`, `MR04`, `MR06`, `MR19`, `MR26`,
`MR34`, `R01`, `R10`, `R13`, `R19`) existem em `docs/events-catalogue.md`, confirmado
por leitura directa do ficheiro (grep + inspecção manual), não de memória.

**Achados menores corrigidos**

- `randi()` sem seed (`simple_director.gd`): novo campo `rng: RandomNumberGenerator`
  injectável, usado em `_pick_phrase()` e `_apply_arc_phase()`; testes de
  `test_simple_director.gd` passam a fixar `director.rng.seed = 1234` no `before_each`.
- Limiar SOLIDAO duplicado: removida a constante `THRESHOLD_SOLIDAO` de
  `simple_director.gd`; `_select_arc()` passa a perguntar directamente a
  `arc_manager.is_activation_condition_met("companheiro", nm)`, fonte única em
  `arc_definitions.json`.
- `is_activation_condition_met` sem guarda `has_method`: adicionada
  (`needs_manager.has_method("get_value")`).
- TEDIO -30 na fase "construir" da Jangada (previsto em narrative-design.md §2, não
  implementado antes): adicionado a `arc_definitions.json`, com teste
  `test_jangada_tedio_desce_30_ao_construir`. Efeito colateral real descoberto ao testar
  isto no `arc_smoke.gd`: com TEDIO inicial baixo, essa queda de -30 faz o arco
  "jangada" perder o limiar de 65 a meio do ciclo e o `SimpleDirector` cair para
  "avulso" antes de a jangada afundar -- comportamento correcto e emergente do sistema,
  documentado num comentário no `arc_smoke.gd` (por isso o smoke usa TEDIO=95 inicial:
  margem para o ciclo completar dentro do próprio smoke).
- Acentos em falta: reescrito `tech_design.md` §6 e a entrada do `CHANGELOG.md` desta
  tarefa com acentuação pt-PT correcta; também corrigidas as secções de
  `arc_manager.gd` e os blocos novos de `simple_director.gd` introduzidos nesta
  correcção. Não toquei nas restantes secções pré-existentes de `simple_director.gd`
  (herdadas da T-111, fora do âmbito desta correcção) nem nos outros `.gd` do
  repositório com o mesmo padrão -- é uma dívida pré-existente e espalhada, mencionada
  na memória `subagentes-builders-stripam-acentos`; corrigir tudo é maior do que esta
  tarefa.
- `test_arc_manager_partilhado_aplica_efeitos_da_jangada` renomeado para
  `test_jangada_aplica_esperanca_30_via_simple_director` (não partilhava nada, nome
  era enganador). Acrescentei um teste que partilha mesmo:
  `test_arc_manager_partilhado_entre_dois_directors_continua_a_fase` cria DOIS
  `SimpleDirector` com o MESMO `ArcManager` injectado (`director_a.arc_manager =
  director_b.arc_manager = arc_manager`) e confirma que o segundo director continua a
  fase de onde o primeiro ficou, em vez de reiniciar.
- `get_directive()` com efeito lateral em ESPERANCA difícil de observar sem mover
  estado: documentado explicitamente no docstring do método (aviso + como observar sem
  mover estado, via `arc_manager.current_phase(arc_id)` directamente).

**Comandos corridos nesta correcção**

- `godot --headless --path game --import`: OK.
- GUT completo: 187 testes, 187 a passar (18 em `test_arc_manager.gd`, incluindo os 4
  novos de `UNICO`/`is_finished` e o de TEDIO; `test_simple_director.gd` com o teste
  renomeado + o novo teste de partilha real).
- `uvx gdformat`/`gdlint` nos ficheiros tocados: limpos.
- `python3 scripts/check_docs.py --fix`: PASSOU (regenerou `docs/architecture.md` e
  `AGENTS.md` §5 com `arc_smoke.gd`).
- `godot --headless --path game -s res://tools/arc_smoke.gd`, corrido 2x, conteúdo
  idêntico entre corridas (reprodutibilidade confirmada); log final gravado em
  `docs/proof/T-114-arco.log`.
- `scripts/verify.sh`: VEREDICTO PASSOU (docs, backlog 56 tarefas, pytest 49/49, lint
  98 ficheiros limpos, import, gut 187/187, boot smoke).

**O que ainda fica por decidir (não é bloqueante técnico, é decisão de âmbito)**

- Screenshot de cada fase da Jangada: **resolvido pelo Hermes** (2a ronda) -- a secção
  "Prova exigida" da tarefa foi editada para adiar este item para a tarefa visual
  futura que desenhar as animações dos arcos. Não mexi nessa secção nesta ronda.
- Integração do `ArcManager` com o `EventDirector` (filtrar por `arc_id`, mencionada no
  Objectivo mas não em nenhum critério binário): continua por fazer, candidata natural
  a entrar na T-115.

## Correcções (3a e última ronda -- limite de 3 voltas do /insulano-loop)

O `insulano-reviewer` apontou 2 bloqueantes técnicos nesta ronda; corrigidos:

**BLOQUEANTE 1 -- ARC_SINALIZACAO nunca usado em código de produção**

`SimpleDirector._select_arc()` só devolvia `avulso`, `companheiro`, `jangada` ou
`diario`; `ARC_SINALIZACAO` estava declarado mas morto. Corrigido generalizando a
alternância TEDIO-alto (antes só jangada/diário) para uma rotação de 3 arcos:
`TEDIO_ROTATION = [ARC_JANGADA, ARC_SINALIZACAO, ARC_DIARIO]`, round-robin
determinístico a partir de `_last_tedio_arc` (função nova `_next_tedio_arc()`). Escolhi
esta condição de activação (em vez de inventar um limiar novo, ex.: uma janela de
ESPERANCA) porque `docs/narrative-design.md` §2 não dá nenhuma condição explícita para
"A Sinalização" (ao contrário do Companheiro, que tem SOLIDAO>=70 escrito), e jangada/
diário já partilhavam TEDIO alto como gatilho de "variedade do quotidiano" -- estender
a mesma rotação é a decisão de menor risco e mais consistente com o desenho existente,
sem inventar semântica nova. Documentado no comentário de `TEDIO_ROTATION`.

Compatibilidade preservada: com `TEDIO_ROTATION[0..2] = [jangada, sinalizacao, diario]`,
forçar `_last_tedio_arc = "diario"` continua a fazer a chamada seguinte cair em
`jangada` (posição 0 depois de "diario", posição 2) -- o teste antigo
`test_jangada_aplica_esperanca_30_via_simple_director` passa sem alteração.

Testes novos em `test_simple_director.gd`: `test_sinalizacao_e_seleccionada_na_rotacao_de_tedio`
(1 chamada), `test_rotacao_de_tedio_percorre_os_3_arcos_por_ordem` (6 chamadas, prova a
ordem fixa `jangada -> sinalizacao -> diario -> jangada -> ...`, repondo TEDIO=70 antes
de cada chamada para isolar a rotação do efeito TEDIO-30 da própria fase "construir" da
jangada) e `test_transita_fases_do_arco_sinalizacao` (4 chamadas com a rotação forçada
a cair sempre em sinalização, prova as 4 fases `decide_fazer_fogo -> reune_madeira ->
acende_fumo -> barco_passa_sem_parar` por ordem).

Log de prova actualizado: `game/tools/arc_smoke.gd` ganhou uma 3a secção dedicada à
sinalização (função nova `_run_isolated_tedio_arc()`, reutilizada também pela secção da
jangada, que passou a usar a mesma técnica de isolamento em vez de alternância natural
com "diário" -- mais simples e focado desde que existem 3 arcos na rotação, não 2). Log
regerado em `docs/proof/T-114-arco.log`, corrido 2x, conteúdo idêntico (reprodutibilidade
confirmada de novo).

**BLOQUEANTE 2 -- falha silenciosa em is_activation_condition_met**

`is_activation_condition_met()` devolve `true` quando o arco não existe no `ArcManager`
(regra documentada: "condição vazia OU arco desconhecido = sempre activável" -- a mesma
regra serve os dois casos porque `_arcs[arc_id].get("condicoes_activacao", {})` de um
arco inexistente também devolve `{}`). `_select_arc()` chamava isto directamente para
"companheiro" sem confirmar primeiro que o arco existia: se `arc_definitions.json`
faltasse ou não parseasse, `_arcs` ficava `{}` e o director passava a devolver
`companheiro` **sempre**, para qualquer SOLIDAO, em silêncio (nenhum erro visível além
do `push_error` do `ArcManager` ao carregar).

Corrigido com uma guarda `has_arc()` antes da pergunta:
`manager.has_arc(ARC_COMPANHEIRO) and manager.is_activation_condition_met(...)`. Não
criei um predicado novo (`should_activate`) como a alternativa sugeria -- a guarda
inline é suficiente e mais simples, mantém `is_activation_condition_met()` com a mesma
semântica documentada (ela não muda; o chamador é que passa a confirmar existência
primeiro).

Teste novo `test_arc_definitions_em_falta_nao_activa_companheiro_em_silencio`: cria um
`ArcManager` apontado a `user://este_ficheiro_nao_existe.json` (`_arcs` fica `{}`),
SOLIDAO=0, e confirma que o arco resultante é `avulso`, nunca `companheiro`. Consome o
`push_error` esperado com `assert_push_error(...)`, mesmo padrão já usado em
`test_phrase_filter.gd:53-59` (senão o GUT reprova o teste por "Unexpected Errors" mesmo
com as asserções a passar).

**Dívida técnica conhecida (não bloqueia esta ronda, registada como pedido)**

- Activity code -> descrição para o prompt: `directive.activity` passa a conter um
  código do catálogo (ex.: `"R13"`) em vez de um verbo pt-PT; quem monta o contexto para
  o LLM (T-115) vai precisar de traduzir o código para texto usando
  `docs/events-catalogue.md` (não há ainda nenhum `Dictionary` code->descrição em
  `game/data/`).
- Seed do `rng` do `SimpleDirector`: por defeito não tem seed fixa (`RandomNumberGenerator.new()`
  sem `.seed =`), só os testes e o `arc_smoke.gd` a fixam explicitamente; em produção o
  comportamento continua não determinístico entre arranques (aceitável para variedade de
  frase/actividade, mas vale registar).
- Mismatch semântico: a fase `decide_fazer_fogo` da Sinalização usa o código `R19`
  ("Sinal de SOS nas Pedras"), que é tecnicamente um método de sinalização diferente
  (pedras, não fogo); é o código mais próximo disponível no catálogo para "decidir
  tentar sinalizar", documentado como aproximação no `_activities_desc` do JSON.
- Cleanup do teste UNICO: os testes `test_arco_unico_*` em `test_arc_manager.gd` escrevem
  e apagam `user://test_arc_unico_tmp.json` manualmente em cada teste (sem `before_each`/
  `after_each` dedicado); funciona mas duplica a lógica de escrita/limpeza 3 vezes.

**Comandos corridos nesta 3a ronda**

- `godot --headless --path game --import`: OK.
- GUT completo: **191 testes, 191 a passar** (4 novos em `test_simple_director.gd`:
  os 3 de rotação/sinalização + o de falha silenciosa; os 187 anteriores continuam
  verdes sem alteração de comportamento).
- `uvx gdformat`/`gdlint` em `simple_director.gd`, `test_simple_director.gd` e
  `arc_smoke.gd`: limpos (gdlint apanhou e corrigi: linha longa, `load()` duplicado em
  vez de `preload()`, argumento de função sem uso).
- `python3 scripts/check_docs.py --fix`: PASSOU.
- `godot --headless --path game -s res://tools/arc_smoke.gd`, corrido 2x: conteúdo
  idêntico (reprodutibilidade confirmada), log gravado em `docs/proof/T-114-arco.log`
  (agora com 3 secções: companheiro, jangada, sinalização).
- `scripts/verify.sh`: **VEREDICTO PASSOU** (docs, backlog 56 tarefas, pytest 49/49,
  lint 98 ficheiros limpos, import, gut 191/191, boot smoke: fome -68.1 pontos,
  deslocação 700 px).

## Fora de âmbito

- Animacoes visuais dos arcos (entram como tarefas `visual` separadas)
- Arcos gerados pela IA (T-115)
- Mais de 3 arcos (restantes entram em V1.x)

## Prova exigida

- Smoke reprodutivel com arco visivel a progredir no log (script commitado + log em
  `docs/proof/`)
- Screenshot de cada fase do arco "A Jangada": adiado. T-114 e' codigo puro, sem
  representacao visual por fase (ver "Fora de ambito"). Fica a cargo da tarefa visual
  que desenhar as animacoes dos arcos (candidata: nova tarefa dependente de T-114,
  ou alargar T-118).

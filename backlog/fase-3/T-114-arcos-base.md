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

## Fora de âmbito

- Animacoes visuais dos arcos (entram como tarefas `visual` separadas)
- Arcos gerados pela IA (T-115)
- Mais de 3 arcos (restantes entram em V1.x)

## Prova exigida

- Smoke de 60s com arco visivel a progredir no log
- Screenshot de cada fase do arco "A Jangada"

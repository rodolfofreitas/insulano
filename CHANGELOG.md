# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.1.0/). Versionamento: SemVer.
Entradas em linguagem de utilizador, não de commit. Cada tarefa acrescenta a sua em `[Não lançado]`.

## [Não lançado]

### Adicionado
- `DrinkCoconutAction` (T-126): naufrago parte um coco e bebe a agua. FOME -10pts ao completar.
  Duracao 5s, cooldown 4h de jogo (240s acelerado). Trigger: SEDE >= 60 ou TEDIO >= 40.
  5 frases fallback categoria `beber_coco` em `game/data/phrases_fallback.json`.
- `JumpTreeAction` (T-127): naufrago trepa a palmeira e salta para o mar. TEDIO -30pts,
  ESPERANCA +5pts ao completar. Duracao 8s, cooldown 1 dia de jogo (1800s). RARO.
  Trigger: TEDIO >= 70. 5 frases fallback categoria `saltar_arvore` em `phrases_fallback.json`.
- 6 testes GUT em `game/tests/unit/test_drink_jump.gd`:
  `test_drink_reduces_hunger`, `test_drink_completes_in_5s`, `test_drink_cooldown_blocks_second_use`,
  `test_jump_reduces_tedio_30pts`, `test_jump_completes_in_8s`, `test_jump_cooldown_1_day`.
- `DanceAction` (T-129): naufrago danca de alegria quando ESPERANCA >= 80.
  Dura 8s, repoe SOLIDAO -10 e TEDIO -20 ao terminar. 5 frases fallback
  categoria `dancar` adicionadas a `game/data/phrases_fallback.json`.
- `ExerciseAction` (T-130): naufrago faz flexoes/abdominais quando TEDIO >= 55.
  Dura 10s, repoe TEDIO -20 ao terminar. 5 frases fallback categoria `exercicio`
  adicionadas a `game/data/phrases_fallback.json`.
- 5 testes GUT em `game/tests/unit/test_dance_exercise.gd`:
  `test_dance_reduces_tedio_20`, `test_dance_reduces_solidao_10`,
  `test_dance_completes_in_8s`, `test_exercise_reduces_tedio_20`,
  `test_exercise_completes_in_10s`.
- `SwimAction` (T-124): naufrago nada no oceano durante 10s quando TEDIO >= 60
  ou hora entre 11h-16h. Repoe TEDIO 20pts e CALOR 15pts (se existir) ao completar.
  CPUParticles2D splash ao entrar na agua. 5 frases fallback categoria `nadar`
  adicionadas a `game/data/phrases_fallback.json`.
- `RunAction` (T-125): naufrago corre pela praia durante 6s quando TEDIO >= 50.
  Repoe TEDIO 15pts ao completar. Mais rapido que andar. 5 frases fallback categoria
  `correr` adicionadas a `game/data/phrases_fallback.json`.
- 4 testes GUT em `game/tests/unit/test_swim_run.gd`:
  `test_swim_reduces_tedio`, `test_swim_completes_in_10s`,
  `test_run_reduces_tedio`, `test_run_completes_in_6s`.
- `ImaginaryCompanion` (T-118): companheiro imaginario com ciclo de vida completo
  (ABSENT -> ALIVE -> MOURNING -> ABSENT). Nasce quando SOLIDAO >= 100, perde-se
  via evento `tide_takes_companion` (MUITO_RARO, peso 1). Nome e objecto aleatorios
  por sessao (nunca "Wilson"). SOLIDAO cai 40pts ao nascer; sobe 30pts e TEDIO 20pts
  ao perder-se. Autoload `Companion`. Evento adicionado a `game/data/events.json`.
  Dados em `companion_names.json` (12 nomes) e `companion_objects.json` (12 objectos).
  7 testes GUT em `game/tests/unit/test_imaginary_companion.gd`.
- `RantAction` (T-128): naufrago xinga o oceano quando TEDIO >= 60 ou ESPERANCA <= 30.
  Dura 4s, pede frase LLM com categoria `furia` via `LLMBridge`. 5 frases fallback
  categoria `furia` adicionadas a `game/data/phrases_fallback.json`.
- `PrayAction` (T-132): naufrago reza ou medita quando ESPERANCA <= 40 ou hora >= 21.
  Dura 6s, chama `NeedsManager.replenish("ESPERANCA", 10)` ao completar. 5 frases
  fallback categoria `reza` adicionadas a `game/data/phrases_fallback.json`.
  3 testes GUT em `game/tests/unit/test_rant_pray.gd`.
- `WaveAction` (T-131): naufrago acena quando `Events.event_started` emite 'boat'
  ou 'seagull'; dura `WAVE_DURATION = 5s`, devolve RUNNING durante a acenagem e
  SUCCESS no fim. Frases fallback categoria `acenar` (5 frases PT-PT) em
  `phrases_fallback.json`.
- `HumAction` (T-133): naufrago cantarola autonomamente durante `HUM_DURATION = 8s`;
  trigger sem evento externo (usar TEDIO >= 50 na arvore). Frases fallback categoria
  `cantarolar` (5 frases PT-PT) em `phrases_fallback.json`.
- 4 testes GUT em `game/tests/unit/test_wave_hum.gd`:
  `test_wave_triggers_on_boat_event`, `test_wave_triggers_on_seagull_event`,
  `test_wave_completes_in_5s`, `test_hum_completes_in_8s`.
- `LLMDirector` gera arcos originais via Ollama (T-117): quando TEDIO >= 65,
  nenhum arco activo e pelo menos 1 dia desde o ultimo arco, o director pede
  ao Ollama um arco novo com prompt que inclui titulos de arcos ja completados
  (para nao repetir), objectos na ilha (palmeira, pedras, madeira, coco, peixe,
  fogueira), estado actual do naufrago (dias, needs, hora) e instrucao de
  formato JSON `{titulo, tipo, fases: [{nome, actividade, duracao_ciclos}],
  necessidade_que_sobe}`. O arco e validado (`_validate_arc`): titulo nao
  vazio, >= 2 fases com `nome` e `actividade`, titulo nao repetido em
  `ArcHistory` (case-insensitive). Se valido: entra em `_arc_definitions_extra`
  e em `ArcHistory.active_arc` com `origem="llm"`. Se invalido: `SimpleDirector`
  escolhe arco base como fallback. 7 testes GUT novos em
  `game/tests/unit/test_llm_arc_generation.gd`.
- `MakeCampfireAction` e `CookFishAction` (T-120): ritual completo de cozinhar o peixe.
  O naufrago nunca come peixe cru: `FishingAction` define `blackboard["has_fish"]=true` em
  vez de repor fome directamente; `MakeCampfireAction` recolhe lenha (~3s) e accende a
  fogueira (~2s, instancia `CampfireObject`); `CookFishAction` assa (~8s) e come com
  `hunger.increase_percent(60)` -- o dobro do comportamento anterior.
  `SessionData.record_fish_caught()` e agora chamado pelo `CookFishAction` (so conta peixes
  comidos, nao crus).
- `CloudLayer` com parallax de 5 camadas (T-134): `ParallaxBackground` na cena principal com
  `NightSky` (estrelas/lua, Z=0), `CloudLayer` (nuvens, Z=1), horizonte, ilha e naufrago.
  As nuvens movem-se da direita para a esquerda a 15 px/s e fazem wrap ao sair do ecra.
  Alpha 0.7 de dia (6h-20h) e 0.2 de noite, ligado ao sinal `Clock.hour_changed`.
  Cada nuvem e desenhada com 3 circulos sobrepostos (sem dependencias de sprites).
  3 testes de integracao novos: movimento, wrap-around e alpha dia/noite.
- `GameClock` modo acelerado (T-123): em modo screensaver, o ciclo de dia dura 30 minutos
  reais (48x mais rapido), ancorado na hora real de arranque -- abrir as 22h coloca o jogo
  na hora de jogo 22h, e 15 minutos depois (real) e meia-noite de jogo. Em modo janela o
  comportamento anterior e mantido (hora real directa). `INSULANO_FAKE_TIME` continua a
  funcionar. Constante `GAME_DAY_DURATION_S = 1800.0` e metodo `_activate_accelerated_mode()`
  adicionados ao autoload `Clock`.
- `CampfireObject` (T-119): fogueira visual com `CPUParticles2D` para chamas (laranja/amarelo)
  e fumo (cinzento), e `PointLight2D` nocturno. `ignite()` acende e emite sinal `lit`;
  `extinguish()` apaga e emite `extinguished`. Luz activa apenas de noite (via `Clock.period()`
  -- periodos `noite`, `madrugada`, `anoitecer`). Instanciado na cena de teste perto do local
  de pesca (posicao 300, 340).
- `LLMDirector` (T-115): director narrativo via Ollama que substitui o `SimpleDirector`
  através do contrato `IDirector` (`get_directive`/`is_available`, mesma interface).
  Um único pedido ao Ollama por ciclo (`LLM.request_completion`, novo método do
  `LLMBridge` com o sinal `completion_ready`, ao lado de `request_phrase`) devolve JSON
  `{arc, activity, phrase}`, validado contra o schema (arco tem de ser um dos 5 do
  `SimpleDirector`, `activity` não vazia, `phrase` do tipo certo); qualquer falha --
  rede, timeout, JSON inválido ou schema inválido -- cai no `SimpleDirector` injectado,
  nunca deixa o jogo sem directiva. Ciclo event-driven, disparado por
  `trigger_cycle(reason)` com um dos três gatilhos (`activity_completed`,
  `need_threshold_crossed`, `session_start`), nunca por poll; um ciclo já em curso
  ignora pedidos novos. Contexto enviado: dia, hora, estação (hemisfério norte),
  necessidades, arco activo, 5 títulos de arcos recentes, companheiro (sempre `null`
  até à T-118) e último evento livre. Prompt em
  `game/data/prompts/director_prompt.txt`, memória das últimas 10 decisões em
  `user://director_memory.json` com escrita atómica (tmp + rename, mesmo padrão de
  `arc_history.gd`).
- `ArcManager` e `arc_definitions.json` (T-114): máquina de estados de fases para os 3
  arcos base, com actividades ligadas aos códigos reais de `docs/events-catalogue.md`
  (ex.: `R13`, `MR26`, `C16`, `MR06`, `L05`, `MR01`). "A Jangada" (5 fases CICLICO:
  `encontra_madeira` -> `construir` -> `cerimonia_lancamento` -> `afunda` ->
  `devastacao`; ESPERANCA +30 na 1a fase, TEDIO -30 em `construir`, ESPERANCA -40 na
  fase `afunda`). "O Companheiro" (4 fases CICLICO, condição de activação SOLIDAO >=
  70, agora verificada por `ArcManager.is_activation_condition_met`, sem duplicar o
  limiar no `SimpleDirector`). "A Sinalização" (4 fases CICLICO; ESPERANCA -20 na
  fase `barco_passa_sem_parar`). `ArcManager.advance_phase(arc_id, needs_manager)`
  aplica os efeitos da fase actual e avança o índice, voltando a 0 após a última fase
  em arcos CICLICO; arcos UNICO ficam parados no último índice e `is_finished(arc_id)`
  passa a `true` (sem reciclar nem reaplicar efeitos). `SimpleDirector` (T-111) passa a
  delegar no `ArcManager` quando o arco escolhido tem definição: usa uma actividade da
  fase actual em vez da actividade fixa de `simple_director_phrases.json` e expõe
  `fase_id`/`fase_index` na directiva; a escolha de frase e de actividade usa agora um
  `RandomNumberGenerator` injectável (`director.rng`), costura de teste para
  determinismo (AGENTS.md §6.6). Prova reproduzível em
  `game/tools/arc_smoke.gd` (`godot --headless --path game -s
  res://tools/arc_smoke.gd`), log gravado em `docs/proof/T-114-arco.log` (3 secções:
  companheiro, jangada, sinalização). `SimpleDirector._select_arc()` alterna os 3 arcos
  sem condição própria (jangada, sinalização, diário) por rotação determinística
  (`TEDIO_ROTATION`) quando TEDIO está alto -- a sinalização estava declarada mas nunca
  era seleccionada; e passa a confirmar `arc_manager.has_arc("companheiro")` antes de
  perguntar `is_activation_condition_met`, para um `arc_definitions.json` em falta não
  activar o companheiro sempre, em silêncio, para qualquer SOLIDAO.
- `AmbientAudio` (T-504): sons ambiente CC0 da ilha. `ocean_waves.ogg` toca em loop continuo sempre (volume -6dB). `wind_breeze.ogg` entra em loop quando `Weather.current()` e `clouds`, `rain` ou `storm`. `rain_storm.ogg` loop em `rain` ou `storm`. `seagulls.ogg` dispara com `Events.event_started('seagull')` e para com `Events.event_finished('seagull')` (sem loop). Setting `insulano/audio/enabled` (defeito `true`) e `insulano/audio/volume_db` (defeito 0.0) controlam o som globalmente. Todos os sons CC0 registados em `docs/assets-licencas.md`, aprovados pelo Rodolfo antes do download.
- `CreditsScreen` (T-503): ecra de creditos com atribuicoes obrigatorias de todos os assets e bibliotecas. Gerado a partir de `game/data/credits.json` com as entradas: sprites do personagem (Antifarea e Clint Bellanger, CC-BY 3.0), tileset Tiny Islands (Majadroid, CC0), codigo base Guy on Island (Doubi, MIT), Godot Engine (Juan Linietsky e Ariel Manzur, MIT), Beehave (bitbrain, MIT), GUT (bitwes, MIT). Aparece ao arrancar com `-- --credits`, ou automaticamente durante 5s no inicio de cada hora em modo screensaver. Instanciado na cena principal como `CreditsScreen` (CanvasLayer, layer 10). Prova visual em `docs/proof/T-503-creditos.png`.
- Export Windows reproduzivel (T-507): `scripts/export.sh` exporta agora `dist/windows/insulano.exe` (PE32+ x86_64, ~105 MiB) em sequencia apos o Linux, com saida INDETERMINADO (exit 3) quando os templates Windows faltam. Runbook actualizado com comandos de export, teste via Wine e teste via VM QEMU (dockurr/windows). Arranque em Windows nao verificado nesta sessao (Wine nao instalado, VM nao iniciada); exe validado como PE32+ valido.
- `Screensaver` (T-501): autoload que configura o modo de execucao por argumentos de linha de comandos. `--screensaver` (ou `-s`): janela em ecra inteiro, cursor escondido, delega deteccao de input ao `InputWatcher` em modo screensaver. `--windowed` (ou `-w`): janela normal. `--credits`: reservado para a cena de creditos (T-503). Sem argumentos o modo por omissao e `window`. A funcao `_parse_from(args)` e publica para facilitar testes unitarios sem abrir janela real. Registado como autoload `Screensaver` em `project.godot`.
- `HolidayCalendar` (T-401): calendario de feriados com funcoes estaticas puras. `easter_sunday(year)` calcula o Domingo de Pascoa pelo algoritmo de Meeus/Butcher (devolve `{year, month, day}`). `holidays_on(date)` devolve a lista de feriados activos nessa data, suportando datas fixas (`rule.type=fixed`) e datas moveis relativas a Pascoa (`rule.type=easter`, `offset_days`). Feriados carregados de `game/data/holidays.json`. Entradas com `rule.type` desconhecido sao ignoradas com `push_warning`, sem crashar.
- `HolidayScenes` (T-402): cenas de Natal e Ano Novo. Em 24 e 25 de Dezembro o naufrago usa gorro vermelho com pompom e a ilha exibe estrelas decorativas desenhadas em codigo. Na vespera de Ano Novo (31 Dez) e no Ano Novo (1 Jan), a partir das 20h, `CPUParticles2D` dispara fogos de artificio com cores variadas; de dia os fogos estao desligados. Em qualquer feriado o campo `holiday` do `PhraseContext` e preenchido com o nome do feriado. Instanciado na cena principal como `HolidayScenes`. Provas visuais em `docs/proof/T-402-*.png`.
- `Boat` (T-303): barco que atravessa o horizonte (y=30% do viewport) da direita para a esquerda quando o EventDirector lanca o evento `boat`. Visual desenhado em codigo GDScript (`_draw()`) com casco (rectangulo castanho), mastro (linha) e vela (triangulo creme), sem assets novos. O naufrago para ate 5s a olhar o barco e diz uma frase da categoria `boat` (fallback com 5 frases PT-PT: acenamento desesperado, ironia, planos). Autoload `Events` registado em `project.godot`. `events.json` actualizado com kind `boat` (peso 8, intervalo 600s, duracao 12s). Instanciado na cena principal como `BoatEvent`. Prova visual em `docs/proof/T-303-barco.png`.
- `SeagullEvent` (T-302): gaivota que atravessa o ecra quando o EventDirector lanca o evento `seagull`. Visual desenhado em codigo GDScript (`_draw()`, CC0) com animacao de bater asas via `_process`. O naufrago comenta com frase pedida ao LLM (contexto `action="ver uma gaivota a passar"`, fallback categoria `seagull`). Instanciado na cena principal. Frases de fallback PT-PT existentes em `phrases_fallback.json` (5 frases na categoria `seagull`). Asset registado em `docs/assets-licencas.md`.

### Adicionado
- `Rain` (T-305): chuva com `CPUParticles2D` que liga quando `Weather.current()` e `rain` ou `storm` e desliga nas outras condicoes. Storm tem 300 particulas, rain tem 150. Angulo quase vertical com ligeiro desvio para a direita, cor azul transparente (`#aaccff`, alpha=0.4). Ao comecar a chover o naufrago diz uma frase da categoria `rain`. `INSULANO_FAKE_WEATHER` forca a condicao sem rede (documentado no runbook). Instanciado na cena principal.
- `EventDirector` (T-301): director de eventos aleatorios registado como autoload `Events`. Agenda eventos avulsos (gaivota, barco, tartaruga, etc.) com pesos configurados em `game/data/events.json`. Seed reprodutivel via setting `insulano/events/seed` (0 = aleatorio; outro valor = determinista). Garante que nunca ha dois eventos do mesmo `kind` activos em simultaneo e respeita `min_interval_s` entre ocorrencias do mesmo tipo. Com config em falta ou invalida o director fica inactivo e regista `push_warning`, sem crashar o jogo.
- `IsNightCondition` e `SleepAction` (T-203): naufrago cansa-se 0.5%/s acordado e recupera 2.0%/s a dormir. Behavior tree do Guy tem ramo de dormir com prioridade maxima: de noite (ou energia < 20%) o personagem para e recupera energia. `IsNightCondition` usa `Clock.period()` para detectar "noite" e "madrugada". `SleepAction` mantem RUNNING enquanto energia < 100 ou e noite, e devolve SUCCESS quando recuperado e ja e dia.
- Necessidade `energy` (T-203): adicionada ao Guy (max 100, inicial 100), desce a `standard_energy_decrease=0.5`%/s via `Guy._process`.
- `ArcHistory` (T-113): persistencia de arcos entre sessoes em `user://arc_history.json`. Escrita atomica (write-to-tmp + rename) para evitar corrupcao em caso de crash. Limite de 50 arcos completados (descarta os mais antigos). `schema_version=1` com reset gracioso em caso de mismatch ou JSON invalido (push_warning + estado vazio, sem crash). `get_recent_titles(n)` para contexto do LLM. Registado como autoload `ArcHistory`.
- `NightSky` (T-204): ceu nocturno com 60 estrelas e lua desenhados em codigo com `_draw()`, sem assets novos. Opacidade varia com a hora: 0 entre as 07h-18h, 1 entre as 21h-05h, interpolado no crepusculo. Seed fixa (42) garante posicoes identicas entre arranques. Instanciado antes de `DayNight` na cena principal para ficar atras de tudo (`z_index = -10`).
- `SimpleDirector` (T-111): director deterministico sem LLM com maquina de estados de 5 arcos (jangada, companheiro, sinalizacao, diario, avulso). Transicoes baseadas nos thresholds do NeedsManager (SOLIDAO>=70 -> companheiro, TEDIO>=65 -> jangada/diario alternados, ESPERANCA<=25 -> avulso). Frases PT-PT em `game/data/simple_director_phrases.json` (10 por arco), sem repeticao imediata. `is_available()` devolve sempre true -- sem dependencia de Ollama. Satisfaz o contrato IDirector por duck typing.
- `DayNight` (T-202): ciclo dia/noite via `CanvasModulate`. Interpola linearmente entre 13 pontos de `game/data/day_night_palette.json` (madrugada azul-escura ate luz quente de manha, por-do-sol em tons laranjas, noite profunda apos as 22h). Transicao suave (lerp a 2.0/s). Instanciado na cena principal.
- `InputWatcher` (T-112): autoload que detecta presenca do utilizador (rato, teclado, clique) e emite sinal `presence_detected` com tipo (suave/brusco/clique/tecla). Acumula delta de rato em 3 frames com minimo de 6px para evitar jitter do Wayland. Em modo `--screensaver` fecha apos 150ms de graca para animacao de reaccao; em modo `--window` nunca fecha por input.
- `GameClock` (T-201): autoload `Clock`, fonte unica da hora do sistema. API publica: `now()`, `hour_float()`, `period()`, `signal hour_changed`. Suporta override via variavel de ambiente `INSULANO_FAKE_TIME` (formato `AAAA-MM-DDTHH:MM`) e setting `insulano/debug/fake_time`, sem mexer no relogio da maquina. Valor invalido regista aviso e usa hora real.

## [0.1.0] - 2026-09-14

### Adicionado
- Projecto jogável em `game/`, a partir do Guy on Island, a correr em Godot 4.7.2.
- Portão de verificação único (`scripts/verify.sh`): documentação, backlog, lint, testes, arranque, imagem, LLM e export.
- Export templates 4.7.2 instalados e export Linux provado: `scripts/export.sh` produz
  `dist/linux/insulano.x86_64` e o binário arranca sem `SCRIPT ERROR`, `Parse Error` nem
  `Failed to load script` (os três padrões vigiados pelo portão), tanto headless (600 frames)
  como em modo janela real na sessão Hyprland (10 s, sem crash). Uma regressão latente exposta
  por esta corrida (erro de motor `TypedArray`/`erase`, fora dos três padrões vigiados) ficou
  registada na T-006, ainda não corrigida (fora do âmbito desta entrada).
- Testes automáticos: 20 testes GUT, 40 testes dos scripts, smoke de arranque de 30 s simulados.
- Captura de ecrã real de tamanho fixo, para provas visuais.
- Eval das frases do LLM local (latência, português de Portugal, comprimento, conteúdo proibido).
- Backlog de 33 tarefas em 6 fases, com critérios de aceitação verificáveis.
- Harness para agentes: AGENTS.md, tech design com contratos, agentes e skills do Claude Code.
- `LLMSettings` (T-101): leitura única das chaves `insulano/llm/*` (activo, URL, modelo, timeout,
  intervalo mínimo), com defeitos em `project.godot`, sobreposição por `user://settings.cfg` e,
  só para o URL, pela variável de ambiente de teste `INSULANO_LLM_URL`.
- `PhraseContext` e `PromptBuilder` (T-102): contexto tipado da situação do náufrago e montagem do
  prompt a partir de `game/data/prompts/phrase_prompt.txt`, com paridade carácter a carácter provada
  contra `scripts/llm_eval.py` (fixture `game/tests/fixtures/prompt_tarde_pescar.txt`, gerada pelo
  Python real). Contexto incompleto nunca produz um prompt com `{campo}` por preencher: devolve `""`
  e regista erro.
- `PhraseFilter` (T-103): aceita ou rejeita frases geradas pelo LLM, com regras lidas de
  `game/data/phrase_rules.json` (nunca hard-coded) e paridade total com `scripts/llm_eval.py`,
  provada contra a fixture partilhada `game/tests/fixtures/phrase_filter_cases.json` em ambos os
  lados (GUT e pytest, com casos de sobreposição de motivos e de NBSP para guardar a ordem de
  verificação e a contagem de palavras). Mesma ordem de verificação do Python: empty, english,
  ptbr, forbidden, too_short, too_long, mais o sétimo valor `rules_missing` (sem equivalente no
  Python), quando `phrase_rules.json` falta ou tem JSON inválido: o filtro falha FECHADO,
  `rejection_reason()` rejeita sempre, nunca aceita por omissão. Padrões
  `english_patterns`/`ptbr_patterns` e a contagem de palavras (`\S+`) compilados com o verbo PCRE2
  `(*UCP)`, para o `(?i)` inline ignorar maiúsculas também em acentuados (ex. `VOCÊ`, `TÔ`) e para
  o NBSP (U+00A0) contar como separador de palavra, como já fazia o Python (`re.IGNORECASE` e
  `str.split()`).
- `FallbackPhrases` (T-104): frases fixas em português de Portugal para quando o Ollama não
  responde, lidas de `game/data/phrases_fallback.json` (nunca hard-coded), com as categorias
  `idle`, `fishing`, `eating`, `morning`, `night`, `rain`, `seagull` e `boat`, cada uma com pelo
  menos 4 frases. `pick()` nunca repete de imediato a frase anterior da mesma categoria e uma
  categoria desconhecida cai sempre em `idle`. Todas as frases de fallback passam o mesmo
  `PhraseFilter` (T-103) que valida as frases geradas pelo LLM: um náufrago sem rede fala tão bem
  como um náufrago com Ollama.
- `LLMBridge` (T-105), autoload `LLM`: ponte assíncrona única com o Ollama, com `HTTPRequest` filho
  (nunca bloqueia um frame) e o sinal `phrase_ready(request_id, text, source)` emitido exactamente
  uma vez por pedido, sempre, mesmo em erro. Um só pedido de cada vez: um pedido novo com outro em
  curso responde já com fallback, sem tocar no pedido em curso. `settings.enabled = false` nunca
  cria o `HTTPRequest` filho. Qualquer falha (rede, timeout, HTTP diferente de 200, JSON inválido,
  resposta vazia ou frase rejeitada pelo `PhraseFilter`) cai no fallback garantido de
  `FallbackPhrases` (T-104). Log `[Insulano/LLM]` com modelo, latência e motivo de fallback, nunca
  o prompt inteiro. Teste ao vivo em `game/tests/live/test_llm_live.gd` (fora do
  `.gutconfig.json`, só corre com `scripts/verify.sh --llm`): marca-se `pending()` em vez de falhar
  quando o Ollama não responde nesta máquina.
- `SayGeneratedAction` (T-106): substitui todos os `TalkAction` fixos em inglês da árvore herdada
  por uma acção que pede uma frase à ponte `LLM` (ou ao fallback garantido) e fala sempre em
  português de Portugal. Lê `current_action` do blackboard, agora escrito por `FishingAction`
  ("pescar"), `UseUsableAction` ("comer"), `WatchOceanAction` ("observar o oceano") e, pelas três
  instâncias de `GoToUsableAction.current_action_label` em `guy.tscn`, "ir comer" (a caminho de
  comer), "ir pescar" (a caminho da pesca) e "passear" (sequência de passear): sem isto, a frase
  dita antes de comer ou pescar podia usar o verbo deixado pela sequência anterior. Respeita
  `LLMSettings.min_interval_s` partilhado entre todas as instâncias via `say_last_at_s` no
  blackboard (provado por mutação: um relógio por instância deixaria os 6 nós falar em sequência
  sem esperar pelos outros); quando o intervalo bloqueia, nunca toca em `talking_text` (nem para
  falar nem para o limpar: desde a T-107 quem manda no desaparecimento do balão é o `SpeechBubble`).
  Ignora `phrase_ready` com o
  `request_id` de outro pedido. Trata a resposta síncrona do `LLMBridge` (ponte desligada, pedido
  concorrente ou prompt vazio) ligando o sinal `phrase_ready` antes de chamar `request_phrase`,
  para nunca perder esse caso e ficar `RUNNING` para sempre. `interrupt()` esquece o pedido em
  curso, para uma resposta tardia de um pedido interrompido nunca falar sobre um contexto que já
  não é o actual. Relógio (`Time.get_ticks_msec` por defeito) injectável via `clock: Callable`,
  para os testes controlarem o tempo sem esperar segundos reais. `boot_smoke.gd` alargado para 90 s
  simulados e confirma que o náufrago diz pelo menos uma frase de `phrases_fallback.json` com
  `INSULANO_LLM_URL` apontado para uma porta morta (agora também passado por `scripts/verify.sh`,
  determinístico e sem depender de um Ollama real a responder).
- `SpeechBubble` (T-107): substitui o `Label` simples do balão de fala por um `PanelContainer` com
  fundo branco opaco e texto quase preto (contraste 18,4:1 pela luminância relativa WCAG, acima do
  mínimo de 4,5:1 pedido), com fundo opaco para se ler sobre qualquer fundo da ilha. Largura máxima de 220 px do mundo com
  quebra de linha automática, para uma frase de 15 palavras nunca sair do ecrã. Passa a ser este nó,
  e não a `SayGeneratedAction`, a decidir quanto tempo uma frase fica visível:
  `clamp(2.5 + 0.35 * palavras, 3, 9)` segundos, com o mínimo (3 s) igual a
  `SayGeneratedAction.MIN_VISIBLE_S`. `SayGeneratedAction.tick()` só pede uma frase nova depois de
  `maxf(min_interval_s, MIN_VISIBLE_S)`, nunca de `min_interval_s` sozinho: assim a garantia de
  "nenhuma frase visível menos de 3 s" vale para qualquer valor configurado em
  `user://settings.cfg`, incluindo 0 (bloqueante da revisão, ronda 1). Provado com
  `docs/proof/T-107-balao-1080p.png` e `docs/proof/T-107-balao-1600p.png`.

### Alterado
- Frases do náufrago afinadas (T-108): o filtro passa a rejeitar a próclise brasileira com verbos
  como poder, dever, querer, ir e conseguir (ex. "pode me ajudar", "vou me deitar"), com casos de
  teste para não rejeitar português de Portugal válido como "o barco que me leve" ou "vai se
  calhar chover"; e o prompt passa a descrever o que existe numa ilha deserta, para reduzir
  animais de quinta e objectos impossíveis nas frases. Eval de referência de 2026-09-14: 40
  amostras, todas aceites pelo filtro, latência mediana de 3 s.
- Renderer passa a Compatibility (OpenGL 3): mais leve para um protector de ecrã 2D.
- Feriados passam de YAML para JSON, com Carnaval e Páscoa calculados a partir da data da Páscoa.
- Modelo por defeito passa a `llama3.1:8b`, o único instalado, com limiares de latência medidos.
- Addon Beehave actualizado de 2.8.3 para 2.9.3 (código de `gh release download v2.9.3 -R bitbrain/beehave`):
  correcções internas de interrupção de árvore e sanitização do blackboard para o depurador, sem
  mudança de comportamento visível nem de contrato para as folhas próprias em `game/beehave/`.

### Corrigido
- Documentação que indicava modelos, versões e endpoints que não correspondiam à máquina real.
- Lint, formatação e documentação dos 21 ficheiros de GDScript herdados do Guy on Island
  (`scripts/gd_baseline.txt` fica vazia): cabeçalhos e docstrings novos, variáveis exportadas
  `fishingRod`, `searchArea` e `navigationAgent` renomeadas para `snake_case` (cenas actualizadas),
  sem alterar o comportamento do jogo.
- Seis bugs latentes do código herdado, cada um com teste de regressão (`test_regression_<bug>`):
  `search_area.body_exited` ligava ao handler errado e os objectos nunca saíam de
  `objects_in_area`; `NeedReplentishingUsable.get_satisfying_needs()` rebentava com
  `max_replentish_value == 0`; `FundUsableForNeedCondition` devolvia `FAILED` (erro global) em
  vez de `FAILURE` quando não havia objectos; `SetDeltaOnBlackboardAction` imprimia o delta a
  cada tick; `FishingAction.spawn_fish` usava um índice `-1` que apanhava o filho errado quando
  o personagem era o primeiro filho do pai; `fishing_spot.gd` desenhava o círculo de debug
  também fora do editor.
- Erro de motor `TypedArray`/`erase` (T-006): `FundUsableForNeedCondition._body_exited_area`
  chamava `objects_in_area.erase(body)` sem confirmar `body is UsableObject`, o que disparava
  `ERROR: Attempted to erase an object into a TypedArray` sempre que um corpo qualquer (não
  `UsableObject`) saía da área de busca. Regressão exposta pela T-004 depois da T-003 ligar o
  sinal correcto; corrigida com a mesma guarda de tipo que `_body_entered_area` já usava.

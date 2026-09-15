extends GutTest
## Testes de integração de [LLMDirector] (T-115): ciclo event-driven, uma
## chamada por ciclo, validação de schema, fallback para SimpleDirector e
## memória de decisões. Nunca fala com um Ollama real: usa um FakeBridge que
## satisfaz o mesmo contrato de LLMBridge (sinal completion_ready, método
## request_completion) e cujos testes emitem a resposta à mão, tal como
## test_llm_bridge.gd usa DEAD_URL para forçar fallback sem rede
## (agent_docs/testing.md:16-17). "Mock HTTP" aqui é mockar a ponte, não o
## socket: LLMDirector nunca abre o próprio HTTPRequest (AGENTS.md §6.2,
## code_patterns.md §6, "só LLMBridge e WeatherService criam HTTPRequest").

const MEMORY_TEST_PATH := "user://test_director_memory.json"
const MEMORY_TEST_TMP_PATH := "user://test_director_memory.tmp.json"


## Ponte falsa: guarda o último prompt pedido e nunca responde sozinha; o
## teste decide quando e o quê emitir em completion_ready.
class FakeBridge:
	extends Node
	signal completion_ready(request_id: int, raw_text: String, source: String)
	var next_request_id: int = 1
	var requested_prompts: Array = []
	var request_count: int = 0

	func request_completion(
		prompt: String, _num_predict: int = -1, _timeout_s: float = -1.0
	) -> int:
		request_count += 1
		requested_prompts.append(prompt)
		var id := next_request_id
		next_request_id += 1
		return id


## NeedsManager falso, mesmo padrão de arc_smoke.gd (FakeNeeds): dicionário
## simples em vez do autoload real.
class FakeNeeds:
	extends Node
	var _values: Dictionary = {"SOLIDAO": 40.0, "TEDIO": 30.0, "ESPERANCA": 55.0}

	func get_value(n: String) -> float:
		return _values.get(n, 0.0)

	func set_value(n: String, v: float) -> void:
		_values[n] = v

	func get_snapshot() -> Dictionary:
		return {"SOLIDAO": {"value": _values["SOLIDAO"]}, "TEDIO": {"value": _values["TEDIO"]}}


func _make_director() -> LLMDirector:
	var director := LLMDirector.new()
	var needs := FakeNeeds.new()
	add_child_autofree(needs)
	director.needs_manager = needs
	director.memory_path = MEMORY_TEST_PATH
	add_child_autofree(director)
	return director


func before_each() -> void:
	for path in [MEMORY_TEST_PATH, MEMORY_TEST_TMP_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func after_each() -> void:
	for path in [MEMORY_TEST_PATH, MEMORY_TEST_TMP_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_get_directive_antes_de_qualquer_ciclo_cai_no_simple_director() -> void:
	var director := _make_director()

	var directive := director.get_directive()

	assert_not_null(directive)
	assert_true(director.is_available())


func test_trigger_cycle_com_resposta_valida_actualiza_a_directiva_e_regista_memoria() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	var received: Array = []
	director.directive_ready.connect(
		func(directive: DirectorDirective, source: String) -> void:
			received.append({"directive": directive, "source": source})
	)

	director.trigger_cycle(LLMDirector.TRIGGER_SESSION_START)
	assert_eq(bridge.request_count, 1, "1 única chamada ao LLM por ciclo")
	assert_true(director.is_thinking())

	var raw := (
		'{"arc": "companheiro", "activity": "conversar com o companheiro", '
		+ '"phrase": "Boa companhia hoje."}'
	)
	bridge.completion_ready.emit(1, raw, "llm")

	assert_false(director.is_thinking())
	assert_eq(received.size(), 1)
	assert_eq(received[0]["source"], "llm")
	assert_eq(received[0]["directive"].arc_id, "companheiro")
	assert_eq(director.get_directive().arc_id, "companheiro")
	assert_eq(director.get_directive().phrase_context_extra.get("phrase"), "Boa companhia hoje.")

	# Memória persistida (atómica) em memory_path.
	assert_true(FileAccess.file_exists(MEMORY_TEST_PATH))
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MEMORY_TEST_PATH))
	var decisoes: Array = saved.get("decisoes_recentes", [])
	assert_eq(decisoes.size(), 1)
	assert_eq(decisoes[0]["arc"], "companheiro")
	assert_eq(decisoes[0]["source"], "llm")


func test_trigger_cycle_com_garbage_cai_no_fallback_simple_director() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	var received: Array = []
	director.directive_ready.connect(
		func(directive: DirectorDirective, source: String) -> void:
			received.append({"directive": directive, "source": source})
	)

	director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
	bridge.completion_ready.emit(1, "isto nao e JSON {{{", "llm")

	assert_engine_error("error != Error::OK")
	assert_false(director.is_thinking())
	assert_eq(received.size(), 1)
	assert_eq(received[0]["source"], "fallback")
	assert_not_null(received[0]["directive"])


func test_trigger_cycle_com_timeout_cai_no_fallback_simple_director() -> void:
	# Mesma combinação que LLMBridge emite num timeout/erro de rede:
	# raw_text = "" e source = "fallback" (ver _resolve_completion).
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	var received: Array = []
	director.directive_ready.connect(
		func(directive: DirectorDirective, source: String) -> void:
			received.append({"directive": directive, "source": source})
	)

	director.trigger_cycle(LLMDirector.TRIGGER_NEED_THRESHOLD)
	bridge.completion_ready.emit(1, "", "fallback")

	assert_false(director.is_thinking())
	assert_eq(received.size(), 1)
	assert_eq(received[0]["source"], "fallback")


func test_trigger_cycle_concorrente_ignora_pedido_novo_enquanto_pensa() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	director.trigger_cycle(LLMDirector.TRIGGER_SESSION_START)
	director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
	director.trigger_cycle(LLMDirector.TRIGGER_NEED_THRESHOLD)

	assert_eq(bridge.request_count, 1, "um ciclo em curso ignora novos disparos até terminar")

	bridge.completion_ready.emit(
		1, '{"arc": "diario", "activity": "escrever no diario", "phrase": "Mais um dia."}', "llm"
	)
	assert_false(director.is_thinking())

	director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
	assert_eq(bridge.request_count, 2, "depois de terminar, um novo trigger volta a chamar o LLM")


## Bloqueante da ronda 3 (revisão insulano-reviewer): prova que _resolve()
## chama mesmo o PhraseFilter, não só que o filtro em si funciona (isso já
## está coberto em test_phrase_filter.gd). Sem as duas linhas de
## game/llm/llm_director.gd que aplicam o filtro (raw_phrase / phrase_context_extra
## = _filter_phrase(...)), este teste falhava porque a frase PT-BR passava
## intacta. Caso "Você viu o barco?" vem de
## game/tests/fixtures/phrase_filter_cases.json (reason=ptbr, clean == raw): o
## mesmo padrão de gerúndio/pronome brasileiro apanhado ao vivo no ciclo 07 de
## docs/proof/T-115-director-live-ronda2.log.
func test_trigger_cycle_frase_ptbr_e_rejeitada_pelo_filtro_sem_perder_arc_activity() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	var received: Array = []
	director.directive_ready.connect(
		func(directive: DirectorDirective, source: String) -> void:
			received.append({"directive": directive, "source": source})
	)

	director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
	var raw := '{"arc": "diario", "activity": "escrever no diario", "phrase": "Você viu o barco?"}'
	bridge.completion_ready.emit(1, raw, "llm")

	assert_false(director.is_thinking())
	assert_eq(received.size(), 1)
	# (b) fonte continua "llm": só a frase falhou, não a decisão inteira.
	assert_eq(received[0]["source"], "llm")
	var directive: DirectorDirective = received[0]["directive"]
	# (c) arc/activity continuam os do JSON original, intocados pelo filtro.
	assert_eq(directive.arc_id, "diario")
	assert_eq(directive.activity, "escrever no diario")
	# (a) phrase rejeitada fica vazia, nunca a frase original em PT-BR.
	assert_eq(directive.phrase_context_extra.get("phrase"), "")
	assert_eq(director.get_directive().phrase_context_extra.get("phrase"), "")


## Contraprova de aceitação: uma frase PT-PT válida (mesma fixture
## partilhada, reason=null) atravessa _resolve() sem alteração.
func test_trigger_cycle_frase_ptpt_valida_atravessa_o_filtro_sem_alteracao() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	var received: Array = []
	director.directive_ready.connect(
		func(directive: DirectorDirective, source: String) -> void:
			received.append({"directive": directive, "source": source})
	)

	director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
	var raw := '{"arc": "avulso", "activity": "observar o mar", "phrase": "O mar está calmo hoje."}'
	bridge.completion_ready.emit(1, raw, "llm")

	assert_eq(received.size(), 1)
	assert_eq(received[0]["source"], "llm")
	assert_eq(received[0]["directive"].phrase_context_extra.get("phrase"), "O mar está calmo hoje.")


func test_memory_guarda_no_maximo_10_decisoes_mais_recentes() -> void:
	var director := _make_director()
	var bridge := FakeBridge.new()
	add_child_autofree(bridge)
	director.bridge = bridge

	for i in range(12):
		director.trigger_cycle(LLMDirector.TRIGGER_ACTIVITY_COMPLETED)
		var raw := (
			'{"arc": "diario", "activity": "escrever no diario %d", "phrase": "dia %d"}' % [i, i]
		)
		bridge.completion_ready.emit(bridge.next_request_id - 1, raw, "llm")

	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MEMORY_TEST_PATH))
	var decisoes: Array = saved.get("decisoes_recentes", [])
	assert_eq(decisoes.size(), 10)
	assert_eq(decisoes[-1]["activity"], "escrever no diario 11")

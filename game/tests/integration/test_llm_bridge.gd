extends GutTest
## Testes de integração de [LLMBridge]: sinais, timing e concorrência
## (tech_design.md §4.5). Nunca fala com um Ollama real: usa
## INSULANO_LLM_URL ou LLMSettings.url apontados para uma porta morta
## (127.0.0.1:9, "connection refused" quase instantâneo) para forçar o
## caminho de fallback sem depender de nenhuma rede a responder
## (agent_docs/testing.md:16-17: rede real só em game/tests/live/, nunca
## aqui). O teste que fala com um Ollama real vive em
## game/tests/live/test_llm_live.gd, fora deste ficheiro de propósito.

## Porta sem nada a escutar: a mesma costura de teste que o
## scripts/llm_eval.py e o tech_design.md §10 usam para provar fallback.
const DEAD_URL := "http://127.0.0.1:9"

## Valor de INSULANO_LLM_URL antes do teste corrente, para o repor tal como
## estava (mesmo cuidado de game/tests/unit/test_llm_settings.gd:14-20).
var _env_before: String
## Se INSULANO_LLM_URL existia antes do teste corrente.
var _env_existed_before: bool


func before_each() -> void:
	_env_before = OS.get_environment("INSULANO_LLM_URL")
	_env_existed_before = OS.has_environment("INSULANO_LLM_URL")


func after_each() -> void:
	if _env_existed_before:
		OS.set_environment("INSULANO_LLM_URL", _env_before)
	elif OS.has_environment("INSULANO_LLM_URL"):
		OS.unset_environment("INSULANO_LLM_URL")


## Contexto com os 5 campos de texto preenchidos (tech_design.md §4.2). Sem
## isto, o PromptBuilder devolve "" e o pedido cai em fallback por "prompt
## vazio" antes de chegar à rede, o que mascararia o que estes testes
## querem provar (o caminho de rede real, ainda que morto).
func _full_context() -> PhraseContext:
	var context := PhraseContext.new()
	context.hour = 15
	context.period = "tarde"
	context.action = "passear pela praia"
	context.hunger_label = "satisfeito"
	context.weather = "sol"
	context.holiday = "nenhuma"
	return context


## Liga um recetor que junta cada emissão de phrase_ready num Array, pela
## ordem de chegada: mais explícito para testar ORDEM e CONTAGEM de
## emissões do que depender do signal_watcher genérico do GUT.
func _collect_phrase_ready(bridge: LLMBridge) -> Array:
	var received: Array = []
	bridge.phrase_ready.connect(
		func(request_id: int, text: String, source: String) -> void:
			received.append({"id": request_id, "text": text, "source": source})
	)
	return received


func test_env_var_dead_port_yields_fallback_within_timeout() -> void:
	OS.set_environment("INSULANO_LLM_URL", DEAD_URL)
	var bridge := LLMBridge.new()
	add_child_autofree(bridge)
	var received := _collect_phrase_ready(bridge)

	assert_eq(bridge.settings.url, DEAD_URL, "LLMBridge tem de ler INSULANO_LLM_URL em _ready()")

	var started_at := Time.get_ticks_msec()
	var request_id := bridge.request_phrase(_full_context(), "idle")
	var arrived: bool = await wait_for_signal(bridge.phrase_ready, bridge.settings.timeout_s + 1.0)
	var elapsed_s := (Time.get_ticks_msec() - started_at) / 1000.0

	assert_true(arrived, "phrase_ready tem de chegar dentro de timeout_s + 1 s")
	assert_lt(elapsed_s, bridge.settings.timeout_s + 1.0)
	assert_eq(received.size(), 1)
	assert_eq(received[0]["id"], request_id)
	assert_eq(received[0]["source"], "fallback")


func test_disabled_bridge_yields_fallback_without_http_request() -> void:
	var bridge := LLMBridge.new()
	bridge.settings = LLMSettings.new()
	bridge.settings.enabled = false
	add_child_autofree(bridge)
	var received := _collect_phrase_ready(bridge)

	var initial_child_count := bridge.get_child_count()
	var request_id := bridge.request_phrase(_full_context(), "idle")

	# Resolve-se sincronamente: nem é preciso esperar um frame.
	assert_eq(received.size(), 1)
	assert_eq(received[0]["id"], request_id)
	assert_eq(received[0]["source"], "fallback")
	assert_eq(
		bridge.get_child_count(),
		initial_child_count,
		"enabled=false nunca cria o HTTPRequest filho"
	)
	assert_false(bridge.is_busy())


func test_second_request_while_busy_gets_immediate_fallback_and_each_id_gets_one_signal() -> void:
	var bridge := LLMBridge.new()
	bridge.settings = LLMSettings.new()
	bridge.settings.url = DEAD_URL
	bridge.settings.timeout_s = 2.0
	add_child_autofree(bridge)
	var received := _collect_phrase_ready(bridge)

	var id1 := bridge.request_phrase(_full_context(), "idle")
	assert_true(bridge.is_busy(), "o 1º pedido tem de ficar em curso antes do 2º chegar")
	var id2 := bridge.request_phrase(_full_context(), "idle")

	assert_ne(id1, id2, "cada pedido tem um request_id distinto")
	# O 2º já respondeu antes de qualquer espera: é isto que "imediato" significa.
	assert_eq(received.size(), 1, "o 2º pedido resolve-se logo, sem esperar pelo 1º")
	assert_eq(received[0]["id"], id2)
	assert_eq(received[0]["source"], "fallback")

	var arrived: bool = await wait_for_signal(bridge.phrase_ready, bridge.settings.timeout_s + 1.0)
	assert_true(arrived, "o 1º pedido também tem de receber o seu sinal, mais tarde")

	assert_eq(received.size(), 2, "cada request_id recebe um e um só sinal, nenhum a mais")
	assert_eq(received[1]["id"], id1)
	assert_eq(received[1]["source"], "fallback")

	var count_id1 := 0
	var count_id2 := 0
	for entry in received:
		if entry["id"] == id1:
			count_id1 += 1
		elif entry["id"] == id2:
			count_id2 += 1
	assert_eq(count_id1, 1, "id1 recebe exactamente um sinal")
	assert_eq(count_id2, 1, "id2 recebe exactamente um sinal")

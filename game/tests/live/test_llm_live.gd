extends GutTest
## Teste ao vivo de [LLMBridge] (T-105): prova que a ponte fala com um
## Ollama REAL e mede a latência de uma chamada verdadeira. Fica FORA de
## game/.gutconfig.json de propósito (não está em tests/unit nem
## tests/integration): nunca corre com "scripts/verify.sh" sem "--llm", nem
## no pre-commit. Só o passo dedicado de "scripts/verify.sh --llm" o invoca,
## com "-gdir=res://tests/live" explícito.
##
## Se o Ollama não estiver a responder nesta máquina (AGENTS.md §9: Docker,
## só CPU, 127.0.0.1:11434), o teste marca-se a si próprio como pending() em
## vez de falhar: um Ollama parado é um estado válido do jogo (regra
## invariante 4 do AGENTS.md, "o jogo corre completo sem Ollama"), não um
## bug da ponte.

## Segundos de margem, além de settings.timeout_s, para o teste esperar por
## um phrase_ready antes de desistir (rede real, folga acima do timeout
## interno da própria ponte para nunca correr à letra).
const WAIT_MARGIN_S := 2.0


## Verifica se há um Ollama a responder em url (GET /api/tags, tal como
## scripts/llm_eval.py faz antes do eval). Usa o próprio HTTPRequest do
## motor, nunca OS.execute: mantém a única dependência de rede deste teste
## coerente com o resto do jogo (AGENTS.md §6.2).
func _ollama_is_up(url: String) -> bool:
	var http := HTTPRequest.new()
	add_child_autofree(http)
	http.timeout = 3.0
	# Dictionary, não dois "var bool" soltos: uma lambda do GDScript captura
	# variáveis locais de tipo valor (bool, int, ...) por CÓPIA, não por
	# referência, por isso escrever nelas de dentro da lambda nunca chegava a
	# esta função (bug real, apanhado ao correr este teste contra um Ollama
	# que estava mesmo a responder e via "Pending" na mesma). Um Dictionary é
	# tipo referência: a mesma instância é partilhada entre a lambda e o
	# resto da função.
	var outcome := {"responded": false, "reachable": false}
	http.request_completed.connect(
		func(
			result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray
		) -> void:
			outcome["responded"] = true
			outcome["reachable"] = result == HTTPRequest.RESULT_SUCCESS and response_code == 200
	)
	var err := http.request(url + "/api/tags")
	if err != OK:
		return false
	await wait_for_signal(http.request_completed, 4.0)
	return outcome["responded"] and outcome["reachable"]


func test_real_ollama_answers_with_llm_source_and_measured_latency() -> void:
	var settings := LLMSettings.load_settings()
	if not await _ollama_is_up(settings.url):
		pending("Ollama não respondeu em %s: teste ao vivo saltado" % settings.url)
		return

	var bridge := LLMBridge.new()
	add_child_autofree(bridge)

	var context := PhraseContext.new()
	context.hour = 15
	context.period = "tarde"
	context.action = "passear pela praia"
	context.hunger_label = "satisfeito"
	context.weather = "sol"
	context.holiday = "nenhuma"

	var received: Array = []
	bridge.phrase_ready.connect(
		func(request_id: int, text: String, source: String) -> void:
			received.append({"id": request_id, "text": text, "source": source})
	)

	var started_at := Time.get_ticks_msec()
	var request_id := bridge.request_phrase(context, "idle")
	var arrived: bool = await wait_for_signal(
		bridge.phrase_ready, bridge.settings.timeout_s + WAIT_MARGIN_S
	)
	var elapsed_s := (Time.get_ticks_msec() - started_at) / 1000.0

	assert_true(arrived, "phrase_ready tem de chegar dentro de timeout_s + margem")
	assert_eq(received.size(), 1)
	assert_eq(received[0]["id"], request_id)

	print(
		(
			"[Insulano/LLM] teste ao vivo: modelo=%s source=%s latencia=%.2fs texto=%s"
			% [bridge.settings.model, received[0]["source"], elapsed_s, received[0]["text"]]
		)
	)

	assert_eq(
		received[0]["source"],
		"llm",
		"Ollama respondeu mas a ponte caiu em fallback (ver o log [Insulano/LLM] acima para o motivo)"
	)
	assert_false(received[0]["text"].is_empty())

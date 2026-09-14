class_name LLMBridge
extends Node
## Ponte assíncrona para o Ollama: qualquer parte do jogo pede uma frase e
## recebe exactamente um sinal `phrase_ready`, do LLM ou do fallback, sem
## nunca bloquear um frame (tech_design.md §4.5, AGENTS.md §6.3).
##
## Autoload único que fala com o Ollama (AGENTS.md §6.2): nenhum outro
## script deste jogo cria um HTTPRequest para o endpoint de geração de
## frases. Depende de LLMSettings (T-101, configuração), PhraseContext e
## PromptBuilder (T-102, montam o prompt), PhraseFilter (T-103, aceita ou
## rejeita a resposta) e FallbackPhrases (T-104, garante sempre uma frase).
## Não conhece a behavior tree: quem chama request_phrase() e o que faz com
## o texto devolvido é responsabilidade de SayGeneratedAction (T-106, fora
## de âmbito aqui).

## Emitido exactamente uma vez por cada request_id devolvido por
## request_phrase(), mesmo quando o resultado é um erro. source: "llm" se o
## texto veio do Ollama e passou o PhraseFilter; "fallback" em qualquer
## outro caso.
signal phrase_ready(request_id: int, text: String, source: String)

## Definições injectadas pelos testes; em jogo ficam nulas e são carregadas
## em _ready() a partir dos defeitos reais (project.godot, user://settings.cfg,
## INSULANO_LLM_URL). Um teste que as define ANTES de add_child() evita que
## _ready() as sobreponha (padrão de injecção de code_patterns.md §5).
var settings: LLMSettings = null
## Filtro de aceitação de frases; ver settings acima quanto à injecção.
var filter: PhraseFilter = null
## Fonte das frases de fallback; ver settings acima quanto à injecção.
var fallback: FallbackPhrases = null
## Template do prompt já carregado (game/data/prompts/phrase_prompt.txt);
## ver settings acima quanto à injecção.
var template: String = ""

## Nó HTTPRequest reutilizado entre pedidos; só é criado quando o primeiro
## pedido REAL é despachado (nunca com settings.enabled = false), para o
## critério "enabled = false não cria pedido HTTP" poder ser confirmado a
## partir de fora (contar filhos do nó, ver
## game/tests/integration/test_llm_bridge.gd).
var _http: HTTPRequest = null
## Próximo request_id a atribuir; começa em 1 (0 fica livre para "nenhum",
## caso algum chamador futuro precise de um valor "sem pedido").
var _next_request_id: int = 1
## request_id do pedido HTTP actualmente em curso, ou -1 se nenhum.
var _busy_request_id: int = -1
## Categoria de fallback do pedido em curso, para usar se a rede falhar.
var _busy_fallback_category: String = ""
## Momento (Time.get_ticks_msec()) em que o pedido em curso foi despachado,
## só para calcular a latência que vai para o log.
var _busy_started_at_ms: int = 0


## Carrega os defeitos que um teste não tenha injectado. Feito em _ready()
## (não em _init()) porque LLMSettings.load_settings() lê ProjectSettings e
## ficheiros em user://, que só existem com a árvore de cenas a correr.
func _ready() -> void:
	if settings == null:
		settings = LLMSettings.load_settings()
	if filter == null:
		filter = PhraseFilter.from_rules_file()
	if fallback == null:
		fallback = FallbackPhrases.from_file()
	if template.is_empty():
		template = PromptBuilder.load_template()


## Verdadeiro enquanto há um pedido HTTP real em curso. Não conta os
## fallbacks imediatos (desligado ou pedido concorrente): esses resolvem-se
## antes de sequer chegar a ficar "em curso".
func is_busy() -> bool:
	return _busy_request_id != -1


## Pede uma frase para context. Devolve já o request_id atribuído; o sinal
## phrase_ready com esse mesmo request_id chega depois, com source "llm", OU
## já dentro desta própria chamada (sincronamente), com source "fallback",
## quando: a ponte está desligada (settings.enabled = false), já há um
## pedido em curso (contrato tech_design.md §4.5: "pedido novo com um em
## curso responde já com fallback") ou o prompt saiu vazio (contexto
## incompleto ou template em falta). fallback_category escolhe a frase de
## FallbackPhrases quando é preciso cair no fallback.
func request_phrase(context: PhraseContext, fallback_category: String) -> int:
	var request_id := _next_request_id
	_next_request_id += 1

	if not settings.enabled:
		_emit_fallback(request_id, fallback_category, "desligado (enabled=false)")
		return request_id
	if is_busy():
		_emit_fallback(request_id, fallback_category, "pedido anterior ainda em curso")
		return request_id

	var prompt := PromptBuilder.build(template, context)
	if prompt.is_empty():
		_emit_fallback(
			request_id, fallback_category, "prompt vazio (contexto ou template incompleto)"
		)
		return request_id

	_dispatch_request(request_id, fallback_category, prompt)
	return request_id


## Cria (se preciso) o HTTPRequest filho e despacha o pedido POST ao Ollama.
## Um erro imediato de HTTPRequest.request() (URL inválida, etc.) cai logo
## em fallback; falhas que só aparecem mais tarde (rede, timeout, HTTP
## diferente de 200) chegam a _on_request_completed.
func _dispatch_request(request_id: int, fallback_category: String, prompt: String) -> void:
	if _http == null:
		_http = HTTPRequest.new()
		add_child(_http)
		_http.request_completed.connect(_on_request_completed)
	_http.timeout = settings.timeout_s

	_busy_request_id = request_id
	_busy_fallback_category = fallback_category
	_busy_started_at_ms = Time.get_ticks_msec()

	var payload := build_payload(settings.model, prompt)
	var err := _http.request(
		settings.url + "/api/generate",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	if err != OK:
		_busy_request_id = -1
		_emit_fallback(request_id, fallback_category, "request_error_%d" % err)


## Callback de HTTPRequest.request_completed. Resolve o pedido em curso
## (aceite do Ollama ou fallback) e emite phrase_ready exactamente uma vez.
func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	var request_id := _busy_request_id
	var fallback_category := _busy_fallback_category
	var latency_s := (Time.get_ticks_msec() - _busy_started_at_ms) / 1000.0
	_busy_request_id = -1

	var raw := parse_response(result, response_code, body)
	if raw.is_empty():
		print(
			(
				(
					"[Insulano/LLM] modelo=%s latencia=%.2fs fallback: resposta vazia/invalida "
					+ "(result=%d codigo=%d)"
				)
				% [settings.model, latency_s, result, response_code]
			)
		)
		_emit_fallback(request_id, fallback_category, "resposta vazia ou invalida")
		return

	var clean_text := filter.clean(raw)
	var reason := filter.rejection_reason(clean_text)
	if reason != "":
		print(
			(
				"[Insulano/LLM] modelo=%s latencia=%.2fs fallback: frase rejeitada (%s)"
				% [settings.model, latency_s, reason]
			)
		)
		_emit_fallback(request_id, fallback_category, "rejeitada: %s" % reason)
		return

	print("[Insulano/LLM] modelo=%s latencia=%.2fs fonte=llm" % [settings.model, latency_s])
	phrase_ready.emit(request_id, clean_text, "llm")


## Emite o fallback garantido para request_id. reason só vai para o log
## (nunca para o sinal): o contrato tech_design.md §4.5 só define os valores
## "llm" e "fallback" para o campo source.
func _emit_fallback(request_id: int, fallback_category: String, reason: String) -> void:
	var text := fallback.pick(fallback_category)
	print("[Insulano/LLM] fallback (%s), categoria=%s" % [reason, fallback_category])
	phrase_ready.emit(request_id, text, "fallback")


## Payload exacto documentado em docs/api-ollama.md ("Pedido"): model e
## prompt vêm dos argumentos, o resto é fixo. static e pura, para testar o
## payload sem montar toda a ponte (settings, filtro, fallback).
static func build_payload(model: String, prompt: String) -> Dictionary:
	return {
		"model": model,
		"prompt": prompt,
		"stream": false,
		"keep_alive": "10m",
		"options": {"temperature": 0.8, "top_p": 0.9, "num_predict": 40},
	}


## Extrai o texto de "response" do corpo devolvido pelo Ollama. Devolve ""
## em QUALQUER falha (docs/api-ollama.md, tabela "Erros e o que a ponte
## faz"): result diferente de sucesso, código HTTP diferente de 200, corpo
## que não é JSON válido, ou sem uma chave "response" do tipo String
## (incluindo vazia). Não aplica o PhraseFilter: só extrai o texto cru; quem
## decide aceitar ou rejeitar é o chamador (_on_request_completed).
static func parse_response(result: int, response_code: int, body: PackedByteArray) -> String:
	if result != HTTPRequest.RESULT_SUCCESS:
		return ""
	if response_code != 200:
		return ""
	var data: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	var response: Variant = data.get("response", "")
	if typeof(response) != TYPE_STRING:
		return ""
	return response

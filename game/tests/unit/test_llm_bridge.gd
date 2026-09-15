extends GutTest
## Testes puros de [LLMBridge]: build_payload (payload exacto de
## docs/api-ollama.md) e parse_response (extracção do texto da resposta do
## Ollama, "" em qualquer falha, tabela "Erros e o que a ponte faz"). Sem
## cena, sem rede: fixtures gravadas em game/tests/fixtures/ollama_*, para
## os testes nunca dependerem de um Ollama a correr (agent_docs/testing.md:16-17).

const OK_FIXTURE := "res://tests/fixtures/ollama_ok.json"
const EMPTY_FIXTURE := "res://tests/fixtures/ollama_empty.json"
const INVALID_FIXTURE := "res://tests/fixtures/ollama_invalid.txt"


## Lê uma fixture de bytes, tal como o corpo que o HTTPRequest entrega ao
## sinal request_completed (PackedByteArray, não String).
func _read_fixture(path: String) -> PackedByteArray:
	return FileAccess.get_file_as_bytes(path)


func test_build_payload_matches_docs_api_ollama() -> void:
	# Payload exacto da secção "Pedido" de docs/api-ollama.md, com model e
	# prompt substituídos pelos argumentos.
	var expected := {
		"model": "llama3.1:8b",
		"prompt": "Diz uma frase curta de náufrago em português de Portugal.",
		"stream": false,
		"keep_alive": "10m",
		"options": {"temperature": 0.8, "top_p": 0.9, "num_predict": 40},
	}

	var actual := LLMBridge.build_payload(
		"llama3.1:8b", "Diz uma frase curta de náufrago em português de Portugal."
	)

	assert_eq(actual, expected)


func test_build_payload_uses_the_given_model_and_prompt() -> void:
	# Prova que os campos variáveis vêm mesmo dos argumentos, não de valores
	# fixos copiados do exemplo da documentação.
	var actual := LLMBridge.build_payload("outro-modelo", "outro prompt")

	assert_eq(actual["model"], "outro-modelo")
	assert_eq(actual["prompt"], "outro prompt")


func test_build_completion_payload_matches_docs_api_ollama() -> void:
	# Mesmo payload de build_payload, mas com num_predict configurável
	# (tech_design.md §4.5, request_completion): a resposta do director é
	# um JSON com vários campos, não cabe nos 40 tokens fixos das frases.
	var expected := {
		"model": "llama3.1:8b",
		"prompt": "prompt do director",
		"stream": false,
		"keep_alive": "10m",
		"options": {"temperature": 0.8, "top_p": 0.9, "num_predict": 123},
	}

	var actual := LLMBridge.build_completion_payload("llama3.1:8b", "prompt do director", 123)

	assert_eq(actual, expected)


func test_build_completion_payload_with_default_num_predict_constant() -> void:
	# Exercita DEFAULT_COMPLETION_NUM_PREDICT explicitamente: é o valor que
	# _dispatch_completion_request usa quando o chamador não indica
	# num_predict (request_completion(prompt) sem o 2º argumento), nunca
	# antes coberto por um teste (bloqueante apontado na revisão da T-115).
	var actual := LLMBridge.build_completion_payload(
		"llama3.1:8b", "prompt", LLMBridge.DEFAULT_COMPLETION_NUM_PREDICT
	)

	assert_eq(actual["options"]["num_predict"], 200)
	assert_eq(actual["options"]["num_predict"], LLMBridge.DEFAULT_COMPLETION_NUM_PREDICT)


func test_parse_response_extracts_response_field_from_ok_fixture() -> void:
	var body := _read_fixture(OK_FIXTURE)
	assert_gt(body.size(), 0, "a fixture ollama_ok.json tem de existir e não estar vazia")

	var text := LLMBridge.parse_response(HTTPRequest.RESULT_SUCCESS, 200, body)

	assert_eq(text, "Parece que até o Natal estou sozinho.")


func test_parse_response_empty_response_field_is_empty_string() -> void:
	var body := _read_fixture(EMPTY_FIXTURE)
	assert_gt(body.size(), 0, "a fixture ollama_empty.json tem de existir e não estar vazia")

	var text := LLMBridge.parse_response(HTTPRequest.RESULT_SUCCESS, 200, body)

	assert_eq(text, "")


func test_parse_response_invalid_json_is_empty_string() -> void:
	var body := _read_fixture(INVALID_FIXTURE)
	assert_gt(body.size(), 0, "a fixture ollama_invalid.txt tem de existir e não estar vazia")

	var text := LLMBridge.parse_response(HTTPRequest.RESULT_SUCCESS, 200, body)

	assert_eq(text, "")
	# JSON.parse_string() regista, por baixo, um erro de motor ao falhar o
	# parse de um texto genuinamente inválido (mesmo padrão de
	# test_phrase_filter.gd:58): consumi-lo aqui, senão o GUT reprova o
	# teste por "Unexpected Errors" mesmo com a asserção acima a passar.
	assert_engine_error("error != Error::OK")


func test_parse_response_http_500_is_empty_string_even_with_valid_json() -> void:
	# Corpo válido (fixture ollama_ok.json) mas código HTTP 500: o critério de
	# aceitação distingue "código diferente de 200" de "JSON inválido", por
	# isso este teste reutiliza o corpo bom com o código mau.
	var body := _read_fixture(OK_FIXTURE)

	var text := LLMBridge.parse_response(HTTPRequest.RESULT_SUCCESS, 500, body)

	assert_eq(text, "")


func test_parse_response_network_failure_is_empty_string() -> void:
	var text := LLMBridge.parse_response(HTTPRequest.RESULT_CONNECTION_ERROR, 0, PackedByteArray())

	assert_eq(text, "")

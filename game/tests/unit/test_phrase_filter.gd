extends GutTest
## Testes de [PhraseFilter] contra a fixture partilhada
## game/tests/fixtures/phrase_filter_cases.json, o mesmo ficheiro que
## scripts/tests/test_llm_eval.py usa contra scripts/llm_eval.py.
##
## test_case_matches_python_eval percorre TODOS os casos da fixture num único
## laço (nunca casos escritos à mão aqui): é isto que garante que o jogo
## rejeita as mesmas frases que o eval rejeita, pelas mesmas razões
## (tech_design.md §4.3). Um caso novo na fixture aparece automaticamente
## aqui e no pytest, sem tocar em nenhum dos dois ficheiros de teste.

const RULES_PATH := "res://data/phrase_rules.json"
const FIXTURE_PATH := "res://tests/fixtures/phrase_filter_cases.json"


## Devolve a lista de casos da fixture partilhada ({raw, clean, reason}).
## reason vem "null" em JSON para os casos aceites; a fixture não escreve
## "" (string vazia) para não confundir com um `reason` real.
func _load_cases() -> Array:
	var text := FileAccess.get_file_as_string(FIXTURE_PATH)
	var data: Variant = JSON.parse_string(text)
	assert_eq(typeof(data), TYPE_DICTIONARY, "fixture tem de ser um objecto JSON")
	return data["cases"]


func test_case_matches_python_eval() -> void:
	var filter := PhraseFilter.from_rules_file(RULES_PATH)
	var cases := _load_cases()
	assert_gt(cases.size(), 0, "a fixture não pode estar vazia")

	for case in cases:
		var raw: String = case["raw"]
		var expected_clean: String = case["clean"]
		# JSON "null" chega como Variant nulo; o contrato do PhraseFilter usa
		# "" para "aceite", nunca null (tech_design.md §4.3).
		var expected_reason: String = "" if case["reason"] == null else case["reason"]

		var actual_clean := filter.clean(raw)
		var actual_reason := filter.rejection_reason(actual_clean)

		assert_eq(actual_clean, expected_clean, "clean('%s')" % raw)
		assert_eq(actual_reason, expected_reason, "rejection_reason('%s')" % raw)


## Se phrase_rules.json não existir, o filtro falha FECHADO: rejeita
## qualquer texto, mesmo um que passaria nos DEFAULT_* (revisão do
## insulano-reviewer à T-103: um filtro sem regras não pode deixar passar
## tudo por omissão).
func test_missing_rules_file_fails_closed() -> void:
	var filter := PhraseFilter.from_rules_file("res://data/nao_existe.json")
	var reason := filter.rejection_reason(filter.clean("Isto parece uma frase normal e aceitável."))
	assert_ne(reason, "", "sem regras carregadas, rejection_reason() nunca devolve aceite")
	# from_rules_file() regista um push_error próprio e o FileAccess do Godot
	# regista, por baixo, um erro de motor ao não conseguir abrir o ficheiro
	# inexistente. Consumir os dois aqui (mesmo padrão de
	# test_prompt_builder.gd:69), senão o GUT reprova o teste por "Unexpected
	# Errors" mesmo com a asserção acima a passar.
	assert_engine_error("error != Error::OK")
	assert_push_error("phrase_rules.json inválido ou inexistente")

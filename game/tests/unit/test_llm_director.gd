extends GutTest
## Testes puros de [LLMDirector] (T-115): estação por mês, montagem do prompt,
## parsing e validação do JSON de resposta ({arc, activity, phrase}) e
## conversão para DirectorDirective. Sem cena, sem rede: as fixtures
## (game/tests/fixtures/director_*.json|txt) espelham o que o Ollama devolve,
## tal como game/tests/unit/test_llm_bridge.gd faz para as frases
## (agent_docs/testing.md:16-17).

const OK_FIXTURE := "res://tests/fixtures/director_ok.json"
const OK_FENCED_FIXTURE := "res://tests/fixtures/director_ok_fenced.txt"
const GARBAGE_FIXTURE := "res://tests/fixtures/director_garbage.txt"
const INVALID_SCHEMA_FIXTURE := "res://tests/fixtures/director_invalid_schema.json"
const INVALID_ARC_FIXTURE := "res://tests/fixtures/director_invalid_arc.json"
const INVALID_ACTIVITY_FIXTURE := "res://tests/fixtures/director_invalid_activity.json"
const INVALID_PHRASE_FIXTURE := "res://tests/fixtures/director_invalid_phrase.json"


func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path)


func test_season_for_month_matches_hemisferio_norte() -> void:
	assert_eq(LLMDirector.season_for_month(1), "Inverno")
	assert_eq(LLMDirector.season_for_month(2), "Inverno")
	assert_eq(LLMDirector.season_for_month(12), "Inverno")
	assert_eq(LLMDirector.season_for_month(3), "Primavera")
	assert_eq(LLMDirector.season_for_month(5), "Primavera")
	assert_eq(LLMDirector.season_for_month(6), "Verao")
	assert_eq(LLMDirector.season_for_month(8), "Verao")
	assert_eq(LLMDirector.season_for_month(9), "Outono")
	assert_eq(LLMDirector.season_for_month(11), "Outono")


func test_build_prompt_substitui_o_marcador_de_contexto() -> void:
	var template := "antes {{CONTEXTO}} depois"
	var context := {"dia": 5}

	var prompt := LLMDirector.build_prompt(template, context)

	assert_eq(prompt, "antes %s depois" % JSON.stringify(context, "  "))


func test_build_prompt_com_template_vazio_devolve_vazio() -> void:
	assert_eq(LLMDirector.build_prompt("", {"dia": 1}), "")


func test_parse_directive_extrai_json_da_fixture_ok() -> void:
	var raw := _read(OK_FIXTURE)
	assert_gt(raw.length(), 0, "a fixture director_ok.json tem de existir e não estar vazia")

	var data := LLMDirector.parse_directive(raw)

	assert_eq(data.get("arc"), "companheiro")
	assert_eq(data.get("activity"), "conversar com o companheiro")
	assert_eq(data.get("phrase"), "Ainda bem que tenho companhia hoje.")


func test_parse_directive_remove_fences_markdown() -> void:
	var raw := _read(OK_FENCED_FIXTURE)
	assert_gt(raw.length(), 0, "a fixture director_ok_fenced.txt tem de existir e não estar vazia")

	var data := LLMDirector.parse_directive(raw)

	assert_eq(data.get("arc"), "jangada")
	assert_eq(data.get("activity"), "reparar a jangada")


func test_parse_directive_garbage_devolve_dicionario_vazio() -> void:
	var raw := _read(GARBAGE_FIXTURE)
	assert_gt(raw.length(), 0, "a fixture director_garbage.txt tem de existir e não estar vazia")

	var data := LLMDirector.parse_directive(raw)

	assert_true(data.is_empty())
	# JSON.parse_string() regista um erro de motor ao falhar o parse de um
	# texto genuinamente inválido (mesmo padrão de test_llm_bridge.gd:75):
	# consumi-lo aqui, senão o GUT reprova por "Unexpected Errors".
	assert_engine_error("error != Error::OK")


func test_parse_directive_texto_vazio_devolve_dicionario_vazio() -> void:
	assert_true(LLMDirector.parse_directive("").is_empty())


func test_validate_directive_aceita_fixture_ok() -> void:
	var data := LLMDirector.parse_directive(_read(OK_FIXTURE))
	assert_true(LLMDirector.validate_directive(data))


func test_validate_directive_rejeita_arco_desconhecido_activity_vazia_e_phrase_nao_string() -> void:
	# Regressão combinada (mantida): os 3 defeitos isolados abaixo já provam
	# cada um por si, esta prova que a combinação continua rejeitada.
	var data := LLMDirector.parse_directive(_read(INVALID_SCHEMA_FIXTURE))
	assert_false(LLMDirector.validate_directive(data))


func test_validate_directive_rejeita_arco_desconhecido() -> void:
	var data := LLMDirector.parse_directive(_read(INVALID_ARC_FIXTURE))
	assert_false(LLMDirector.validate_directive(data))


func test_validate_directive_rejeita_activity_vazia() -> void:
	var data := LLMDirector.parse_directive(_read(INVALID_ACTIVITY_FIXTURE))
	assert_false(LLMDirector.validate_directive(data))


func test_validate_directive_rejeita_phrase_nao_string() -> void:
	var data := LLMDirector.parse_directive(_read(INVALID_PHRASE_FIXTURE))
	assert_false(LLMDirector.validate_directive(data))


func test_validate_directive_rejeita_campo_em_falta() -> void:
	assert_false(
		LLMDirector.validate_directive({"arc": "diario", "activity": "escrever no diário"})
	)


func test_validate_directive_rejeita_dicionario_vazio() -> void:
	assert_false(LLMDirector.validate_directive({}))


func test_directive_from_data_preenche_directordirective() -> void:
	var data := LLMDirector.parse_directive(_read(OK_FIXTURE))

	var directive := LLMDirector.directive_from_data(data)

	assert_eq(directive.arc_id, "companheiro")
	assert_eq(directive.activity, "conversar com o companheiro")
	assert_eq(directive.phrase_context_extra.get("phrase"), "Ainda bem que tenho companhia hoje.")

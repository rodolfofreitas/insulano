extends GutTest
## Testes de [PhraseContext] e [PromptBuilder] contra o template partilhado
## game/data/prompts/phrase_prompt.txt.
##
## test_build_matches_python_render_for_tarde_pescar prova a paridade carácter a
## carácter com scripts/llm_eval.py: render_prompt (Python) e PromptBuilder.build
## (GDScript) têm de produzir exactamente o mesmo texto para o mesmo contexto,
## senão o jogo e o eval falam coisas diferentes ao Ollama.
##
## Para regenerar game/tests/fixtures/prompt_tarde_pescar.txt a partir do
## caso "tarde-pescar" de evals/phrase_cases.json (correr da raiz do repo):
##   python3 -c "
##   import sys
##   sys.path.insert(0, 'scripts')
##   from llm_eval import render_prompt, PROMPT_PATH, CASES_PATH, load_json
##   cases = load_json(CASES_PATH)['cases']
##   case = next(c for c in cases if c['id'] == 'tarde-pescar')
##   template = PROMPT_PATH.read_text(encoding='utf-8')
##   prompt = render_prompt(template, case['context'])
##   out = 'game/tests/fixtures/prompt_tarde_pescar.txt'
##   with open(out, 'w', encoding='utf-8', newline='\n') as f:
##       f.write(prompt)
##   "

const FIXTURE_PATH := "res://tests/fixtures/prompt_tarde_pescar.txt"


## Contexto do caso "tarde-pescar" de evals/phrase_cases.json, copiado a mão dos
## valores desse ficheiro (hour, period, action, hunger, weather, holiday).
func _tarde_pescar_context() -> PhraseContext:
	var context := PhraseContext.new()
	context.hour = 17
	context.period = "fim da tarde"
	context.action = "pescar"
	context.hunger_label = "com fome"
	context.weather = "sol"
	context.holiday = "nenhuma"
	return context


func test_build_matches_python_render_for_tarde_pescar() -> void:
	var expected := FileAccess.get_file_as_string(FIXTURE_PATH)
	assert_false(expected.is_empty(), "fixture Python tem de existir e não estar vazia")

	var template := PromptBuilder.load_template()
	var actual := PromptBuilder.build(template, _tarde_pescar_context())

	assert_eq(actual, expected)


func test_incomplete_context_returns_empty_string_and_no_curly_braces() -> void:
	# Contexto sem "weather" nem "holiday" preenchidos: o prompt nunca pode
	# sair com "{weather}" ou "{holiday}" literais.
	var context := PhraseContext.new()
	context.hour = 10
	context.period = "manhã"
	context.action = "passear pela praia"
	context.hunger_label = "satisfeito"
	# weather e holiday ficam "" (defeito), de propósito.

	var template := PromptBuilder.load_template()
	var result := PromptBuilder.build(template, context)

	assert_eq(result, "")
	assert_eq(result.find("{"), -1)
	# Confirma que o "" não é silencioso: fica registado um erro (tech_design.md
	# §4.2). assert_push_error consome o erro, senão o GUT reprova o teste por
	# "Unexpected Errors" mesmo com as asserções acima a passar.
	assert_push_error("contexto incompleto")


func test_unknown_field_left_by_format_is_caught_by_second_net() -> void:
	# Contexto completo (os cinco campos de texto preenchidos), mas um template
	# sintético com um placeholder que o PhraseContext nunca fornece
	# ("{desconhecido}"). String.format() deixa essa chaveta literal (ao
	# contrário do str.format do Python, não levanta erro por chave em
	# falta), por isso quem tem de a apanhar é a segunda rede depois do
	# format (prompt_builder.gd:45-47), não a validação de contexto
	# incompleto (linhas 38-42), que não dispara aqui porque o contexto está
	# completo.
	var template := "prefixo {desconhecido} {period}"
	var result := PromptBuilder.build(template, _tarde_pescar_context())

	assert_eq(result, "")
	assert_push_error("campo por preencher")


func test_hunger_label_for_above_60_is_satisfeito() -> void:
	assert_eq(PromptBuilder.hunger_label_for(61.0), "satisfeito")


func test_hunger_label_for_at_60_is_com_fome() -> void:
	# Fronteira: 60 exacto NÃO é "satisfeito" (o corte é ">60", não ">=60").
	assert_eq(PromptBuilder.hunger_label_for(60.0), "com fome")


func test_hunger_label_for_at_25_is_esfomeado() -> void:
	# Fronteira: 25 exacto NÃO é "com fome" (o corte é ">25", não ">=25").
	assert_eq(PromptBuilder.hunger_label_for(25.0), "esfomeado")


func test_hunger_label_for_at_0_is_esfomeado() -> void:
	assert_eq(PromptBuilder.hunger_label_for(0.0), "esfomeado")

class_name PromptBuilder
extends RefCounted
## Monta o prompt enviado ao Ollama a partir do template partilhado
## game/data/prompts/phrase_prompt.txt e de um [PhraseContext].
##
## Usado pelo LLMBridge (T-105) antes de cada pedido. Não fala com a rede nem
## decide o que fazer com a resposta: só texto dentro, texto fora. Tem
## paridade carácter a carácter com scripts/llm_eval.py (render_prompt),
## testada em game/tests/unit/test_prompt_builder.gd contra a fixture
## game/tests/fixtures/prompt_tarde_pescar.txt, gerada pelo próprio Python.

## Caminho do template partilhado; fonte única (tech_design.md §4.2 e §1.4:
## dados fora do código). O texto do prompt em si é da T-108, não desta tarefa.
const TEMPLATE_PATH := "res://data/prompts/phrase_prompt.txt"

## Acima deste valor (percentagem de energia da Need de fome), o náufrago
## está "satisfeito" (tech_design.md §4.2).
const HUNGER_SATISFIED_ABOVE: float = 60.0
## Acima deste valor, "com fome"; a partir daqui para baixo, "esfomeado".
const HUNGER_HUNGRY_ABOVE: float = 25.0


## Lê o template partilhado do disco. "" com push_error se o ficheiro faltar
## ou estiver vazio (nunca deixa o jogo continuar com um template a meio).
static func load_template() -> String:
	var text := FileAccess.get_file_as_string(TEMPLATE_PATH)
	if text.is_empty():
		push_error("[Insulano/LLM] template do prompt vazio ou inexistente: %s" % TEMPLATE_PATH)
	return text


## Preenche o template com os campos do contexto. Devolve "" e regista um erro
## se o contexto estiver incompleto (algum campo de texto obrigatório em
## branco) ou se, depois de preenchido, ainda sobrar alguma chaveta "{...}":
## nunca se devolve um prompt com um campo por preencher (tech_design.md §4.2).
static func build(template: String, context: PhraseContext) -> String:
	var fields := context.to_template_fields()
	for key in ["period", "action", "hunger", "weather", "holiday"]:
		var value: String = fields.get(key, "")
		if value.is_empty():
			push_error("[Insulano/LLM] contexto incompleto: falta o campo '%s'" % key)
			return ""

	var result: String = template.format(fields)
	if result.find("{") != -1:
		push_error("[Insulano/LLM] prompt com campo por preencher depois do format: %s" % result)
		return ""
	return result


## Traduz uma percentagem de fome (0-100) no rótulo em pt-PT usado pelo
## template. Fronteiras exactas do tech_design.md §4.2: >60 satisfeito,
## >25 com fome (60 exacto cai aqui), resto esfomeado (25 exacto cai aqui).
static func hunger_label_for(percentage: float) -> String:
	if percentage > HUNGER_SATISFIED_ABOVE:
		return "satisfeito"
	if percentage > HUNGER_HUNGRY_ABOVE:
		return "com fome"
	return "esfomeado"

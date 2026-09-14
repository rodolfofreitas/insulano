extends GutTest
## Testes de [FallbackPhrases] (tech_design.md §4.4), a fonte de frases fixas
## usada pelo LLMBridge (T-105) quando o Ollama falha, demora ou a resposta é
## rejeitada pelo [PhraseFilter]. As três garantias exigidas pela tarefa
## T-104: as frases passam as mesmas regras que valem para o LLM, nunca
## repetem a frase anterior na mesma categoria, e uma categoria inexistente
## nunca deixa o náufrago em silêncio (cai em "idle").

const RULES_PATH := "res://data/phrase_rules.json"
const FALLBACK_PATH := "res://data/phrases_fallback.json"
## Mesma lista de categorias exigida pelo critério de aceitação da T-104.
const EXPECTED_CATEGORIES := [
	"idle", "fishing", "eating", "morning", "night", "rain", "seagull", "boat"
]


## Todas as categorias esperadas existem e têm pelo menos 4 frases: sem isto,
## pick() nunca teria por onde variar (o critério da T-104 pede pelo menos 4
## por categoria). Também garante que nenhuma categoria tem frases repetidas:
## pick() (fallback_phrases.gd) compara por valor, não por índice, mas essa
## robustez só evita repetição imediata se houver de facto uma frase
## diferente para escolher; esta asserção é a rede de segurança para a
## fixture actual (o dia em que phrases_fallback.json ganhar uma duplicada,
## esta falha antes de a repetição chegar a acontecer em produção).
func test_all_expected_categories_have_at_least_four_phrases() -> void:
	var fallback := FallbackPhrases.from_file(FALLBACK_PATH)
	var text := FileAccess.get_file_as_string(FALLBACK_PATH)
	var data: Dictionary = JSON.parse_string(text)

	for category in EXPECTED_CATEGORIES:
		assert_true(
			fallback.categories().has(category), "categorias() tem de incluir '%s'" % category
		)
		var phrases: Array = data[category]
		assert_gt(phrases.size(), 3, "categoria '%s' precisa de pelo menos 4 frases" % category)

		var distinct := {}
		for phrase in phrases:
			distinct[String(phrase)] = true
		assert_eq(
			distinct.size(),
			phrases.size(),
			"categoria '%s' tem frases repetidas: %s" % [category, phrases]
		)


## Nenhuma frase de phrases_fallback.json pode ser rejeitada pelo PhraseFilter:
## um náufrago sem LLM tem de dizer coisas tão válidas como as geradas.
func test_every_fallback_phrase_passes_the_phrase_filter() -> void:
	var filter := PhraseFilter.from_rules_file(RULES_PATH)
	var text := FileAccess.get_file_as_string(FALLBACK_PATH)
	var data: Dictionary = JSON.parse_string(text)

	for category in data.keys():
		var phrases: Array = data[category]
		for phrase in phrases:
			var cleaned := filter.clean(String(phrase))
			var reason := filter.rejection_reason(cleaned)
			assert_eq(
				reason, "", "categoria '%s', frase '%s' rejeitada: %s" % [category, phrase, reason]
			)


## 50 escolhas seguidas na categoria "idle" nunca repetem a frase imediatamente
## anterior (critério da T-104). seed() fixa por determinismo (testing.md §4.3).
func test_fifty_consecutive_picks_never_repeat_previous() -> void:
	seed(42)
	var fallback := FallbackPhrases.from_file(FALLBACK_PATH)
	var previous := fallback.pick("idle")

	for _i in range(50):
		var current := fallback.pick("idle")
		assert_ne(current, previous, "pick() repetiu a frase anterior na mesma categoria")
		previous = current


## Uma categoria que não existe em phrases_fallback.json devolve sempre uma
## frase da categoria "idle" (tech_design.md §4.4). Corrido em laço com uma
## categoria inexistente diferente por iteração: uma única chamada só provaria
## um resultado de uma escolha aleatória; o laço reduz drasticamente a chance
## de um falso verde por sorte.
func test_unknown_category_falls_back_to_idle() -> void:
	var fallback := FallbackPhrases.from_file(FALLBACK_PATH)
	var idle_phrases: Array = (
		JSON.parse_string(FileAccess.get_file_as_string(FALLBACK_PATH))["idle"]
	)

	for i in range(30):
		var picked := fallback.pick("categoria_que_nao_existe_%d" % i)
		assert_true(
			idle_phrases.has(picked), "categoria inexistente tem de devolver uma frase de 'idle'"
		)


## categories() devolve exactamente as chaves de phrases_fallback.json, sem
## nada acrescentado nem perdido (a T-402, fora de âmbito, tem o seu próprio
## holidays.json e não entra aqui).
func test_categories_matches_json_keys() -> void:
	var fallback := FallbackPhrases.from_file(FALLBACK_PATH)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FALLBACK_PATH))

	var categories := fallback.categories()
	assert_eq(categories.size(), data.keys().size())
	for category in data.keys():
		assert_true(categories.has(category))

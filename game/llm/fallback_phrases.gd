class_name FallbackPhrases
extends RefCounted
## Escolhe frases fixas em português de Portugal quando não há resposta do
## Ollama (tech_design.md §4.4): rede indisponível, resposta vazia ou
## rejeitada pelo [PhraseFilter]. Usado pelo LLMBridge (T-105) como o
## fallback garantido que a regra invariante 4 do AGENTS.md exige: o jogo
## tem de correr completo sem Ollama e sem internet.
##
## Não fala com a rede, não decide QUANDO usar fallback (isso é do
## LLMBridge) e não conhece feriados: as frases de feriado vivem em
## holidays.json e são geridas pela T-402, fora de âmbito aqui.

## Caminho por defeito, fonte única de dados (AGENTS.md §6.5).
const DEFAULT_PATH := "res://data/phrases_fallback.json"
## Categoria usada quando pick() recebe uma categoria desconhecida ou vazia.
const FALLBACK_CATEGORY := "idle"

## category -> PackedStringArray de frases, tal como lidas do JSON.
var _categories: Dictionary = {}
## category -> última frase devolvida por pick() nessa categoria, para nunca
## repetir de imediato a mesma frase duas vezes seguidas.
var _last_picked: Dictionary = {}


## Lê phrases_fallback.json e devolve uma instância com as suas categorias.
## Ficheiro em falta ou com JSON inválido: regista um erro e devolve uma
## instância sem categorias (pick() devolve "" nesse caso, com o seu próprio
## erro); ao contrário do PhraseFilter (que falha FECHADO a rejeitar tudo),
## aqui não há "aceitar ou rejeitar", só "ter ou não ter frases para dizer".
static func from_file(path: String = DEFAULT_PATH) -> FallbackPhrases:
	var fallback := FallbackPhrases.new()
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[Insulano/LLM] phrases_fallback.json inválido ou inexistente: %s" % path)
		return fallback

	for category in data.keys():
		var raw_list: Variant = data[category]
		if typeof(raw_list) != TYPE_ARRAY:
			continue
		var phrases := PackedStringArray()
		for phrase in raw_list:
			phrases.append(String(phrase))
		fallback._categories[category] = phrases
	return fallback


## Escolhe ao acaso uma frase da categoria pedida. Categoria inexistente ou
## sem frases cai em "idle" (tech_design.md §4.4). Nunca devolve a mesma
## STRING que a chamada anterior devolveu para a mesma categoria final (a que
## efectivamente forneceu a frase, já depois de qualquer queda para "idle"),
## desde que exista pelo menos uma frase de valor diferente nessa categoria;
## a comparação é por VALOR, não por índice, por isso a garantia aguenta
## frases duplicadas em phrases_fallback.json (ficheiro de dados editável por
## outras tarefas, ex. T-402 ou o insulano-llm-tuner). Caso extremo aceite: se
## todas as frases da categoria forem a mesma string, não há alternativa
## possível e pick() repete-a; a rede de segurança contra esse caso na
## fixture actual é o teste "sem frases repetidas por categoria" em
## test_fallback_phrases.gd, não esta função.
func pick(category: String) -> String:
	var key := category
	if not _categories.has(key) or (_categories[key] as PackedStringArray).is_empty():
		key = FALLBACK_CATEGORY

	var phrases: PackedStringArray = _categories.get(key, PackedStringArray())
	if phrases.is_empty():
		push_error("[Insulano/LLM] categoria de fallback '%s' sem frases disponíveis" % key)
		return ""

	var previous: String = _last_picked.get(key, "")
	var index := randi_range(0, phrases.size() - 1)
	var chosen := phrases[index]
	if chosen == previous:
		# Repetiu por valor: procura os índices com uma frase realmente
		# diferente da anterior e escolhe ao acaso entre eles. Se a lista
		# ficar vazia (todas as frases da categoria são iguais a "previous"),
		# mantém-se a escolha original: repetir é o único resultado possível.
		var alternative_indices: Array[int] = []
		for i in range(phrases.size()):
			if phrases[i] != previous:
				alternative_indices.append(i)
		if not alternative_indices.is_empty():
			index = alternative_indices[randi_range(0, alternative_indices.size() - 1)]
			chosen = phrases[index]

	_last_picked[key] = chosen
	return chosen


## Categorias disponíveis, na ordem em que existem no dicionário interno
## (a mesma ordem das chaves de phrases_fallback.json).
func categories() -> PackedStringArray:
	var keys := PackedStringArray()
	for key in _categories.keys():
		keys.append(key)
	return keys

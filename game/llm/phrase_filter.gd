class_name PhraseFilter
extends RefCounted
## Aceita ou rejeita frases geradas pelo LLM segundo game/data/phrase_rules.json
## (tech_design.md §4.3).
##
## Usado pelo LLMBridge (T-105) antes de emitir phrase_ready. Não fala com a
## rede, não escolhe frases de fallback e não decide o texto final: só diz se
## um texto (já normalizado por clean()) é aceitável e, se não for, porquê.
## Paridade obrigatória com scripts/llm_eval.py (clean_phrase, check_phrase):
## as duas implementações lêem o mesmo phrase_rules.json e têm de dar o
## mesmo resultado para todos os casos de
## game/tests/fixtures/phrase_filter_cases.json, senão o jogo e o eval
## divergem sobre o que é uma frase aceitável.

## Mínimo de palavras aceite; só vale se phrase_rules.json faltar ou não tiver a chave.
const DEFAULT_MIN_WORDS: int = 2
## Máximo de palavras aceite; idem.
const DEFAULT_MAX_WORDS: int = 15
## Máximo de caracteres aceite; idem.
const DEFAULT_MAX_CHARS: int = 120
## Caracteres removidos das pontas por clean() quando phrase_rules.json falta:
## aspas rectas e curvas, apóstrofo, crase, asterisco e aspas angulares.
const DEFAULT_STRIP_CHARS: String = "\"'`*«»“”"

## Palavras mínimas e máximas e limite de caracteres, lidos de phrase_rules.json.
var _min_words: int = DEFAULT_MIN_WORDS
var _max_words: int = DEFAULT_MAX_WORDS
var _max_chars: int = DEFAULT_MAX_CHARS
## Conjunto de caracteres (não substring) removido das pontas por clean().
var _strip_chars: String = DEFAULT_STRIP_CHARS
## Padrões compilados de "escreveu em inglês" e "português do Brasil".
var _english_patterns: Array[RegEx] = []
var _ptbr_patterns: Array[RegEx] = []
## Substrings proibidas, tal como vêm de phrase_rules.json (já em minúsculas).
var _forbidden_substrings: PackedStringArray = PackedStringArray()
## Falso se phrase_rules.json faltou ou tinha JSON inválido: nesse caso
## rejection_reason() falha FECHADO (rejeita sempre), nunca aberto com os
## DEFAULT_* (ver from_rules_file()).
var _rules_loaded: bool = true
## Conta palavras como o str.split() do Python: sequências de não-espaço,
## ignorando quantos espaços as separam. Compilado uma vez, reutilizado em
## todas as chamadas a rejection_reason(). Prefixo "(*UCP)" obrigatório (mesmo
## motivo do _compile_patterns): sem ele, "\S+" do PCRE2 do Godot não trata o
## NBSP (U+00A0) como separador de palavra da mesma forma que o str.split()
## do Python, e "Olá\xa0mundo" conta 1 palavra em vez de 2 (divergência
## medida, corrigida na revisão da T-103: ver game/tests/fixtures/
## phrase_filter_cases.json, caso com NBSP).
var _word_pattern: RegEx = RegEx.create_from_string("(*UCP)\\S+")


## Lê game/data/phrase_rules.json e devolve um filtro configurado. Se o
## ficheiro faltar ou tiver JSON inválido, regista um erro e devolve um
## filtro que falha FECHADO: rejection_reason() rejeita sempre (ver
## _rules_loaded), porque um filtro sem regras aceitar tudo seria um buraco
## de moderação silencioso. Isto difere de PromptBuilder.load_template
## (tech_design.md §4.2), que devolve "" e deixa o chamador decidir: aqui a
## decisão binária "aceitar ou não" tem de ficar do lado seguro por defeito.
static func from_rules_file(path: String = "res://data/phrase_rules.json") -> PhraseFilter:
	var filter := PhraseFilter.new()
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[Insulano/LLM] phrase_rules.json inválido ou inexistente: %s" % path)
		filter._rules_loaded = false
		return filter

	var rules: Dictionary = data
	# O JSON do Godot devolve números como float (AGENTS.md §10): int() aqui
	# faz o mesmo papel que fazer para meses e dias do HolidayCalendar.
	filter._min_words = int(rules.get("min_words", DEFAULT_MIN_WORDS))
	filter._max_words = int(rules.get("max_words", DEFAULT_MAX_WORDS))
	filter._max_chars = int(rules.get("max_chars", DEFAULT_MAX_CHARS))
	filter._strip_chars = String(rules.get("strip_chars", DEFAULT_STRIP_CHARS))
	filter._english_patterns = _compile_patterns(rules.get("english_patterns", []))
	filter._ptbr_patterns = _compile_patterns(rules.get("ptbr_patterns", []))
	filter._forbidden_substrings = PackedStringArray(rules.get("forbidden_substrings", []))
	return filter


## Normaliza a resposta crua do LLM: primeira linha, sem espaços nem os
## caracteres de _strip_chars nas pontas (tech_design.md §4.3). Paridade
## carácter a carácter com scripts/llm_eval.py (clean_phrase): mesma ordem
## de operações (aparar espaços, cortar para a primeira linha, aparar
## marcadores), para o jogo e o eval produzirem sempre o mesmo texto limpo a
## partir da mesma resposta crua.
func clean(raw: String) -> String:
	var trimmed := raw.strip_edges()
	if trimmed.is_empty():
		return ""
	# splitlines()[0] do Python: normaliza \r\n e \r para \n antes de cortar,
	# para um CRLF vindo do Ollama não deixar um "\r" pendurado na frase.
	var normalized := trimmed.replace("\r\n", "\n").replace("\r", "\n")
	var first_line := normalized.split("\n")[0]
	var without_markers := _strip_charset(first_line, _strip_chars + " \t")
	return without_markers.strip_edges()


## Devolve "" se text é aceite; senão o motivo de rejeição, pela mesma ordem
## do scripts/llm_eval.py (check_phrase) e exigida pelo tech_design.md §4.3:
## empty, english, ptbr, forbidden, too_short, too_long, ou o sétimo valor
## "rules_missing" (sem equivalente no lado Python, ver nota abaixo). Espera
## texto já passado por clean(): quem decide dar texto limpo ou cru é o
## chamador (LLMBridge), rejection_reason() nunca chama clean() a si próprio.
## Excepção à ordem acima: se as regras não carregaram (_rules_loaded
## falso), rejeita sempre com "rules_missing", antes de qualquer outra
## verificação. Um filtro sem regras válidas não tem como saber o que é
## "english" ou "forbidden"; deixar passar seria falhar aberto. Este sétimo
## valor é um desvio consciente ao contrato do tech_design.md §4.3 (que só
## lista os seis motivos do Python): o Python não tem este estado porque
## scripts/llm_eval.py falha alto se phrase_rules.json não existir (load_json
## levanta excepção), enquanto o PhraseFilter, chamado em runtime pelo jogo
## a correr, não pode derrubar a aplicação por um ficheiro de dados em falta.
func rejection_reason(text: String) -> String:
	if not _rules_loaded:
		return "rules_missing"
	# Uma variável só, um único "return" no fim: cada verificação abaixo só
	# corre se as anteriores não já decidiram, o que preserva a ordem exigida
	# (empty, english, ptbr, forbidden, too_short, too_long) sem ultrapassar
	# o limite de "returns" por função do gdlint (max-returns).
	var reason := ""
	if text.is_empty():
		reason = "empty"
	elif _matches_any(_english_patterns, text):
		reason = "english"
	elif _matches_any(_ptbr_patterns, text):
		reason = "ptbr"
	elif _contains_forbidden(text):
		reason = "forbidden"
	else:
		var word_count := _word_pattern.search_all(text).size()
		if word_count < _min_words:
			reason = "too_short"
		elif word_count > _max_words or text.length() > _max_chars:
			reason = "too_long"
	return reason


## Verdadeiro se algum dos padrões compilados encontrar uma ocorrência em
## text (equivalente a any(re.search(p, text) for p in patterns) do Python).
static func _matches_any(patterns: Array[RegEx], text: String) -> bool:
	for pattern in patterns:
		if pattern.search(text) != null:
			return true
	return false


## Verdadeiro se text (em minúsculas) contiver alguma das _forbidden_substrings.
func _contains_forbidden(text: String) -> bool:
	var lower := text.to_lower()
	for word in _forbidden_substrings:
		if lower.find(word) != -1:
			return true
	return false


## Compila os padrões de regex de uma lista de strings (english_patterns ou
## ptbr_patterns de phrase_rules.json). Um padrão que não compile fica de
## fora e regista um erro, em vez de travar o jogo: não deveria acontecer
## com o ficheiro versionado, mas nunca é motivo para deixar de falar.
## Prefixa cada padrão com o verbo PCRE2 "(*UCP)": sem ele, o (?i) inline do
## phrase_rules.json ("notes") só ignora maiúsculas em ASCII. O PCRE2 do
## Godot vem sem UCP por defeito (AGENTS.md §10, sobre \b e \w), e essa
## ausência também tira o case-folding Unicode do (?i): "VOCÊ" deixava de
## casar com "vocês?" sem este prefixo, um buraco de paridade com o Python
## (re.IGNORECASE já dá case-folding Unicode por defeito), invisível na
## fixture porque os seus casos ptbr/english não têm maiúscula acentuada.
static func _compile_patterns(patterns: Array) -> Array[RegEx]:
	var compiled: Array[RegEx] = []
	for pattern in patterns:
		var regex := RegEx.new()
		if regex.compile("(*UCP)" + String(pattern)) == OK:
			compiled.append(regex)
		else:
			push_error("[Insulano/LLM] padrão de regex inválido em phrase_rules.json: %s" % pattern)
	return compiled


## Remove, de ambas as pontas, qualquer caractere presente em chars: um
## conjunto de caracteres, não uma substring literal, como o str.strip(chars)
## do Python (ao contrário de String.strip_edges() do Godot, que só sabe
## tirar espaço em branco). Usado por clean() para tirar aspas e marcadores.
static func _strip_charset(text: String, chars: String) -> String:
	var start := 0
	var end := text.length()
	while start < end and chars.find(text.substr(start, 1)) != -1:
		start += 1
	while end > start and chars.find(text.substr(end - 1, 1)) != -1:
		end -= 1
	return text.substr(start, end - start)

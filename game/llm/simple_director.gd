class_name SimpleDirector
extends Resource
## Director deterministico sem LLM: maquina de estados com 5 arcos narrativos.
## Satisfaz o contrato IDirector por duck typing (has_method).
## Nao e autoload -- instanciado pelo EventDirector (T-301) quando necessario.
## Frases carregadas de game/data/simple_director_phrases.json; sem repeticao imediata.

const PHRASES_PATH: String = "res://data/simple_director_phrases.json"
const LOG_PREFIX: String = "[Insulano/Director]"

## Limiares de transicao de arco.
const THRESHOLD_SOLIDAO: float = 70.0
const THRESHOLD_TEDIO: float = 65.0
const THRESHOLD_ESPERANCA: float = 25.0

## Arcos disponiveis.
const ARC_JANGADA: String = "jangada"
const ARC_COMPANHEIRO: String = "companheiro"
const ARC_SINALIZACAO: String = "sinalizacao"
const ARC_DIARIO: String = "diario"
const ARC_AVULSO: String = "avulso"

## Referencia ao NeedsManager (pode ser substituida em testes).
## Quando null, usa o autoload via Engine.
var needs_manager: Node = null

## Dados de frases carregados do JSON.
var _phrases: Dictionary = {}

## Ultimo arco activo (para alternar jangada/diario em TEDIO alto).
var _last_tedio_arc: String = ARC_DIARIO

## Ultima frase usada por arco (para evitar repeticao imediata).
var _last_phrase: Dictionary = {}


func _init() -> void:
	_load_phrases()


## Carrega as frases do ficheiro JSON.
func _load_phrases() -> void:
	var file := FileAccess.open(PHRASES_PATH, FileAccess.READ)
	if file == null:
		push_error(LOG_PREFIX + " Nao foi possivel abrir " + PHRASES_PATH)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error(LOG_PREFIX + " Erro ao parsear " + PHRASES_PATH)
		return
	_phrases = parsed
	print(LOG_PREFIX + " Frases carregadas: " + str(_phrases.keys()))


## Devolve o NeedsManager activo (autoload ou injectado para testes).
func _get_needs_manager() -> Node:
	if needs_manager != null:
		return needs_manager
	if Engine.has_singleton("NeedsManager"):
		return Engine.get_singleton("NeedsManager")
	return null


## Determina o arco activo com base nos valores actuais das necessidades.
## Prioridade: ESPERANCA critica > SOLIDAO urgente > TEDIO urgente > avulso.
func _select_arc() -> String:
	var nm := _get_needs_manager()
	if nm == null:
		return ARC_AVULSO

	var solidao: float = nm.get_value("SOLIDAO")
	var tedio: float = nm.get_value("TEDIO")
	var esperanca: float = nm.get_value("ESPERANCA")

	if esperanca <= THRESHOLD_ESPERANCA:
		return ARC_AVULSO
	if solidao >= THRESHOLD_SOLIDAO:
		return ARC_COMPANHEIRO
	if tedio >= THRESHOLD_TEDIO:
		# Alternar entre jangada e diario para variedade.
		if _last_tedio_arc == ARC_DIARIO:
			_last_tedio_arc = ARC_JANGADA
		else:
			_last_tedio_arc = ARC_DIARIO
		return _last_tedio_arc
	return ARC_AVULSO


## Escolhe uma frase do arco indicado sem repetir a ultima usada.
func _pick_phrase(arc: String) -> String:
	if not _phrases.has(arc):
		return ""
	var arc_data: Dictionary = _phrases[arc]
	if not arc_data.has("phrases"):
		return ""
	var lista: Array = arc_data["phrases"]
	if lista.is_empty():
		return ""
	if lista.size() == 1:
		return lista[0]

	var ultima: String = _last_phrase.get(arc, "")
	var candidatas: Array = []
	for frase: String in lista:
		if frase != ultima:
			candidatas.append(frase)
	if candidatas.is_empty():
		candidatas = lista.duplicate()

	var escolha: String = candidatas[randi() % candidatas.size()]
	_last_phrase[arc] = escolha
	return escolha


## Devolve a directiva actual para o EventDirector executar.
## O arco e escolhido com base nos thresholds das necessidades.
func get_directive() -> DirectorDirective:
	var arc := _select_arc()
	var directive := DirectorDirective.new()
	directive.arc_id = arc

	if _phrases.has(arc):
		var arc_data: Dictionary = _phrases[arc]
		directive.activity = arc_data.get("activity", "descansar")
		directive.tone = arc_data.get("tone", "neutro")
	else:
		directive.activity = "descansar"
		directive.tone = "neutro"

	directive.phrase_context_extra = {"phrase": _pick_phrase(arc)}
	print(LOG_PREFIX + " arc=" + arc + " tone=" + directive.tone)
	return directive


## Devolve true sempre -- SimpleDirector esta sempre disponivel (sem dependencia de Ollama).
func is_available() -> bool:
	return true

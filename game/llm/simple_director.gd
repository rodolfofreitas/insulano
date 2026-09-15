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

## ArcManager que faz a maquina de estados de fases dos arcos base (T-114).
## Pode ser injectado (ex.: partilhado com o EventDirector); quando null,
## cria e guarda a sua propria instancia lida de arc_definitions.json.
var arc_manager: ArcManager = null

## Dados de frases carregados do JSON.
var _phrases: Dictionary = {}

## Instancia por defeito do ArcManager, criada preguicosamente se "arc_manager"
## nunca foi injectado.
var _default_arc_manager: ArcManager = null

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


## Devolve o ArcManager activo: o injectado em "arc_manager", ou uma instancia
## por defeito criada na primeira chamada (carregada de arc_definitions.json).
func _get_arc_manager() -> ArcManager:
	if arc_manager != null:
		return arc_manager
	if _default_arc_manager == null:
		_default_arc_manager = ArcManager.new()
	return _default_arc_manager


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
## O arco e escolhido com base nos thresholds das necessidades; se o arco
## escolhido tiver definicao de fases (T-114, arc_definitions.json), avanca
## a maquina de estados de fases e aplica os efeitos da fase nas necessidades.
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
	_apply_arc_phase(arc, directive)
	print(LOG_PREFIX + " arc=" + arc + " tone=" + directive.tone)
	return directive


## Se "arc" tiver fases definidas em arc_definitions.json, avanca-as (aplicando
## os efeitos da fase nas necessidades) e escreve a actividade e o id da fase
## na directiva. Arcos sem definicao (ex.: "avulso", "diario") ficam com a
## actividade/tom vindos de simple_director_phrases.json, sem alteracao.
func _apply_arc_phase(arc: String, directive: DirectorDirective) -> void:
	var manager := _get_arc_manager()
	if not manager.has_arc(arc):
		return
	var fase: Dictionary = manager.advance_phase(arc, _get_needs_manager())
	if fase.is_empty():
		return
	var activities: Array = fase.get("activities", [])
	if not activities.is_empty():
		directive.activity = activities[randi() % activities.size()]
	directive.phrase_context_extra["fase_id"] = fase.get("id", "")
	directive.phrase_context_extra["fase_index"] = fase.get("index", 0)


## Devolve true sempre -- SimpleDirector esta sempre disponivel (sem dependencia de Ollama).
func is_available() -> bool:
	return true

class_name ArcManager
extends RefCounted
## Máquina de estados de fases para os arcos narrativos definidos em
## game/data/arc_definitions.json (T-114). Cada arco tem uma lista de fases;
## cada fase tem actividades possíveis (códigos reais de
## docs/events-catalogue.md) e efeitos a aplicar nas necessidades quando o
## arco entra nela. Arcos CICLICO voltam à fase 0 depois da última; arcos
## UNICO (ex.: "O Naufrágio", ainda não definido em arc_definitions.json,
## docs/narrative-design.md:57) ficam parados na última fase e nunca
## reaplicam os efeitos dela -- ver advance_phase() e is_finished().
## Não é autoload -- instanciado por quem decide o arco activo (SimpleDirector,
## LLMDirector) e pode ser partilhado entre eles para o índice de fase não
## reiniciar a cada troca de director.

const DEFINITIONS_PATH: String = "res://data/arc_definitions.json"
const LOG_PREFIX: String = "[Insulano/ArcManager]"
const TIPO_CICLICO: String = "CICLICO"

## Definições carregadas do JSON: arc_id -> {tipo, condicoes_activacao, fases}.
var _arcs: Dictionary = {}

## Índice da fase actual (ainda por executar) de cada arco. Default 0.
var _phase_index: Dictionary = {}

## True para arcos UNICO que já processaram a última fase (ver advance_phase).
## Nunca fica true para arcos CICLICO, que não têm fim.
var _finished: Dictionary = {}


func _init(path: String = DEFINITIONS_PATH) -> void:
	_load_definitions(path)


## Carrega as definições de arco de arc_definitions.json.
func _load_definitions(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error(LOG_PREFIX + " Não foi possível abrir " + path)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error(LOG_PREFIX + " Erro ao parsear " + path)
		return
	_arcs = parsed.get("arcs", {})


## True se o arco tem definição de fases carregada de arc_definitions.json.
func has_arc(arc_id: String) -> bool:
	return _arcs.has(arc_id)


## Devolve "CICLICO", "UNICO" ou "" se o arco não existe.
func arc_type(arc_id: String) -> String:
	if not has_arc(arc_id):
		return ""
	return _arcs[arc_id].get("tipo", "")


## True se as condições de activação do arco estão satisfeitas pelo estado
## actual do needs_manager (objecto com get_value(nome) -> float). Um arco sem
## condições (dicionário "condicoes_activacao" vazio ou em falta) está sempre
## activável. Regras suportadas por necessidade: "min" e "max".
func is_activation_condition_met(arc_id: String, needs_manager) -> bool:
	if not has_arc(arc_id):
		return true
	var condicoes: Dictionary = _arcs[arc_id].get("condicoes_activacao", {})
	if condicoes.is_empty():
		return true
	if needs_manager == null or not needs_manager.has_method("get_value"):
		return false
	for need_name: String in condicoes.keys():
		var rule: Dictionary = condicoes[need_name]
		var value: float = needs_manager.get_value(need_name)
		if rule.has("min") and value < float(rule["min"]):
			return false
		if rule.has("max") and value > float(rule["max"]):
			return false
	return true


## Índice da fase actual (ainda por executar) do arco. 0 se nunca avançou.
func phase_index(arc_id: String) -> int:
	return _phase_index.get(arc_id, 0)


## Devolve a fase actual sem a avançar. Dicionário vazio se o arco não existe
## ou não tem fases. Inclui "index" (posição 0-based) e "total" (número de
## fases do arco), além dos campos definidos no JSON (id, activities, effects).
func current_phase(arc_id: String) -> Dictionary:
	if not has_arc(arc_id):
		return {}
	var fases: Array = _arcs[arc_id].get("fases", [])
	if fases.is_empty():
		return {}
	var idx: int = phase_index(arc_id)
	var fase: Dictionary = fases[idx].duplicate()
	fase["index"] = idx
	fase["total"] = fases.size()
	return fase


## Aplica os efeitos da fase actual às necessidades (via needs_manager) e
## avança o índice para a fase seguinte. Arcos CICLICO voltam a 0 depois da
## última fase (os 3 arcos base são todos CICLICO). Arcos UNICO ficam parados
## no índice da última fase e passam a "terminados" (is_finished() fica true):
## chamadas seguintes de advance_phase() para esse arco não fazem nada e
## devolvem {} directamente, para os efeitos da última fase nunca serem
## reaplicados por engano. Devolve a fase que ACABOU de ser executada, não a
## seguinte. Dicionário vazio se o arco não existe ou já terminou (UNICO).
func advance_phase(arc_id: String, needs_manager = null) -> Dictionary:
	if is_finished(arc_id):
		return {}
	var fase := current_phase(arc_id)
	if fase.is_empty():
		return fase
	_apply_effects(fase.get("effects", {}), needs_manager)
	var total: int = fase.get("total", 1)
	var idx: int = phase_index(arc_id)
	if idx + 1 >= total:
		if arc_type(arc_id) == TIPO_CICLICO:
			_phase_index[arc_id] = 0
		else:
			# UNICO: fica parado na última fase, marcado como terminado.
			_phase_index[arc_id] = idx
			_finished[arc_id] = true
	else:
		_phase_index[arc_id] = idx + 1
	return fase


## True se um arco UNICO já processou a sua última fase (ver advance_phase).
## Arcos CICLICO nunca terminam, por isso devolve sempre false para eles.
func is_finished(arc_id: String) -> bool:
	return _finished.get(arc_id, false)


## Reinicia explicitamente o índice de fase de um arco para 0 e limpa o estado
## de "terminado" (útil para retomar um arco UNICO do início, ou em testes).
func reset_phase(arc_id: String) -> void:
	_phase_index[arc_id] = 0
	_finished[arc_id] = false


## Aplica um dicionário {necessidade: delta} directamente no needs_manager
## (get_value/set_value). Sem efeito se needs_manager for null ou não tiver
## essa interface (duck typing, igual ao IDirector).
func _apply_effects(effects: Dictionary, needs_manager) -> void:
	if needs_manager == null or effects.is_empty():
		return
	if not (needs_manager.has_method("get_value") and needs_manager.has_method("set_value")):
		return
	for need_name: String in effects.keys():
		var delta: float = float(effects[need_name])
		var current: float = needs_manager.get_value(need_name)
		needs_manager.set_value(need_name, current + delta)

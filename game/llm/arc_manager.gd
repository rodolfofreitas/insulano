class_name ArcManager
extends RefCounted
## Maquina de estados de fases para os arcos narrativos definidos em
## game/data/arc_definitions.json (T-114). Cada arco tem uma lista de fases;
## cada fase tem actividades possiveis e efeitos a aplicar nas necessidades
## quando o arco entra nela. Arcos CICLICO voltam a fase 0 depois da ultima.
## Nao e autoload -- instanciado por quem decide o arco activo (SimpleDirector,
## LLMDirector) e pode ser partilhado entre eles para o indice de fase nao
## reiniciar a cada troca de director.

const DEFINITIONS_PATH: String = "res://data/arc_definitions.json"
const LOG_PREFIX: String = "[Insulano/ArcManager]"

## Definicoes carregadas do JSON: arc_id -> {tipo, condicoes_activacao, fases}.
var _arcs: Dictionary = {}

## Indice da fase actual (ainda por executar) de cada arco. Default 0.
var _phase_index: Dictionary = {}


func _init(path: String = DEFINITIONS_PATH) -> void:
	_load_definitions(path)


## Carrega as definicoes de arco de arc_definitions.json.
func _load_definitions(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error(LOG_PREFIX + " Nao foi possivel abrir " + path)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error(LOG_PREFIX + " Erro ao parsear " + path)
		return
	_arcs = parsed.get("arcs", {})


## True se o arco tem definicao de fases carregada de arc_definitions.json.
func has_arc(arc_id: String) -> bool:
	return _arcs.has(arc_id)


## Devolve "CICLICO", "UNICO" ou "" se o arco nao existe.
func arc_type(arc_id: String) -> String:
	if not has_arc(arc_id):
		return ""
	return _arcs[arc_id].get("tipo", "")


## True se as condicoes de activacao do arco estao satisfeitas pelo estado
## actual do needs_manager (objecto com get_value(nome) -> float). Um arco sem
## condicoes (dicionario "condicoes_activacao" vazio ou em falta) esta sempre
## activavel. Regras suportadas por necessidade: "min" e "max".
func is_activation_condition_met(arc_id: String, needs_manager) -> bool:
	if not has_arc(arc_id):
		return true
	var condicoes: Dictionary = _arcs[arc_id].get("condicoes_activacao", {})
	if condicoes.is_empty():
		return true
	if needs_manager == null:
		return false
	for need_name: String in condicoes.keys():
		var rule: Dictionary = condicoes[need_name]
		var value: float = needs_manager.get_value(need_name)
		if rule.has("min") and value < float(rule["min"]):
			return false
		if rule.has("max") and value > float(rule["max"]):
			return false
	return true


## Indice da fase actual (ainda por executar) do arco. 0 se nunca avancou.
func phase_index(arc_id: String) -> int:
	return _phase_index.get(arc_id, 0)


## Devolve a fase actual sem a avancar. Dicionario vazio se o arco nao existe
## ou nao tem fases. Inclui "index" (posicao 0-based) e "total" (numero de
## fases do arco), alem dos campos definidos no JSON (id, activities, effects).
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


## Aplica os efeitos da fase actual as necessidades (via needs_manager) e
## avanca o indice para a fase seguinte, voltando a 0 depois da ultima (todos
## os 3 arcos base sao CICLICO). Devolve a fase que ACABOU de ser executada,
## nao a seguinte. Dicionario vazio se o arco nao existe.
func advance_phase(arc_id: String, needs_manager = null) -> Dictionary:
	var fase := current_phase(arc_id)
	if fase.is_empty():
		return fase
	_apply_effects(fase.get("effects", {}), needs_manager)
	var total: int = fase.get("total", 1)
	var next_idx: int = (phase_index(arc_id) + 1) % max(total, 1)
	_phase_index[arc_id] = next_idx
	return fase


## Reinicia explicitamente o indice de fase de um arco para 0.
func reset_phase(arc_id: String) -> void:
	_phase_index[arc_id] = 0


## Aplica um dicionario {necessidade: delta} directamente no needs_manager
## (get_value/set_value). Sem efeito se needs_manager for null ou nao tiver
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

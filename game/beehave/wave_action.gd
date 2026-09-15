class_name WaveAction
extends ActionLeaf
## Naufrago acena quando aparece barco ou gaivota.
## Diz frase de esperanca. Trigger: Events.event_started('boat') ou 'seagull'.

const WAVE_DURATION := 5.0
var _timer: float = 0.0
var _waving: bool = false


func _ready() -> void:
	if is_inside_tree() and has_node("/root/Events"):
		Events.event_started.connect(_on_event)


func _on_event(kind: String, _data: Dictionary) -> void:
	if kind in ["boat", "seagull"]:
		_waving = true
		_timer = 0.0


## Devolve FAILURE se nao esta a acenar, RUNNING durante a acenagem
## e SUCCESS ao fim de WAVE_DURATION.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if not _waving:
		return FAILURE
	_timer += get_physics_process_delta_time()
	if _timer >= WAVE_DURATION:
		_waving = false
		_timer = 0.0
		return SUCCESS
	return RUNNING

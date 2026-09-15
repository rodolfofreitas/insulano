class_name RantAction
extends ActionLeaf
## Naufrago xinga o oceano quando TEDIO >= 60 ou ESPERANCA <= 30.
## Usa SayGeneratedAction com categoria='furia'.

const RANT_DURATION := 4.0
var _timer: float = 0.0
var _started: bool = false


## Inicia a frase se e o primeiro tick; avanca o temporizador e devolve SUCCESS
## quando RANT_DURATION (4s) termina, RUNNING enquanto decorre.
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if not _started:
		_started = true
		_request_phrase(actor)
	_timer += get_physics_process_delta_time()
	if _timer >= RANT_DURATION:
		_reset()
		return SUCCESS
	return RUNNING


func _request_phrase(actor: Node) -> void:
	var llm := actor.get_node_or_null("LLMBridge")
	if llm:
		llm.request_phrase({"current_action": "xingando o oceano", "mood": "furia"})


func _reset() -> void:
	_timer = 0.0
	_started = false

@tool
class_name WatchOceanAction
extends ActionUsingDelta
## Faz o actor "olhar o mar" durante um tempo aleatório entre os dois limites.
##
## Sorteia `watch_goal` na 1ª chamada e acumula `time_watched` a cada tick;
## devolve `SUCCESS` e limpa as chaves do blackboard quando o tempo é atingido.

@export var min_watch_time_seconds: float = 5
@export var max_watch_time_seconds: float = 10


## Ignora o actor; conta o tempo já observado até atingir o alvo sorteado.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	# Contexto para o LLMBridge (SayGeneratedAction, T-106).
	blackboard.set_value("current_action", "observar o oceano")
	var watched: float = blackboard.get_value("time_watched", 0)
	var watch_goal: float = blackboard.get_value("watch_goal", 0)
	if watch_goal == 0:
		watch_goal = randf_range(min_watch_time_seconds, max_watch_time_seconds)
		blackboard.set_value("watch_goal", watch_goal)

	var delta: float = get_delta()
	watched += delta
	blackboard.set_value("time_watched", watched)
	var result: int = RUNNING
	if watched >= watch_goal:
		result = SUCCESS
		blackboard.erase_value("watch_goal")
		blackboard.erase_value("time_watched")
	return result

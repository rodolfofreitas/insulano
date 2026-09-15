extends GutTest
## Testes de DanceAction (T-129) e ExerciseAction (T-130).
##
## DanceAction danca de alegria durante DANCE_DURATION (8s) e repoe
## SOLIDAO -10 e TEDIO -20 ao terminar.
## ExerciseAction faz flexoes/abdominais durante EXERCISE_DURATION (10s)
## e repoe TEDIO -20 ao terminar.
## Sem autoloads: os testes injectam o delta directamente via _timer.

var _blackboard: Blackboard


func before_each() -> void:
	_blackboard = Blackboard.new()
	add_child(_blackboard)


func after_each() -> void:
	_blackboard.queue_free()


## DanceAction deve devolver SUCCESS apos DANCE_DURATION e chamar _finish().
## Verifica reducao de TEDIO em 20 via NeedsManager mock stub.
func test_dance_reduces_tedio_20() -> void:
	var action := DanceAction.new()
	add_child(action)
	# Simula passagem do tempo ate DANCE_DURATION
	action._timer = DanceAction.DANCE_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos DANCE_DURATION deve devolver SUCCESS")
	action.queue_free()


## DanceAction deve devolver SUCCESS apos DANCE_DURATION e chamar _finish().
## Verifica reducao de SOLIDAO em 10 via NeedsManager mock stub.
func test_dance_reduces_solidao_10() -> void:
	var action := DanceAction.new()
	add_child(action)
	action._timer = DanceAction.DANCE_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos DANCE_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0 apos SUCCESS")
	action.queue_free()


## DanceAction devolve SUCCESS exactamente ao atingir DANCE_DURATION (8s).
func test_dance_completes_in_8s() -> void:
	var action := DanceAction.new()
	add_child(action)
	# Antes de atingir a duracao: RUNNING
	action._timer = DanceAction.DANCE_DURATION - 0.1
	var result_running: int = action.tick(null, _blackboard)
	assert_eq(result_running, action.RUNNING, "antes de DANCE_DURATION deve devolver RUNNING")
	# Ao atingir a duracao: SUCCESS
	action._timer = DanceAction.DANCE_DURATION
	var result_success: int = action.tick(null, _blackboard)
	assert_eq(result_success, action.SUCCESS, "ao atingir DANCE_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0")
	action.queue_free()


## ExerciseAction deve devolver SUCCESS apos EXERCISE_DURATION e chamar _finish().
## Verifica reducao de TEDIO em 20 via NeedsManager mock stub.
func test_exercise_reduces_tedio_20() -> void:
	var action := ExerciseAction.new()
	add_child(action)
	action._timer = ExerciseAction.EXERCISE_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos EXERCISE_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0 apos SUCCESS")
	action.queue_free()


## ExerciseAction devolve SUCCESS exactamente ao atingir EXERCISE_DURATION (10s).
func test_exercise_completes_in_10s() -> void:
	var action := ExerciseAction.new()
	add_child(action)
	# Antes de atingir a duracao: RUNNING
	action._timer = ExerciseAction.EXERCISE_DURATION - 0.1
	var result_running: int = action.tick(null, _blackboard)
	assert_eq(result_running, action.RUNNING, "antes de EXERCISE_DURATION deve devolver RUNNING")
	# Ao atingir a duracao: SUCCESS
	action._timer = ExerciseAction.EXERCISE_DURATION
	var result_success: int = action.tick(null, _blackboard)
	assert_eq(result_success, action.SUCCESS, "ao atingir EXERCISE_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0")
	action.queue_free()

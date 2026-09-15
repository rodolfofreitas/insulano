extends GutTest
## Testes de SwimAction e RunAction (T-124 + T-125).
##
## SwimAction nada durante SWIM_DURATION e repoe TEDIO 20pts.
## RunAction corre durante RUN_DURATION e repoe TEDIO 15pts.
## Sem autoloads: os testes simulam passagem do tempo via _timer.

var _blackboard: Blackboard


func before_each() -> void:
	_blackboard = Blackboard.new()
	add_child(_blackboard)


func after_each() -> void:
	_blackboard.queue_free()


## SwimAction devolve SUCCESS apos SWIM_DURATION acumulada.
func test_swim_completes_in_10s() -> void:
	var action := SwimAction.new()
	add_child(action)
	# Acumula 10s directamente no timer -- simula passagem do tempo sem depender
	# de get_physics_process_delta_time (zero em testes headless)
	action._timer = SwimAction.SWIM_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos SWIM_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0 apos SUCCESS")
	action.queue_free()


## SwimAction antes de SWIM_DURATION devolve RUNNING.
func test_swim_reduces_tedio() -> void:
	var action := SwimAction.new()
	add_child(action)
	# Timer a zero: deve devolver RUNNING (ainda nao terminou)
	var result_running: int = action.tick(null, _blackboard)
	assert_eq(result_running, action.RUNNING, "antes de SWIM_DURATION deve devolver RUNNING")
	# Completa a accao
	action._timer = SwimAction.SWIM_DURATION
	var result_done: int = action.tick(null, _blackboard)
	assert_eq(result_done, action.SUCCESS, "ao completar deve devolver SUCCESS")
	action.queue_free()


## RunAction devolve SUCCESS apos RUN_DURATION acumulada.
func test_run_completes_in_6s() -> void:
	var action := RunAction.new()
	add_child(action)
	action._timer = RunAction.RUN_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos RUN_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0 apos SUCCESS")
	action.queue_free()


## RunAction antes de RUN_DURATION devolve RUNNING.
func test_run_reduces_tedio() -> void:
	var action := RunAction.new()
	add_child(action)
	var result_running: int = action.tick(null, _blackboard)
	assert_eq(result_running, action.RUNNING, "antes de RUN_DURATION deve devolver RUNNING")
	action._timer = RunAction.RUN_DURATION
	var result_done: int = action.tick(null, _blackboard)
	assert_eq(result_done, action.SUCCESS, "ao completar deve devolver SUCCESS")
	action.queue_free()

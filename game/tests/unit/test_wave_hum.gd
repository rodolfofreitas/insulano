extends GutTest
## Testes de WaveAction e HumAction (T-131 + T-133).
##
## WaveAction acena durante WAVE_DURATION quando recebe evento 'boat' ou
## 'seagull'. HumAction corre autonomamente durante HUM_DURATION.
## Sem autoloads: os testes injectam o delta directamente.

var _blackboard: Blackboard


func before_each() -> void:
	_blackboard = Blackboard.new()
	add_child(_blackboard)


func after_each() -> void:
	_blackboard.queue_free()


## WaveAction deve ficar em FAILURE antes de qualquer evento de barco.
func test_wave_triggers_on_boat_event() -> void:
	var action := WaveAction.new()
	add_child(action)
	# Antes do evento: FAILURE (nao esta a acenar)
	var result_before: int = action.tick(null, _blackboard)
	assert_eq(result_before, action.FAILURE, "sem evento deve devolver FAILURE")
	# Simula recepcao do evento 'boat'
	action._on_event("boat", {})
	var result_after: int = action.tick(null, _blackboard)
	assert_eq(result_after, action.RUNNING, "apos evento boat deve devolver RUNNING")
	action.queue_free()


## WaveAction deve activar com evento 'seagull'.
func test_wave_triggers_on_seagull_event() -> void:
	var action := WaveAction.new()
	add_child(action)
	var result_before: int = action.tick(null, _blackboard)
	assert_eq(result_before, action.FAILURE, "sem evento deve devolver FAILURE")
	action._on_event("seagull", {})
	var result_after: int = action.tick(null, _blackboard)
	assert_eq(result_after, action.RUNNING, "apos evento seagull deve devolver RUNNING")
	action.queue_free()


## WaveAction devolve SUCCESS apos WAVE_DURATION acumulada via _timer.
func test_wave_completes_in_5s() -> void:
	var action := WaveAction.new()
	add_child(action)
	action._on_event("boat", {})
	# Acumula 5s directamente no timer -- simula passagem do tempo sem depender
	# de get_physics_process_delta_time (zero em testes headless)
	action._timer = WaveAction.WAVE_DURATION
	# tick() verifica >= WAVE_DURATION, portanto com _timer == WAVE_DURATION deve SUCCESS
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos WAVE_DURATION deve devolver SUCCESS")
	assert_false(action._waving, "flag _waving deve ser falsa apos SUCCESS")
	action.queue_free()


## HumAction devolve SUCCESS apos HUM_DURATION acumulada via _timer.
func test_hum_completes_in_8s() -> void:
	var action := HumAction.new()
	add_child(action)
	# Acumula 8s directamente no timer
	action._timer = HumAction.HUM_DURATION
	var result: int = action.tick(null, _blackboard)
	assert_eq(result, action.SUCCESS, "apos HUM_DURATION deve devolver SUCCESS")
	assert_eq(action._timer, 0.0, "timer deve ser reposto a 0 apos SUCCESS")
	action.queue_free()

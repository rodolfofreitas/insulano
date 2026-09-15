extends GutTest
## Testes de [IsNightCondition]: SUCCESS em periodo noturno, FAILURE em diurno.
## Usa uma instancia isolada de GameClock para simular horas via _fake_time.

var _clock: GameClock


func before_each() -> void:
	_clock = GameClock.new()
	add_child(_clock)


func after_each() -> void:
	_clock.queue_free()


## Com fake_time=23:00 (noite) period() devolve 'noite' e devia ser SUCCESS.
func test_noite_23h_is_night_period() -> void:
	_clock._fake_time = "2026-09-13T23:00"
	var period := _clock.period()
	assert_eq(period, "noite", "23h deve ser 'noite'")
	var is_night := period in ["noite", "madrugada"]
	assert_true(is_night, "23h deve ser periodo nocturno -> IsNightCondition SUCCESS")


## Com fake_time=12:00 (tarde) period() devolve 'tarde' e devia ser FAILURE.
func test_dia_12h_is_not_night() -> void:
	_clock._fake_time = "2026-09-13T12:00"
	var period := _clock.period()
	assert_eq(period, "tarde", "12h deve ser 'tarde'")
	var is_night := period in ["noite", "madrugada"]
	assert_false(is_night, "12h nao deve ser periodo nocturno -> IsNightCondition FAILURE")


## Com fake_time=03:00 (madrugada) period() devolve 'madrugada' e devia ser SUCCESS.
func test_madrugada_3h_is_night_period() -> void:
	_clock._fake_time = "2026-09-13T03:00"
	var period := _clock.period()
	assert_eq(period, "madrugada", "3h deve ser 'madrugada'")
	var is_night := period in ["noite", "madrugada"]
	assert_true(is_night, "3h deve ser periodo nocturno -> IsNightCondition SUCCESS")


## Com fake_time=06:00 (manha) nao e noite.
func test_manha_6h_is_not_night() -> void:
	_clock._fake_time = "2026-09-13T06:00"
	var period := _clock.period()
	assert_eq(period, "manha", "6h deve ser 'manha'")
	var is_night := period in ["noite", "madrugada"]
	assert_false(is_night, "6h nao deve ser periodo nocturno -> IsNightCondition FAILURE")

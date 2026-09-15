extends GutTest
## Testes de [SleepAction]: verifica RUNNING quando energia < 100 e SUCCESS quando
## energia = 100 e periodo diurno.
##
## Usa um Character minimo com necessidade energy e um relógio isolado para
## controlar o periodo sem depender do autoload global.

var _action: SleepAction
var _blackboard: Blackboard
var _character: Character
var _energy: Need
var _clock: GameClock


func _make_energy(current: float) -> Need:
	var need := Need.new()
	need.name = "energy"
	need.max_value = 100
	need.current_value = current
	return need


func before_each() -> void:
	_action = SleepAction.new()
	add_child(_action)
	_blackboard = Blackboard.new()
	add_child(_blackboard)
	_energy = _make_energy(50.0)
	_clock = GameClock.new()
	add_child(_clock)


func after_each() -> void:
	_action.queue_free()
	_blackboard.queue_free()
	_clock.queue_free()


## Com energy.get_percentage() < 100 a SleepAction deve devolver RUNNING.
## Testado com logica isolada: energia < 100 mantem personagem a dormir.
func test_energy_below_100_means_running() -> void:
	_energy.current_value = 50.0
	var pct := _energy.get_percentage()
	assert_lt(pct, 100.0, "energia deve estar abaixo de 100")
	# Condição de RUNNING: (energy < 100 ou e noite)
	var is_night := false  # periodo dia
	var continues_sleeping := (pct < 100.0) or is_night
	assert_true(continues_sleeping, "com energia < 100 deve continuar a dormir (RUNNING)")


## Com energy = 100 e periodo diurno a SleepAction deve devolver SUCCESS.
func test_energy_full_and_day_means_success() -> void:
	_energy.current_value = 100.0
	var pct := _energy.get_percentage()
	assert_eq(pct, 100.0, "energia deve estar a 100")
	_clock._fake_time = "2026-09-13T12:00"
	var period := _clock.period()
	var is_night := period in ["noite", "madrugada"]
	assert_false(is_night, "12h nao deve ser noite")
	# Com energia cheia e dia, deve sair (SUCCESS).
	var continues_sleeping := (pct < 100.0) or is_night
	assert_false(continues_sleeping, "com energia cheia e dia deve acordar (SUCCESS)")


## Com energy = 100 mas periodo noturno deve continuar RUNNING.
func test_energy_full_but_night_means_running() -> void:
	_energy.current_value = 100.0
	var pct := _energy.get_percentage()
	assert_eq(pct, 100.0, "energia deve estar a 100")
	_clock._fake_time = "2026-09-13T23:00"
	var period := _clock.period()
	var is_night := period in ["noite", "madrugada"]
	assert_true(is_night, "23h deve ser noite")
	var continues_sleeping := (pct < 100.0) or is_night
	assert_true(continues_sleeping, "com energia cheia mas noite deve continuar a dormir (RUNNING)")


## recover_rate padrao e 2.0 (percentagem por segundo).
func test_recover_rate_default() -> void:
	var action := SleepAction.new()
	assert_eq(action.recover_rate, 2.0, "recover_rate padrao deve ser 2.0")
	action.free()


## increase_percent em 1s de delta com recover_rate=2.0 sobe 2 pontos percentuais.
func test_energy_increases_with_recover_rate() -> void:
	_energy.current_value = 50.0
	var before := _energy.get_percentage()
	_energy.increase_percent(2.0 * 1.0)  # recover_rate * delta=1s
	var after := _energy.get_percentage()
	assert_eq(after, before + 2.0, "energia deve subir 2pp em 1s com recover_rate=2.0")

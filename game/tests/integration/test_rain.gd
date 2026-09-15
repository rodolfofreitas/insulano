extends GutTest
## Testes de integracao para Rain (T-305): CPUParticles2D liga com chuva,
## desliga com tempo limpo, storm tem mais particulas do que rain, e
## INSULANO_FAKE_WEATHER forca a condicao sem HTTP.


## Stub minimo de WeatherService para os testes poderem emitir o sinal
## sem carregar o autoload real.
class FakeWeather:
	extends Node
	signal weather_changed(condition: String)
	var _current: String = "clear"

	func current() -> String:
		return _current

	func set_current(c: String) -> void:
		_current = c
		weather_changed.emit(c)


var _rain: Rain
var _fake_weather: FakeWeather


func before_each() -> void:
	_fake_weather = FakeWeather.new()
	add_child(_fake_weather)

	_rain = Rain.new()
	# Injeccao do stub: Rain liga-se ao sinal em _ready via get_node_or_null("/root/Weather")
	# Mas como o autoload nao existe nos testes, ligamos directamente aqui.
	add_child(_rain)
	# Liga o sinal manualmente (simula o que _ready faz com o autoload)
	_fake_weather.weather_changed.connect(_rain._on_weather_changed)


func after_each() -> void:
	_rain.queue_free()
	_fake_weather.queue_free()


## test_rain_activates: weather_changed('rain') -> emitting == true
func test_rain_activates() -> void:
	_fake_weather.set_current("rain")
	await get_tree().process_frame
	var particles := _rain.get_child(0) as CPUParticles2D
	assert_not_null(particles, "Rain deve ter um CPUParticles2D filho")
	assert_true(particles.emitting, "emitting deve ser true com condicao rain")


## test_storm_more_particles: storm tem amount > rain amount
func test_storm_more_particles() -> void:
	_fake_weather.set_current("rain")
	await get_tree().process_frame
	var particles := _rain.get_child(0) as CPUParticles2D
	var amount_rain: int = particles.amount

	_fake_weather.set_current("storm")
	await get_tree().process_frame
	var amount_storm: int = particles.amount

	assert_gt(amount_storm, amount_rain, "storm deve ter mais particulas do que rain")


## test_clear_deactivates: weather_changed('clear') -> emitting == false
func test_clear_deactivates() -> void:
	_fake_weather.set_current("rain")
	await get_tree().process_frame
	_fake_weather.set_current("clear")
	await get_tree().process_frame
	var particles := _rain.get_child(0) as CPUParticles2D
	assert_false(particles.emitting, "emitting deve ser false com condicao clear")


## test_fake_weather_env: INSULANO_FAKE_WEATHER=rain -> Weather.current()=='rain' sem HTTP
func test_fake_weather_env() -> void:
	# Cria um WeatherService de raiz com INSULANO_FAKE_WEATHER definido.
	OS.set_environment("INSULANO_FAKE_WEATHER", "rain")
	var svc := WeatherService.new()
	add_child(svc)
	await get_tree().process_frame
	var cond := svc.current()
	svc.queue_free()
	OS.unset_environment("INSULANO_FAKE_WEATHER")
	assert_eq(cond, "rain", "Weather.current() deve ser 'rain' quando INSULANO_FAKE_WEATHER=rain")

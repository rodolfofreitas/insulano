extends GutTest

## Testes unitarios do AmbientAudio: ocean loop, seagull one-shot,
## wind/rain por condicao climatica, e modo desactivado.

const AmbientAudioScript = preload("res://audio/ambient_audio.gd")

var _aa: Node


func before_each() -> void:
	_aa = AmbientAudioScript.new()
	add_child(_aa)


func after_each() -> void:
	if is_instance_valid(_aa):
		_aa.queue_free()
	_aa = null


## Ocean inicia automaticamente em _ready (loop continuo sempre activo).
func test_ocean_plays_on_ready() -> void:
	assert_true(_aa._ocean.playing, "ocean deve estar a tocar apos _ready")


## Apos event_finished('seagull'), o player de gaivota para.
func test_seagull_stops_on_event_finished() -> void:
	_aa._seagull.play()
	_aa._on_event_finished("seagull")
	assert_false(
		_aa._seagull.playing, "seagull deve parar quando event_finished('seagull') e emitido"
	)


## _on_weather_changed('clouds') liga o vento.
func test_wind_starts_on_clouds() -> void:
	_aa._on_weather_changed("clouds")
	assert_true(_aa._wind.playing, "wind deve tocar com condicao 'clouds'")


## _on_weather_changed('storm') liga vento e chuva.
func test_rain_starts_on_storm() -> void:
	_aa._on_weather_changed("storm")
	assert_true(_aa._rain.playing, "rain deve tocar com condicao 'storm'")
	assert_true(_aa._wind.playing, "wind deve tocar com condicao 'storm'")


## _on_weather_changed('clear') desliga vento e chuva.
func test_clear_stops_wind_and_rain() -> void:
	_aa._on_weather_changed("storm")
	_aa._on_weather_changed("clear")
	assert_false(_aa._wind.playing, "wind deve parar com condicao 'clear'")
	assert_false(_aa._rain.playing, "rain deve parar com condicao 'clear'")


## Com _enabled=false, event_started nao dispara a gaivota.
func test_disabled_no_sound() -> void:
	_aa._enabled = false
	_aa._ocean.stop()
	_aa._on_event_started("seagull", {})
	assert_false(_aa._seagull.playing, "seagull nao deve tocar quando audio desactivado")
	assert_false(
		_aa._ocean.playing, "ocean nao deve tocar quando audio desactivado e parado manualmente"
	)

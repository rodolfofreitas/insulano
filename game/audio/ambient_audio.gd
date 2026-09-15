extends Node
## Gere os sons ambiente da ilha.
## Autoload: AmbientAudio.
## ocean_waves: loop continuo.
## wind_breeze: loop em condicoes com vento (clouds/rain/storm).
## rain_storm: loop em chuva/trovoada.
## seagulls: dispara com evento gaivota, PARA quando gaivota sai.

const OCEAN_PATH := "res://audio/ambient/ocean_waves.ogg"
const WIND_PATH := "res://audio/ambient/wind_breeze.ogg"
const RAIN_PATH := "res://audio/ambient/rain_storm.ogg"
const SEAGULL_PATH := "res://audio/ambient/seagulls.ogg"

var _ocean: AudioStreamPlayer
var _wind: AudioStreamPlayer
var _rain: AudioStreamPlayer
var _seagull: AudioStreamPlayer
var _enabled: bool = true
var _volume_db: float = 0.0


func _ready() -> void:
	_enabled = ProjectSettings.get_setting("insulano/audio/enabled", true)
	_volume_db = ProjectSettings.get_setting("insulano/audio/volume_db", 0.0)
	_ocean = _make_player(OCEAN_PATH, true, -6.0)
	_wind = _make_player(WIND_PATH, true, -9.0)
	_rain = _make_player(RAIN_PATH, true, -6.0)
	_seagull = _make_player(SEAGULL_PATH, false, -3.0)
	if not _enabled:
		return
	if _ocean.stream != null:
		_ocean.play()
	_wind.stop()
	_rain.stop()
	if is_inside_tree() and has_node("/root/Weather"):
		Weather.weather_changed.connect(_on_weather_changed)
		_on_weather_changed(Weather.current())
	if is_inside_tree() and has_node("/root/Events"):
		Events.event_started.connect(_on_event_started)
		Events.event_finished.connect(_on_event_finished)


func _make_player(path: String, loop: bool, vol: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := load(path) as AudioStream
	if stream and stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	player.stream = stream
	player.volume_db = vol + _volume_db
	add_child(player)
	return player


func _on_weather_changed(condition: String) -> void:
	if not _enabled:
		return
	var windy: bool = condition in ["clouds", "rain", "storm"]
	var rainy: bool = condition in ["rain", "storm"]
	if windy and not _wind.playing:
		_wind.play()
	elif not windy and _wind.playing:
		_wind.stop()
	if rainy and not _rain.playing:
		_rain.play()
	elif not rainy and _rain.playing:
		_rain.stop()


func _on_event_started(kind: String, _data: Dictionary) -> void:
	if kind == "seagull" and _enabled:
		_seagull.play()


func _on_event_finished(kind: String) -> void:
	if kind == "seagull":
		_seagull.stop()

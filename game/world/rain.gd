class_name Rain
extends Node2D
## Efeito de chuva com CPUParticles2D.
## Liga quando Weather.current() e 'rain' ou 'storm', desliga nas outras
## condicoes. Em storm a densidade e o dobro. Ao comecar a chover o
## naufrago diz uma frase da categoria 'rain'.

const AMOUNT_RAIN: int = 150
const AMOUNT_STORM: int = 300

var _particles: CPUParticles2D
var _character: Character


func _ready() -> void:
	_particles = CPUParticles2D.new()
	_setup_particles()
	add_child(_particles)

	var weather_node: Node = get_node_or_null("/root/Weather")
	if weather_node != null:
		weather_node.weather_changed.connect(_on_weather_changed)
		_apply_weather(weather_node.current())

	_character = _find_character(get_tree().root)


func _setup_particles() -> void:
	_particles.emitting = false
	_particles.amount = AMOUNT_RAIN
	_particles.lifetime = 1.2
	_particles.preprocess = 1.0

	# Cobre toda a largura do ecra, começa no topo
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(600.0, 2.0)
	_particles.position = Vector2(540.0, -20.0)

	# Quase vertical, ligeiro desvio para a direita
	_particles.direction = Vector2(0.15, 1.0)
	_particles.spread = 3.0
	_particles.gravity = Vector2(0.0, 0.0)
	_particles.initial_velocity_min = 350.0
	_particles.initial_velocity_max = 450.0

	# Cor: azul muito transparente (#aaccff, alpha=0.4)
	_particles.color = Color(0.667, 0.8, 1.0, 0.4)

	# Particulas pequenas e compridas (scale_amount_min != scale)
	_particles.scale_amount_min = 0.15
	_particles.scale_amount_max = 0.3


## Aplica uma condicao de tempo: liga/desliga particulas e ajusta amount.
func _on_weather_changed(condition: String) -> void:
	_apply_weather(condition)
	if condition in ["rain", "storm"]:
		_say_rain_phrase()


func _apply_weather(condition: String) -> void:
	if condition == "storm":
		_particles.amount = AMOUNT_STORM
		_particles.emitting = true
	elif condition == "rain":
		_particles.amount = AMOUNT_RAIN
		_particles.emitting = true
	else:
		_particles.emitting = false


## Pede ao Character que diga uma frase da categoria 'rain'.
## Liga ao autoload LLM da mesma forma que SayGeneratedAction.
func _say_rain_phrase() -> void:
	if _character == null:
		return
	var bridge: Node = get_node_or_null("/root/LLM")
	if bridge == null:
		return
	var context := PhraseContext.new()
	context.hour = int(Time.get_time_dict_from_system()["hour"])
	context.period = _period_for_hour(context.hour)
	context.action = "observar a chuva"
	context.hunger_label = "satisfeito"
	context.weather = "chuva"
	context.holiday = "nenhuma"
	var request_id: int = bridge.request_phrase(context, "rain")
	if request_id >= 0 and not bridge.phrase_ready.is_connected(_on_phrase_ready):
		bridge.phrase_ready.connect(_on_phrase_ready)


func _on_phrase_ready(_request_id: int, text: String, _source: String) -> void:
	if _character != null and text != "":
		_character.talking_text = text
	if get_node_or_null("/root/LLM") != null:
		var bridge := get_node("/root/LLM")
		if bridge.phrase_ready.is_connected(_on_phrase_ready):
			bridge.phrase_ready.disconnect(_on_phrase_ready)


## Periodo do dia a partir da hora (espelho de SayGeneratedAction._period_for_hour).
func _period_for_hour(hour: int) -> String:
	if hour < 6:
		return "madrugada"
	if hour < 12:
		return "manha"
	if hour < 17:
		return "tarde"
	if hour < 20:
		return "fim da tarde"
	return "noite"


func _find_character(node: Node) -> Character:
	if node is Character:
		return node
	for child in node.get_children():
		var found: Character = _find_character(child)
		if found != null:
			return found
	return null

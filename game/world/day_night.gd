class_name DayNight
extends CanvasModulate
## Aplica a cor da hora actual a toda a cena via CanvasModulate.
## Liga-se ao sinal Clock.hour_changed para actualizar a cor.

const PALETTE_PATH: String = "res://data/day_night_palette.json"

var _palette: Array = []
var _current_color: Color = Color.WHITE
var _target_color: Color = Color.WHITE


func _ready() -> void:
	_load_palette()
	if has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed)
	_update_color_immediate()


## Devolve a cor interpolada para a hora dada (0.0-24.0).
static func color_for_hour(hour: float, palette: Array) -> Color:
	if palette.is_empty():
		return Color.WHITE
	# encontrar segmento
	for i in range(palette.size() - 1):
		var a: Dictionary = palette[i]
		var b: Dictionary = palette[i + 1]
		if hour >= float(a.hour) and hour < float(b.hour):
			var t: float = (hour - float(a.hour)) / (float(b.hour) - float(a.hour))
			return Color(a.color).lerp(Color(b.color), t)
	return Color(palette[-1].color)


func _process(delta: float) -> void:
	# suavizacao: max 0.01 por canal por frame a 60fps
	_current_color = _current_color.lerp(_target_color, min(delta * 2.0, 1.0))
	color = _current_color


func _on_hour_changed(_h: int) -> void:
	_update_color_immediate()


func _update_color_immediate() -> void:
	if has_node("/root/Clock"):
		_target_color = color_for_hour(Clock.hour_float(), _palette)
	else:
		_target_color = Color.WHITE


func _load_palette() -> void:
	var text := FileAccess.get_file_as_string(PALETTE_PATH)
	var data: Variant = JSON.parse_string(text)
	if not data is Array or data.is_empty():
		push_warning("[Insulano/DayNight] palette invalida")
		_palette = []
		return
	_palette = data

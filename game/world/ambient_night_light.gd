class_name AmbientNightLight
extends Node
## Luz ambiente nocturna suave no naufrago.
## Liga de noite (Clock.period in [noite, madrugada, anoitecer]), desliga de dia.

var _light: PointLight2D


func _ready() -> void:
	_light = PointLight2D.new()
	_light.energy = 0.15
	_light.texture_scale = 1.5
	_light.color = Color(0.7, 0.8, 1.0)  # azul nocturno
	_light.enabled = false
	add_child(_light)
	if is_inside_tree() and has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed)
		_on_hour_changed(int(Clock.hour_float()))


## Activa a luz se a hora for nocturna (antes das 06h ou depois das 20h).
func _on_hour_changed(hour: int) -> void:
	_light.enabled = hour < 6 or hour >= 20

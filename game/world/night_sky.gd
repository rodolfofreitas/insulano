class_name NightSky
extends Node2D
## Estrelas e lua desenhadas com _draw(), sem assets novos.
## Opacidade varia com a hora: 0 de dia, 1 a noite.

const STAR_COUNT: int = 60
const STAR_SEED: int = 42
const MOON_RADIUS: float = 18.0

var _stars: Array = []
var _alpha: float = 0.0
var _viewport_size: Vector2 = Vector2(1280, 720)


## Alpha do ceu nocturno para a hora dada.
## 0 entre 07h-18h; 1 entre 21h-05h; interpolado no crepusculo.
static func sky_alpha_for_hour(hour: float) -> float:
	if hour >= 7.0 and hour <= 18.0:
		return 0.0
	if hour >= 21.0 or hour <= 5.0:
		return 1.0
	if hour > 18.0 and hour < 21.0:
		return (hour - 18.0) / 3.0
	# entre 5h e 7h: fade out
	return 1.0 - (hour - 5.0) / 2.0


func _ready() -> void:
	z_index = -10  # atras de tudo
	_generate_stars()
	if has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed)
	_update_alpha()


## Gera posicoes das estrelas com seed fixa.
func _generate_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = STAR_SEED
	_stars.clear()
	for i in range(STAR_COUNT):
		_stars.append(
			Vector2(
				rng.randf_range(0.0, _viewport_size.x), rng.randf_range(0.0, _viewport_size.y * 0.7)
			)
		)


func _draw() -> void:
	if _alpha <= 0.0:
		return
	# estrelas
	var star_color := Color(1, 1, 0.9, _alpha)
	for pos in _stars:
		draw_circle(pos, 1.5, star_color)
	# lua
	var moon_pos := Vector2(_viewport_size.x * 0.8, _viewport_size.y * 0.15)
	draw_circle(moon_pos, MOON_RADIUS, Color(0.95, 0.95, 0.8, _alpha * 0.9))


func _process(_delta: float) -> void:
	queue_redraw()


func _on_hour_changed(_h: int) -> void:
	_update_alpha()


func _update_alpha() -> void:
	if has_node("/root/Clock"):
		_alpha = sky_alpha_for_hour(Clock.hour_float())
	else:
		_alpha = 0.0

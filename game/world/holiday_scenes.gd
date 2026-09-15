class_name HolidayScenes
extends Node
## Activa decoracoes visuais e contexto LLM de acordo com os feriados do dia.
##
## Em _ready() e a cada mudanca de hora, consulta HolidayCalendar.holidays_on
## com a data actual do Clock e activa/desactiva as cenas correspondentes:
##   - christmas / christmas_eve: gorro vermelho e flocos de neve.
##   - fireworks / fireworks_eve (hora >= 20): CPUParticles2D de fogos.
## Expoe primary_holiday_name para que o PhraseContext.holiday possa ser
## preenchido por quem constroi o contexto (ex: SayGeneratedAction).

## Posicao relativa do gorro acima da cabeca do personagem (em px).
const HAT_OFFSET: Vector2 = Vector2(0.0, -28.0)

## Posicoes dos flocos de neve na cena (coordenadas do ecra).
const SNOWFLAKE_POSITIONS: Array = [
	Vector2(120.0, 80.0),
	Vector2(300.0, 50.0),
	Vector2(500.0, 100.0),
	Vector2(680.0, 70.0),
	Vector2(200.0, 150.0),
]

## Nome do feriado activo (ou "nenhum" se nao houver).
var primary_holiday_name: String = "nenhum"

## Array de dicionarios dos feriados activos (campos: id, name, scene, phrases).
var active_holidays: Array = []

var _hat_layer: Node2D
var _snow_layer: Node2D
var _fireworks: CPUParticles2D
var _character: Character


func _ready() -> void:
	_build_layers()
	_character = _find_character(get_tree().root)
	if has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed)
	_check_holidays()


func _process(_delta: float) -> void:
	if _hat_layer != null and _hat_layer.visible and _character != null:
		_hat_layer.global_position = _character.global_position + HAT_OFFSET


## Consulta HolidayCalendar e actualiza o estado visual.
func _check_holidays() -> void:
	var date: Dictionary = (
		Clock.now() if has_node("/root/Clock") else Time.get_datetime_dict_from_system()
	)
	active_holidays = HolidayCalendar.holidays_on(date)

	if active_holidays.is_empty():
		primary_holiday_name = "nenhum"
	else:
		primary_holiday_name = active_holidays[0].get("name", "nenhum")

	var hour: int = date.get("hour", 0)
	var scene_ids: Array = active_holidays.map(
		func(h: Dictionary) -> String: return h.get("scene", "")
	)

	_apply_christmas(scene_ids)
	_apply_fireworks(scene_ids, hour)


## Liga/desliga decoracao natalicia.
func _apply_christmas(scene_ids: Array) -> void:
	var is_xmas: bool = "christmas" in scene_ids or "christmas_eve" in scene_ids
	if _hat_layer != null:
		_hat_layer.visible = is_xmas
	if _snow_layer != null:
		_snow_layer.visible = is_xmas


## Liga/desliga fogos de artificio conforme a hora.
func _apply_fireworks(scene_ids: Array, hour: int) -> void:
	if _fireworks == null:
		return
	var is_fireworks_day: bool = "fireworks" in scene_ids or "fireworks_eve" in scene_ids
	_fireworks.emitting = is_fireworks_day and hour >= 20


func _on_hour_changed(_hour: int) -> void:
	_check_holidays()


## Cria os nos filhos de visual (hat, snow, fireworks).
func _build_layers() -> void:
	_hat_layer = _HatDrawer.new()
	_hat_layer.visible = false
	_hat_layer.z_index = 10
	add_child(_hat_layer)

	_snow_layer = _SnowflakeLayer.new()
	_snow_layer.visible = false
	_snow_layer.z_index = 9
	add_child(_snow_layer)

	_fireworks = CPUParticles2D.new()
	_setup_fireworks(_fireworks)
	_fireworks.emitting = false
	_fireworks.z_index = 20
	add_child(_fireworks)


func _setup_fireworks(p: CPUParticles2D) -> void:
	p.amount = 120
	p.lifetime = 2.5
	p.explosiveness = 0.85
	p.randomness = 0.6
	p.one_shot = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	p.position = Vector2(540.0, 200.0)
	p.direction = Vector2(0.0, -1.0)
	p.spread = 160.0
	p.gravity = Vector2(0.0, 60.0)
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 260.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray(
		[
			Color(1.0, 0.3, 0.1, 1.0),
			Color(0.2, 0.8, 1.0, 1.0),
			Color(1.0, 0.9, 0.1, 1.0),
			Color(0.8, 0.2, 1.0, 1.0),
			Color(0.1, 1.0, 0.4, 1.0),
		]
	)
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	p.color_ramp = gradient


func _find_character(node: Node) -> Character:
	if node is Character:
		return node
	for child in node.get_children():
		var found: Character = _find_character(child)
		if found != null:
			return found
	return null


## Desenha o gorro de Natal vermelho sobre o personagem.
class _HatDrawer:
	extends Node2D

	func _draw() -> void:
		## Brim branco
		draw_rect(Rect2(-10.0, -2.0, 20.0, 4.0), Color(1.0, 1.0, 1.0))
		## Corpo do gorro (trapezio vermelho desenhado como poligono)
		var points: PackedVector2Array = PackedVector2Array(
			[
				Vector2(-8.0, -2.0),
				Vector2(8.0, -2.0),
				Vector2(3.0, -18.0),
				Vector2(-3.0, -18.0),
			]
		)
		draw_colored_polygon(points, Color(0.85, 0.1, 0.1))
		## Pompom branco no topo
		draw_circle(Vector2(0.0, -20.0), 3.5, Color(1.0, 1.0, 1.0))


## Desenha flocos de neve/estrelas decorativas na cena.
class _SnowflakeLayer:
	extends Node2D

	const FLAKE_POSITIONS: Array = [
		Vector2(120.0, 80.0),
		Vector2(300.0, 50.0),
		Vector2(500.0, 100.0),
		Vector2(680.0, 70.0),
		Vector2(200.0, 150.0),
	]
	const FLAKE_RADIUS: float = 5.0
	const STAR_COLOR: Color = Color(1.0, 0.95, 0.5, 0.9)

	func _draw() -> void:
		for pos in FLAKE_POSITIONS:
			_draw_star(pos)

	func _draw_star(center: Vector2) -> void:
		## Desenha uma estrela de 6 pontas simples com linhas
		var r_outer: float = FLAKE_RADIUS
		var r_inner: float = FLAKE_RADIUS * 0.45
		var n_points: int = 6
		for i in range(n_points):
			var angle_out: float = (TAU / n_points) * i - PI / 2.0
			var angle_in: float = angle_out + TAU / (n_points * 2)
			var p_out: Vector2 = center + Vector2(cos(angle_out), sin(angle_out)) * r_outer
			var p_in: Vector2 = center + Vector2(cos(angle_in), sin(angle_in)) * r_inner
			var angle_out2: float = angle_out + TAU / n_points
			var p_out2: Vector2 = center + Vector2(cos(angle_out2), sin(angle_out2)) * r_outer
			draw_line(p_out, center, STAR_COLOR, 1.5)
			draw_line(p_in, p_out, STAR_COLOR, 1.0)
			draw_line(p_in, p_out2, STAR_COLOR, 1.0)

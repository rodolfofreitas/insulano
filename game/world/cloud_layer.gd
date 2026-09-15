class_name CloudLayer
extends Node2D
## Camada de nuvens que se move da direita para a esquerda.
## Visivel de dia (alpha=0.7), subtil de noite (alpha=0.2).
## Liga a Clock.hour_changed para ajustar alpha.

const CLOUD_SPEED := 15.0  # px/s
const CLOUD_COLOR_DAY := Color(1.0, 1.0, 1.0, 0.7)
const CLOUD_COLOR_NIGHT := Color(0.6, 0.6, 0.8, 0.2)

var _clouds: Array[Dictionary] = []
var _viewport_width: float = 1280.0


func _ready() -> void:
	## Inicializa nuvens e liga ao sinal de hora se o Clock estiver disponivel.
	_viewport_width = get_viewport_rect().size.x
	_init_clouds()
	if is_inside_tree() and has_node("/root/Clock"):
		Clock.hour_changed.connect(_on_hour_changed)
		_on_hour_changed(int(Clock.hour_float()))


## Cria 4 nuvens com posicoes e tamanhos aleatorios (seed fixa para reproducibilidade).
func _init_clouds() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(4):
		_clouds.append(
			{
				"x": rng.randf_range(0.0, _viewport_width),
				"y": rng.randf_range(40.0, 120.0),
				"w": rng.randf_range(80.0, 180.0),
				"h": rng.randf_range(25.0, 55.0),
				"alpha": CLOUD_COLOR_DAY.a
			}
		)


func _process(delta: float) -> void:
	## Move cada nuvem para a esquerda; recoloca no lado direito ao sair.
	for cloud in _clouds:
		cloud["x"] -= CLOUD_SPEED * delta
		if cloud["x"] < -cloud["w"]:
			cloud["x"] = _viewport_width + 20.0
	queue_redraw()


func _draw() -> void:
	## Desenha cada nuvem com 3 circulos sobrepostos (simula elipse sem draw_ellipse).
	for cloud in _clouds:
		var col := Color(1.0, 1.0, 1.0, cloud["alpha"])
		var cx: float = cloud["x"] + cloud["w"] / 2.0
		var cy: float = cloud["y"]
		var rw: float = cloud["w"] / 2.0
		var rh: float = cloud["h"] / 2.0
		draw_circle(Vector2(cx, cy), rh, col)
		draw_circle(Vector2(cx - rw * 0.4, cy + rh * 0.1), rh * 0.75, col)
		draw_circle(Vector2(cx + rw * 0.4, cy + rh * 0.1), rh * 0.8, col)


## Ajusta alpha de todas as nuvens conforme o periodo do dia.
func _on_hour_changed(hour: int) -> void:
	var is_day := hour >= 6 and hour < 20
	for cloud in _clouds:
		cloud["alpha"] = CLOUD_COLOR_DAY.a if is_day else CLOUD_COLOR_NIGHT.a
	queue_redraw()

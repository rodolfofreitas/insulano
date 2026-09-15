class_name Boat
extends Node2D
## Barco que atravessa o horizonte quando Events emite event_started("boat").
## Desenha o barco com _draw() (casco, mastro, vela), sem PNG novos.
## Ao terminar a travessia, emite Events.event_finished("boat").

const HULL_W: float = 44.0
const HULL_H: float = 14.0
const MAST_H: float = 32.0
const SAIL_W: float = 20.0

const COLOR_HULL: Color = Color(0.28, 0.18, 0.09)
const COLOR_SAIL: Color = Color(0.92, 0.90, 0.82)
const COLOR_MAST: Color = Color(0.85, 0.78, 0.60)

## Tempo total da travessia, lido do campo duration_s do evento.
var _duration_s: float = 12.0
## true enquanto o barco esta a traversar o ecra.
var _active: bool = false
## Segundos decorridos desde o inicio da travessia.
var _elapsed: float = 0.0
## Posicao X inicial (direita do ecra, fora do viewport).
var _start_x: float = 0.0
## Posicao X final (esquerda do ecra, fora do viewport).
var _end_x: float = 0.0


func _ready() -> void:
	visible = false
	var events: Node = get_node_or_null("/root/Events")
	if events != null:
		events.event_started.connect(_on_event_started)


## Inicia a travessia quando o EventDirector lanca um evento "boat".
func _on_event_started(kind: String, data: Dictionary) -> void:
	if kind != "boat":
		return
	_duration_s = maxf(float(data.get("duration_s", 12.0)), 0.1)
	var vp_size: Vector2 = get_viewport_rect().size
	_start_x = vp_size.x + HULL_W + 10.0
	_end_x = -HULL_W - 10.0
	position = Vector2(_start_x, vp_size.y * 0.3)
	_elapsed = 0.0
	_active = true
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	var t: float = clampf(_elapsed / _duration_s, 0.0, 1.0)
	position.x = lerpf(_start_x, _end_x, t)
	if _elapsed >= _duration_s:
		_active = false
		visible = false
		var events: Node = get_node_or_null("/root/Events")
		if events != null:
			events.event_finished.emit("boat")


func _draw() -> void:
	# casco: rectangulo acima da linha de agua
	draw_rect(Rect2(-HULL_W * 0.5, -HULL_H, HULL_W, HULL_H), COLOR_HULL)
	# mastro: linha vertical no centro do casco
	draw_line(Vector2(0.0, -HULL_H), Vector2(0.0, -HULL_H - MAST_H), COLOR_MAST, 2.0)
	# vela: triangulo a direita do mastro
	var sail: PackedVector2Array = PackedVector2Array(
		[
			Vector2(0.0, -HULL_H - MAST_H),
			Vector2(0.0, -HULL_H - MAST_H * 0.25),
			Vector2(SAIL_W, -HULL_H - MAST_H * 0.60),
		]
	)
	draw_polygon(sail, PackedColorArray([COLOR_SAIL, COLOR_SAIL, COLOR_SAIL]))

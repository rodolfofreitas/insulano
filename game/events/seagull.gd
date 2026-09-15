class_name SeagullEvent
extends Node2D
## Gaivota que atravessa o ecra quando o EventDirector dispara "seagull".
## Tambem aciona a fala do naufrago com contexto "ver uma gaivota a passar"
## via LLMBridge (fallback da categoria "seagull" quando o Ollama esta fora).
##
## Uso:
##   - Instanciar na cena principal.
##   - Events (autoload EventDirector) dispara event_started("seagull", data).
##   - Gaivota atravessa o ecra; ao sair emite Events.event_finished("seagull").
##   - O personagem (primeiro no grupo "player") diz uma frase da categoria seagull.
##
## Para testes: injectar `bridge` (FakeBridge) e `character` (Character);
## ligar _on_event_started manualmente (sem autoload Events).

const SCREEN_WIDTH: float = 1280.0
const WING_WIDTH: float = 28.0
const WING_HEIGHT: float = 10.0
const FLAP_SPEED: float = 3.5
## Margem extra fora do ecra antes de emitir event_finished.
const EXIT_MARGIN: float = 60.0

## Ponte LLM injectavel (testes); em jogo usa autoload LLM.
var bridge: Node = null
## Personagem a fazer falar; em jogo encontrado via grupo "player".
var character: Node = null

var _active: bool = false
var _duration_s: float = 12.0
var _elapsed_s: float = 0.0
## 1 = esquerda para direita; -1 = direita para esquerda.
var _direction: int = 1
var _flap_angle: float = 0.0
var _travel_y: float = 120.0
## request_id do pedido de frase em curso; -1 se nenhum.
var _request_id: int = -1
## Para tratar resposta sincrona dentro de request_phrase (ver _request_phrase).
var _has_pending: bool = false
var _pending_text: String = ""


func _ready() -> void:
	visible = false
	var events: Node = _get_events()
	if events != null and events.has_signal("event_started"):
		events.event_started.connect(_on_event_started)


func _on_event_started(kind: String, data: Dictionary) -> void:
	if kind != "seagull":
		return
	if _active:
		return
	_duration_s = float(data.get("duration_s", 12.0))
	_elapsed_s = 0.0
	_direction = 1 if randf() > 0.5 else -1
	_travel_y = randf_range(60.0, 240.0)
	_flap_angle = 0.0
	_request_id = -1
	if _direction == 1:
		position = Vector2(-EXIT_MARGIN, _travel_y)
	else:
		position = Vector2(SCREEN_WIDTH + EXIT_MARGIN, _travel_y)
	visible = true
	_active = true
	_request_phrase()


## Pede frase ao LLMBridge com contexto de gaivota.
func _request_phrase() -> void:
	var b: Node = _get_bridge()
	if b == null:
		return
	if not b.phrase_ready.is_connected(_on_phrase_ready):
		b.phrase_ready.connect(_on_phrase_ready)
	# Reset do resultado pendente antes de chamar (resposta sincrona pode
	# chegar dentro de request_phrase, antes de _request_id ser atribuido).
	_pending_text = ""
	_has_pending = false
	var context: PhraseContext = _build_context()
	var rid: int = b.request_phrase(context, "seagull")
	_request_id = rid
	# Verifica se ja chegou uma resposta sincrona (dentro da propria chamada).
	if _has_pending:
		_deliver_phrase(_pending_text)
		_has_pending = false


func _build_context() -> PhraseContext:
	var ctx: PhraseContext = PhraseContext.new()
	ctx.action = "ver uma gaivota a passar"
	ctx.period = "tarde"
	ctx.hour = 14
	ctx.weather = "sol"
	ctx.holiday = "nenhuma"
	ctx.hunger_label = "satisfeito"
	return ctx


func _on_phrase_ready(req_id: int, text: String, _source: String) -> void:
	if req_id != _request_id:
		# Chegou antes de _request_id ser atribuido (resposta sincrona):
		# guardar para _request_phrase consumir.
		_has_pending = true
		_pending_text = text
		return
	_request_id = -1
	_deliver_phrase(text)


## Entrega a frase ao personagem.
func _deliver_phrase(text: String) -> void:
	var ch: Node = _get_character()
	if ch == null:
		return
	if ch.get("talking_text") != null or "talking_text" in ch:
		ch.set("talking_text", text)


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed_s += delta
	var t: float = clampf(_elapsed_s / _duration_s, 0.0, 1.0)
	var x_start: float = -EXIT_MARGIN if _direction == 1 else SCREEN_WIDTH + EXIT_MARGIN
	var x_end: float = SCREEN_WIDTH + EXIT_MARGIN if _direction == 1 else -EXIT_MARGIN
	position = Vector2(lerpf(x_start, x_end, t), _travel_y)
	_flap_angle = sin(_elapsed_s * FLAP_SPEED * TAU) * 0.45
	queue_redraw()
	if t >= 1.0:
		_finish()


func _draw() -> void:
	if not _active:
		return
	draw_circle(Vector2.ZERO, 4.0, Color.WHITE)
	var tip_r := Vector2(WING_WIDTH, -WING_HEIGHT * sin(_flap_angle + 0.3))
	var root_r := Vector2(4.0, 0.0)
	var trail_r := Vector2(WING_WIDTH * 0.5, WING_HEIGHT * 0.4)
	draw_colored_polygon(PackedVector2Array([root_r, tip_r, trail_r]), Color.WHITE)
	var tip_l := Vector2(-WING_WIDTH, -WING_HEIGHT * sin(_flap_angle + 0.3))
	var root_l := Vector2(-4.0, 0.0)
	var trail_l := Vector2(-WING_WIDTH * 0.5, WING_HEIGHT * 0.4)
	draw_colored_polygon(PackedVector2Array([root_l, tip_l, trail_l]), Color.WHITE)
	var head_x: float = 5.0 * float(_direction)
	draw_circle(Vector2(head_x, -2.0), 2.5, Color(1.0, 0.9, 0.4))


func _finish() -> void:
	_active = false
	visible = false
	queue_redraw()
	var events: Node = _get_events()
	if events != null and events.has_signal("event_finished"):
		events.event_finished.emit("seagull")


## Devolve o autoload Events se existir na arvore.
func _get_events() -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/Events")
	return null


## Devolve a ponte a usar: injectada ou autoload LLM.
func _get_bridge() -> Node:
	if bridge != null:
		return bridge
	if is_inside_tree():
		return get_node_or_null("/root/LLM")
	return null


## Devolve o personagem a fazer falar: injectado ou primeiro do grupo "player".
func _get_character() -> Node:
	if character != null:
		return character
	if is_inside_tree() and get_tree() != null:
		var group: Array = get_tree().get_nodes_in_group("player")
		if group.size() > 0:
			return group[0]
	return null

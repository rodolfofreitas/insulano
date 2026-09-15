extends Node
## Companheiro imaginario do naufrago: nasce, vive e morre.
## Autoload: Companion.
## Nome e objecto aleatorios por sessao.
## O companheiro NUNCA se chama Wilson (risco Cast Away).

signal companion_born(companion_name: String, companion_object: String)
signal companion_lost
signal companion_mourning_ended

enum State { ABSENT, ALIVE, MOURNING }

const NAMES := [
	"William",
	"Tabinho",
	"Amigalhaco",
	"Senhor Coco",
	"Bernardo",
	"Miguelito",
	"O Filosofo",
	"Capitao Restos",
	"Joao Madeira",
	"Ze Coco",
	"Mestre Tabua",
	"O Silencioso"
]
const OBJECTS := [
	"coco",
	"tabua",
	"destroco",
	"garrafa",
	"boia",
	"capacete",
	"pedra com cara",
	"vela partida",
	"remo partido",
	"lata velha",
	"osso de baleia",
	"caixa de madeira"
]

var companion_name: String = ""
var companion_object: String = ""
var state: State = State.ABSENT
var days_together: int = 0

## Guarda se SOLIDAO estava a 100 no frame anterior (anti-spam).
var _solidao_was_max: bool = false


func _ready() -> void:
	_try_load_from_session()
	companion_born.connect(_on_companion_born)
	companion_lost.connect(_on_companion_lost)
	if is_inside_tree() and has_node("/root/Events"):
		Events.event_started.connect(_on_event_started)


func _process(_delta: float) -> void:
	## Verificar se SOLIDAO chegou a 100 para nascer companheiro.
	if not is_inside_tree():
		return
	if not has_node("/root/NeedsManager"):
		return
	var solidao: float = NeedsManager.get_value("SOLIDAO")
	var is_max: bool = solidao >= 100.0
	if is_max and not _solidao_was_max and state == State.ABSENT:
		try_birth()
	_solidao_was_max = is_max


## Nasce quando SOLIDAO >= 100.
func try_birth() -> void:
	if state != State.ABSENT:
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	companion_name = NAMES[rng.randi() % NAMES.size()]
	companion_object = OBJECTS[rng.randi() % OBJECTS.size()]
	state = State.ALIVE
	days_together = 0
	companion_born.emit(companion_name, companion_object)
	_save()


## Perde-se quando um evento de mare/tempestade o leva.
func lose() -> void:
	if state != State.ALIVE:
		return
	state = State.MOURNING
	companion_lost.emit()
	_save()


## Luto termina apos 1 dia de jogo.
func end_mourning() -> void:
	if state != State.MOURNING:
		return
	state = State.ABSENT
	companion_name = ""
	companion_object = ""
	companion_mourning_ended.emit()
	_save()


## Devolve true se o companheiro esta vivo.
func is_alive() -> bool:
	return state == State.ALIVE


## Devolve dicionario com contexto do companheiro para o LLMDirector.
func get_context() -> Dictionary:
	return {
		"name": companion_name,
		"object": companion_object,
		"state": State.keys()[state],
		"days_together": days_together,
	}


## Chamado quando companion_born e emitido: baixa SOLIDAO 40pts.
func _on_companion_born(_cname: String, _cobject: String) -> void:
	if is_inside_tree() and has_node("/root/NeedsManager"):
		NeedsManager.decrease("SOLIDAO", 40.0)


## Chamado quando companion_lost e emitido: sobe SOLIDAO 30pts e TEDIO 20pts.
func _on_companion_lost() -> void:
	if is_inside_tree() and has_node("/root/NeedsManager"):
		NeedsManager.increase("SOLIDAO", 30.0)
		NeedsManager.increase("TEDIO", 20.0)


## Intercepta eventos do EventDirector.
func _on_event_started(kind: String, _data: Dictionary) -> void:
	if kind == "tide_takes_companion":
		lose()


func _save() -> void:
	if not is_inside_tree():
		return
	if has_node("/root/SessionData"):
		SessionData.save()


func _try_load_from_session() -> void:
	pass  # expandir quando SessionData tiver campo companion

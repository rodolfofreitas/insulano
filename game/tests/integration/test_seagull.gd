extends GutTest
## Testes de integracao da gaivota (T-302).
##
## test_seagull_traverses: emite Events.event_started("seagull", {}),
##   avanca frames, confirma que a gaivota completou a travessia.
## test_fallback_phrase: com bridge sincrono (simula LLM fora),
##   o naufrago diz uma frase da categoria seagull.


class FakeBridge:
	extends Node

	signal phrase_ready(request_id: int, text: String, source: String)

	var call_count: int = 0
	var last_category: String = ""
	var last_request_id: int = -1
	var synchronous: bool = false
	var text_to_emit: String = "Frases de gaivota de teste."
	var _next_id: int = 1

	func request_phrase(_context: Object, fallback_category: String) -> int:
		call_count += 1
		last_category = fallback_category
		var rid := _next_id
		_next_id += 1
		last_request_id = rid
		if synchronous:
			phrase_ready.emit(rid, text_to_emit, "fallback")
		return rid


## Personagem falso simples com talking_text, compativel com SeagullEvent.
class FakeCharacter:
	extends Node
	var talking_text: String = ""


class FakeEventDirector:
	extends Node
	signal event_started(kind: String, data: Dictionary)
	signal event_finished(kind: String)


var _director: FakeEventDirector
var _seagull: SeagullEvent


func before_each() -> void:
	_director = autofree(FakeEventDirector.new())
	add_child(_director)
	_seagull = autofree(SeagullEvent.new())
	add_child(_seagull)
	# Ligar o sinal manualmente (sem autoload Events nos testes).
	_director.event_started.connect(_seagull._on_event_started)


func after_each() -> void:
	pass


## Confirma que a gaivota atravessa o ecra e fica inactiva ao sair.
func test_seagull_traverses() -> void:
	# Emite evento com duracao curta para o teste nao demorar.
	_director.event_started.emit("seagull", {"duration_s": 0.1})
	assert_true(_seagull.visible, "gaivota deve estar visivel apos event_started")
	assert_true(_seagull._active, "gaivota deve estar activa")

	# Avanca simulacao manual ate a duracao terminar.
	var frames := 0
	while _seagull._active and frames < 200:
		_seagull._process(0.05)
		frames += 1

	assert_false(_seagull._active, "gaivota deve ter terminado a travessia")
	assert_false(_seagull.visible, "gaivota deve ficar invisivel apos sair")


## Confirma que a gaivota pede frase com categoria "seagull".
func test_seagull_pede_frase_categoria_seagull() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	add_child(bridge)
	bridge.synchronous = true
	_seagull.bridge = bridge

	_director.event_started.emit("seagull", {"duration_s": 10.0})

	assert_eq(bridge.call_count, 1, "deve ter pedido uma frase")
	assert_eq(bridge.last_category, "seagull", "categoria do pedido deve ser 'seagull'")


## Confirma que a frase e entregue ao personagem quando o bridge responde.
func test_seagull_entrega_frase_ao_personagem() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	add_child(bridge)
	bridge.synchronous = true
	bridge.text_to_emit = "La vai a gaivota. Livre como eu nao sou."

	var fake_char: FakeCharacter = autofree(FakeCharacter.new())
	add_child(fake_char)
	_seagull.bridge = bridge
	_seagull.character = fake_char

	_director.event_started.emit("seagull", {"duration_s": 10.0})

	assert_eq(
		fake_char.talking_text,
		"La vai a gaivota. Livre como eu nao sou.",
		"personagem deve dizer a frase recebida do bridge"
	)


## Confirma que com bridge assincrono a frase chega quando o sinal e emitido.
func test_seagull_frase_assincrona() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	add_child(bridge)
	bridge.synchronous = false

	var fake_char: FakeCharacter = autofree(FakeCharacter.new())
	add_child(fake_char)
	_seagull.bridge = bridge
	_seagull.character = fake_char

	_director.event_started.emit("seagull", {"duration_s": 10.0})
	assert_eq(fake_char.talking_text, "", "ainda sem frase antes do sinal")

	bridge.phrase_ready.emit(
		bridge.last_request_id, "Boa viagem, gaivota. Manda um postal.", "fallback"
	)
	assert_eq(
		fake_char.talking_text,
		"Boa viagem, gaivota. Manda um postal.",
		"frase deve aparecer apos sinal phrase_ready"
	)


## Confirma que event_started repetido enquanto activo e ignorado.
func test_seagull_ignora_evento_duplicado() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	add_child(bridge)
	bridge.synchronous = true
	_seagull.bridge = bridge

	_director.event_started.emit("seagull", {"duration_s": 10.0})
	var pos_inicial: Vector2 = _seagull.position
	_director.event_started.emit("seagull", {"duration_s": 10.0})
	assert_eq(_seagull.position, pos_inicial, "segunda emissao nao deve reiniciar a posicao")
	assert_eq(bridge.call_count, 1, "segunda emissao nao deve pedir frase de novo")


## Confirma que com bridge sincrono (simula fallback LLM inacessivel)
## o personagem diz uma frase da categoria seagull.
func test_fallback_phrase() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	add_child(bridge)
	bridge.synchronous = true
	# Simula a resposta de fallback que o LLMBridge real daria com LLM fora.
	bridge.text_to_emit = "Tinha de ser uma gaivota. Nao um helicoptero."

	var fake_char: FakeCharacter = autofree(FakeCharacter.new())
	add_child(fake_char)
	_seagull.bridge = bridge
	_seagull.character = fake_char

	_director.event_started.emit("seagull", {"duration_s": 10.0})

	assert_ne(fake_char.talking_text, "", "personagem deve dizer algo mesmo com LLM inacessivel")
	assert_eq(bridge.last_category, "seagull", "fallback deve ser da categoria seagull")

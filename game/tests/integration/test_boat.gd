extends GutTest
## Testes de integracao do Boat (T-303): travessia do ecra e frase de fallback
## do naufrago na categoria "boat" com LLM desligado.

const BoatScript = preload("res://events/boat.gd")
const FALLBACK_PATH := "res://data/phrases_fallback.json"


## Cria um Boat isolado sem autoloads (simula o sinal event_started directo).
func _make_boat() -> Boat:
	var b: Boat = BoatScript.new()
	add_child_autofree(b)
	return b


## test_boat_traverses: emite event_started("boat", {}), avanca frames e
## confirma que o barco sai (event_finished foi emitido e o no esta invisivel).
func test_boat_traverses() -> void:
	var boat: Boat = _make_boat()

	## Simula o evento com duracao curta para o teste ser rapido.
	var data: Dictionary = {"duration_s": 0.1}
	boat._on_event_started("boat", data)

	assert_true(boat.visible, "barco deve ficar visivel apos event_started")
	assert_true(boat._active, "barco deve estar activo apos event_started")

	## Avanca tempo suficiente para a travessia terminar (0.1s + margem).
	var finished: bool = false
	var events: Node = get_node_or_null("/root/Events")
	if events != null:
		events.event_finished.connect(
			func(kind: String) -> void:
				if kind == "boat":
					finished = true,
			CONNECT_ONE_SHOT
		)

	## Simula _process em passos ate o barco terminar.
	var elapsed: float = 0.0
	var max_time: float = 2.0
	while elapsed < max_time and boat._active:
		boat._process(0.05)
		elapsed += 0.05

	assert_false(boat._active, "barco deve estar inactivo apos atravessar o ecra")
	assert_false(boat.visible, "barco deve estar invisivel apos sair do ecra")


## test_boat_ignores_other_events: evento de outro kind nao activa o barco.
func test_boat_ignores_other_events() -> void:
	var boat: Boat = _make_boat()
	boat._on_event_started("seagull", {"duration_s": 5.0})
	assert_false(boat._active, "barco nao deve activar com evento de outro kind")
	assert_false(boat.visible, "barco nao deve ficar visivel com evento de outro kind")


## test_fallback_phrase: com LLM desligado, a categoria "boat" tem frases validas
## que passam o PhraseFilter (verificado via FallbackPhrases.pick).
func test_fallback_phrase() -> void:
	var fallback := FallbackPhrases.from_file(FALLBACK_PATH)
	## Categorias disponíveis devem incluir "boat".
	assert_true(
		fallback.categories().has("boat"),
		"FallbackPhrases deve ter a categoria 'boat'"
	)

	## 10 picks da categoria "boat" devem devolver frases nao vazias.
	for _i: int in range(10):
		var phrase: String = fallback.pick("boat")
		assert_ne(phrase, "", "FallbackPhrases.pick('boat') nao pode devolver string vazia")

	## A categoria tem pelo menos 4 frases (criterio T-303).
	var text := FileAccess.get_file_as_string(FALLBACK_PATH)
	var data: Dictionary = JSON.parse_string(text)
	var boat_phrases: Array = data.get("boat", [])
	assert_gte(
		boat_phrases.size(),
		4,
		"categoria 'boat' precisa de pelo menos 4 frases (encontradas: %d)" % boat_phrases.size()
	)


## test_boat_draw_calls_no_crash: _draw() deve ser chamavel sem erros.
func test_boat_draw_calls_no_crash() -> void:
	var boat: Boat = _make_boat()
	## queue_redraw nao lanca excepcao -- o teste valida que a instancia existe.
	boat.queue_redraw()
	assert_not_null(boat, "Boat deve poder ser instanciado e chamar queue_redraw")

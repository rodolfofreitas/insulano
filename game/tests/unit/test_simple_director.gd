extends GutTest
## Testes unitarios do SimpleDirector: transicoes de arco por necessidades,
## seleccao de frases sem repeticao imediata e fallback para arco avulso.

const SimpleDirectorScript = preload("res://llm/simple_director.gd")


## NeedsManager simulado para testes sem autoload.
class FakeNeedsManager:
	extends Node

	var _values: Dictionary = {
		"SOLIDAO": 40.0,
		"TEDIO": 30.0,
		"ESPERANCA": 55.0,
	}

	func get_value(need_name: String) -> float:
		return _values.get(need_name, 0.0)

	func set_value(need_name: String, value: float) -> void:
		_values[need_name] = value


var director: Resource
var fake_nm: FakeNeedsManager


func _make_director() -> Resource:
	var d := SimpleDirectorScript.new()
	return d


func before_each() -> void:
	director = _make_director()
	fake_nm = FakeNeedsManager.new()
	director.needs_manager = fake_nm


func after_each() -> void:
	if fake_nm:
		fake_nm.free()


## Com SOLIDAO=75 (acima do threshold 70), o arco deve ser 'companheiro'.
func test_transitions_by_needs() -> void:
	fake_nm.set_value("SOLIDAO", 75.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var directive: DirectorDirective = director.get_directive()
	assert_eq(directive.arc_id, "companheiro", "SOLIDAO=75 deve activar arco companheiro")


## Com ESPERANCA<=25 (crise), o arco deve ser 'avulso' independentemente das outras necessidades.
func test_esperanca_crise_activa_avulso() -> void:
	fake_nm.set_value("SOLIDAO", 80.0)
	fake_nm.set_value("TEDIO", 70.0)
	fake_nm.set_value("ESPERANCA", 20.0)
	var directive: DirectorDirective = director.get_directive()
	assert_eq(
		directive.arc_id,
		"avulso",
		"ESPERANCA<=25 deve activar avulso mesmo com outras necessidades altas"
	)


## 10 picks consecutivos do mesmo arco nunca devem repetir a frase imediatamente anterior.
func test_no_immediate_repeat() -> void:
	fake_nm.set_value("SOLIDAO", 80.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var ultima_frase: String = ""
	for i: int in range(10):
		var directive: DirectorDirective = director.get_directive()
		assert_eq(directive.arc_id, "companheiro", "Arco deve manter-se companheiro")
		var frase: String = directive.phrase_context_extra.get("phrase", "")
		assert_ne(
			frase,
			ultima_frase,
			(
				"Frase %d nao deve repetir a anterior (ultima='%s', actual='%s')"
				% [i, ultima_frase, frase]
			)
		)
		ultima_frase = frase


## Sem NeedsManager urgente (valores neutros), o arco deve ser 'avulso'.
func test_fallback_to_avulso() -> void:
	fake_nm.set_value("SOLIDAO", 40.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var directive: DirectorDirective = director.get_directive()
	assert_eq(directive.arc_id, "avulso", "Valores neutros devem resultar em arco avulso")


## is_available() deve devolver true sempre.
func test_is_always_available() -> void:
	assert_true(director.is_available(), "SimpleDirector deve estar sempre disponivel")


## A directiva deve ter arc_id, activity e tone preenchidos.
func test_directive_fields_populated() -> void:
	var directive: DirectorDirective = director.get_directive()
	assert_ne(directive.arc_id, "", "arc_id nao pode estar vazio")
	assert_ne(directive.activity, "", "activity nao pode estar vazia")
	assert_ne(directive.tone, "", "tone nao pode estar vazio")


## Com o arco companheiro activo (T-114), chamadas sucessivas devem avancar de
## fase em fase, expondo o id da fase em phrase_context_extra.
func test_transita_fases_do_arco_companheiro() -> void:
	fake_nm.set_value("SOLIDAO", 80.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var fases_vistas: Array = []
	for i: int in range(4):
		var directive: DirectorDirective = director.get_directive()
		assert_eq(directive.arc_id, "companheiro")
		var fase_id: String = directive.phrase_context_extra.get("fase_id", "")
		assert_ne(fase_id, "", "fase_id deve estar preenchido para um arco com definicao")
		fases_vistas.append(fase_id)
	# As 4 fases do arco companheiro nao se devem repetir num ciclo completo.
	var unicas: Dictionary = {}
	for f: String in fases_vistas:
		unicas[f] = true
	assert_eq(unicas.size(), 4, "As 4 chamadas devem percorrer 4 fases distintas")


## O ciclo da Jangada aplica ESPERANCA +30 ao entrar na 1a fase da maquina de
## estados exposta pelo ArcManager, mesmo quando accionado via SimpleDirector.
func test_arc_manager_partilhado_aplica_efeitos_da_jangada() -> void:
	fake_nm.set_value("ESPERANCA", 55.0)
	fake_nm.set_value("SOLIDAO", 40.0)
	fake_nm.set_value("TEDIO", 65.0)
	# Forcar seleccao de jangada em vez de diario.
	director._last_tedio_arc = "diario"
	var directive: DirectorDirective = director.get_directive()
	assert_eq(directive.arc_id, "jangada", "TEDIO alto alternando deve seleccionar jangada")
	assert_eq(fake_nm.get_value("ESPERANCA"), 85.0, "ESPERANCA deve subir 30 na 1a fase da jangada")

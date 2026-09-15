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

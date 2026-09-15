extends GutTest
## Testes unitarios do SimpleDirector: transicoes de arco por necessidades,
## seleccao de frases sem repeticao imediata e fallback para arco avulso.

const SimpleDirectorScript = preload("res://llm/simple_director.gd")
const ArcManagerScript = preload("res://llm/arc_manager.gd")


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
	director.rng.seed = 1234  # determinismo na escolha de frase/actividade (AGENTS.md §6.6)


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
## estados exposta pelo ArcManager, mesmo quando accionado via SimpleDirector
## (nao usa um ArcManager partilhado -- essa cobertura esta no teste seguinte).
func test_jangada_aplica_esperanca_30_via_simple_director() -> void:
	fake_nm.set_value("ESPERANCA", 55.0)
	fake_nm.set_value("SOLIDAO", 40.0)
	fake_nm.set_value("TEDIO", 65.0)
	# Forcar seleccao de jangada em vez de diario.
	director._last_tedio_arc = "diario"
	var directive: DirectorDirective = director.get_directive()
	assert_eq(directive.arc_id, "jangada", "TEDIO alto alternando deve seleccionar jangada")
	assert_eq(fake_nm.get_value("ESPERANCA"), 85.0, "ESPERANCA deve subir 30 na 1a fase da jangada")


## A rotacao de TEDIO alto (T-114, 3a ronda) tem de incluir os 3 arcos --
## antes so alternava jangada/diario e ARC_SINALIZACAO ficava morto em codigo
## de producao (bloqueante do insulano-reviewer). Forcando _last_tedio_arc a
## "jangada" (posicao 0 de TEDIO_ROTATION), a proxima chamada tem de cair em
## "sinalizacao" (posicao 1).
func test_sinalizacao_e_seleccionada_na_rotacao_de_tedio() -> void:
	fake_nm.set_value("SOLIDAO", 20.0)
	fake_nm.set_value("TEDIO", 70.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	director._last_tedio_arc = "jangada"
	var directive: DirectorDirective = director.get_directive()
	assert_eq(
		directive.arc_id,
		"sinalizacao",
		"Apos jangada, a rotacao de TEDIO tem de cair em sinalizacao"
	)


## Chamadas sucessivas em rotacao pura (sem forcar) percorrem os 3 arcos por
## ordem fixa jangada -> sinalizacao -> diario -> jangada -> ... TEDIO
## reposto a 70 antes de cada chamada para isolar a rotacao em si do efeito
## TEDIO -30 da fase "construir" da propria jangada (arc_definitions.json):
## sem repor, a 2a vez que a jangada e escolhida baixa o TEDIO para 40 e a
## rotacao para de repetir por ter deixado de estar acima do limiar -- esse e
## um comportamento real e correcto do sistema (ver arc_smoke.gd), mas nao e
## o que este teste verifica.
func test_rotacao_de_tedio_percorre_os_3_arcos_por_ordem() -> void:
	fake_nm.set_value("SOLIDAO", 20.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	director._last_tedio_arc = "diario"  # a 1a chamada cai em jangada (posicao seguinte)
	var arcos: Array = []
	for i: int in range(6):
		fake_nm.set_value("TEDIO", 70.0)
		arcos.append(director.get_directive().arc_id)
	assert_eq(
		arcos,
		["jangada", "sinalizacao", "diario", "jangada", "sinalizacao", "diario"],
		"6 chamadas devem percorrer 2 ciclos completos da rotacao, por ordem fixa"
	)


## Com o arco sinalizacao activo (T-114, 3a ronda), chamadas sucessivas devem
## avancar de fase em fase (forcando a rotacao a manter-se em sinalizacao a
## cada chamada, para isolar so a progressao de fases do ArcManager).
func test_transita_fases_do_arco_sinalizacao() -> void:
	fake_nm.set_value("SOLIDAO", 20.0)
	fake_nm.set_value("TEDIO", 70.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var fases_vistas: Array = []
	for i: int in range(4):
		director._last_tedio_arc = "jangada"  # forca a proxima seleccao a ser sinalizacao
		var directive: DirectorDirective = director.get_directive()
		assert_eq(directive.arc_id, "sinalizacao")
		var fase_id: String = directive.phrase_context_extra.get("fase_id", "")
		assert_ne(fase_id, "", "fase_id deve estar preenchido para um arco com definicao")
		fases_vistas.append(fase_id)
	assert_eq(
		fases_vistas,
		["decide_fazer_fogo", "reune_madeira", "acende_fumo", "barco_passa_sem_parar"],
		"As 4 chamadas devem percorrer as 4 fases da Sinalizacao, por ordem"
	)


## Bloqueante do insulano-reviewer (3a ronda): is_activation_condition_met()
## devolve true quando o arco NAO existe no ArcManager (arc_manager.gd,
## "condicao vazia ou arco desconhecido = sempre activavel"). Sem a guarda
## has_arc() em _select_arc(), um arc_definitions.json em falta fazia o
## director devolver "companheiro" SEMPRE, mesmo com SOLIDAO=0. Este teste usa
## um ArcManager apontado a um caminho inexistente (_arcs fica {}) para provar
## que a guarda evita esse falso positivo.
func test_arc_definitions_em_falta_nao_activa_companheiro_em_silencio() -> void:
	director.arc_manager = ArcManagerScript.new("user://este_ficheiro_nao_existe.json")
	# ArcManagerScript.new() ja regista o push_error (ficheiro inexistente) ao
	# construir; consumir aqui, senao o GUT reprova o teste por "Unexpected
	# Errors" mesmo com as asserções abaixo a passar (mesmo padrão de
	# test_phrase_filter.gd:53-59).
	assert_push_error("Não foi possível abrir")
	fake_nm.set_value("SOLIDAO", 0.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)
	var directive: DirectorDirective = director.get_directive()
	assert_ne(
		directive.arc_id,
		"companheiro",
		"SOLIDAO=0 com arc_definitions.json em falta NAO pode activar companheiro"
	)
	assert_eq(
		directive.arc_id,
		"avulso",
		"sem arcos definidos e necessidades neutras, o arco cai em avulso"
	)


## Dois SimpleDirector com o MESMO ArcManager injectado (ArcManager.new(),
## RefCounted, docstring de arc_manager.gd: "pode ser partilhado entre eles
## para o indice de fase nao reiniciar a cada troca de director") tem de
## continuar a mesma progressao de fase, nao reiniciar do zero cada vez que
## um director diferente assume o arco.
func test_arc_manager_partilhado_entre_dois_directors_continua_a_fase() -> void:
	var arc_manager: ArcManager = ArcManagerScript.new()

	var director_a: Resource = _make_director()
	director_a.needs_manager = fake_nm
	director_a.arc_manager = arc_manager
	director_a.rng.seed = 1

	var director_b: Resource = _make_director()
	director_b.needs_manager = fake_nm
	director_b.arc_manager = arc_manager
	director_b.rng.seed = 2

	fake_nm.set_value("SOLIDAO", 80.0)
	fake_nm.set_value("TEDIO", 30.0)
	fake_nm.set_value("ESPERANCA", 55.0)

	var directive_a: DirectorDirective = director_a.get_directive()
	assert_eq(
		directive_a.phrase_context_extra.get("fase_id", ""),
		"encontra_objecto",
		"director_a arranca o ArcManager partilhado na 1a fase"
	)

	var directive_b: DirectorDirective = director_b.get_directive()
	assert_eq(
		directive_b.phrase_context_extra.get("fase_id", ""),
		"constroi_amizade",
		"director_b continua na 2a fase do MESMO ArcManager, nao reinicia na 1a"
	)
	assert_eq(
		arc_manager.phase_index("companheiro"),
		2,
		"o indice de fase no ArcManager partilhado reflecte as 2 chamadas, venham de qual director vierem"
	)

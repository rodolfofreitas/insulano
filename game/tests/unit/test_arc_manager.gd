extends GutTest
## Testes unitarios do ArcManager: fases dos 3 arcos base (T-114), transicao de
## fase, condicoes de activacao e reset ciclico com efeitos nas necessidades.

const ArcManagerScript = preload("res://llm/arc_manager.gd")

## Caminho de um JSON temporario usado so pelos testes de arco UNICO, para nao
## alterar os 3 arcos base entregues por esta tarefa (arc_definitions.json).
const UNICO_PATH: String = "user://test_arc_unico_tmp.json"


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


var arc_manager: RefCounted
var fake_nm: FakeNeedsManager


func before_each() -> void:
	arc_manager = ArcManagerScript.new()
	fake_nm = FakeNeedsManager.new()


func after_each() -> void:
	if fake_nm:
		fake_nm.free()


## Os 3 arcos base tem de existir com o numero de fases exigido pela tarefa.
func test_arcos_base_existem_com_fases_correctas() -> void:
	assert_true(arc_manager.has_arc("jangada"), "arco jangada tem de existir")
	assert_true(arc_manager.has_arc("companheiro"), "arco companheiro tem de existir")
	assert_true(arc_manager.has_arc("sinalizacao"), "arco sinalizacao tem de existir")
	assert_eq(arc_manager.arc_type("jangada"), "CICLICO", "jangada e ciclico")
	assert_eq(arc_manager.arc_type("companheiro"), "CICLICO", "companheiro e ciclico")
	assert_eq(arc_manager.arc_type("sinalizacao"), "CICLICO", "sinalizacao e ciclico")


## Arco jangada tem exactamente 5 fases (critério de aceitação).
func test_jangada_tem_5_fases() -> void:
	var fase: Dictionary = arc_manager.current_phase("jangada")
	assert_eq(fase.get("total", 0), 5, "A Jangada tem 5 fases")


## Arco companheiro tem exactamente 4 fases.
func test_companheiro_tem_4_fases() -> void:
	var fase: Dictionary = arc_manager.current_phase("companheiro")
	assert_eq(fase.get("total", 0), 4, "O Companheiro tem 4 fases")


## Arco sinalizacao tem exactamente 4 fases.
func test_sinalizacao_tem_4_fases() -> void:
	var fase: Dictionary = arc_manager.current_phase("sinalizacao")
	assert_eq(fase.get("total", 0), 4, "A Sinalizacao tem 4 fases")


## advance_phase avanca o indice de fase a cada chamada, sem saltar nem repetir.
func test_transicoes_de_fase_avancam_sequencialmente() -> void:
	var indices: Array = []
	for i in range(4):
		var fase: Dictionary = arc_manager.advance_phase("sinalizacao", fake_nm)
		indices.append(fase.get("index", -1))
	assert_eq(indices, [0, 1, 2, 3], "As fases devem avancar por ordem 0,1,2,3")


## Depois da ultima fase, um arco CICLICO volta a fase 0 (reset ciclico).
func test_reset_ciclico_depois_da_ultima_fase() -> void:
	for i in range(5):
		arc_manager.advance_phase("jangada", fake_nm)
	assert_eq(arc_manager.phase_index("jangada"), 0, "Apos 5 fases, jangada volta ao indice 0")
	var fase: Dictionary = arc_manager.current_phase("jangada")
	assert_eq(
		fase.get("id", ""), "encontra_madeira", "A fase 0 e sempre a mesma no reinicio do ciclo"
	)


## ESPERANCA sobe 30 ao entrar na primeira fase da Jangada (inicio do arco).
func test_jangada_esperanca_sobe_30_ao_iniciar() -> void:
	fake_nm.set_value("ESPERANCA", 55.0)
	arc_manager.advance_phase("jangada", fake_nm)
	assert_eq(fake_nm.get_value("ESPERANCA"), 85.0, "ESPERANCA deve subir 30 na fase inicial")


## TEDIO desce 30 na fase "construir" da Jangada (docs/narrative-design.md:47:
## "TEDIO -30 durante construcao").
func test_jangada_tedio_desce_30_ao_construir() -> void:
	fake_nm.set_value("TEDIO", 60.0)
	arc_manager.advance_phase("jangada", fake_nm)  # fase 0 (encontra_madeira)
	var fase: Dictionary = arc_manager.advance_phase("jangada", fake_nm)  # fase 1 (construir)
	assert_eq(fase.get("id", ""), "construir", "A 2a fase (indice 1) e a de construcao")
	assert_eq(fake_nm.get_value("TEDIO"), 30.0, "TEDIO deve descer 30 durante a construcao")


## ESPERANCA desce 40 na fase em que a jangada afunda (4a fase, indice 3).
func test_jangada_esperanca_desce_40_ao_afundar() -> void:
	fake_nm.set_value("ESPERANCA", 55.0)
	for i in range(3):
		arc_manager.advance_phase("jangada", fake_nm)
	# A proxima chamada executa a fase de indice 3 ("afunda").
	var esperanca_antes: float = fake_nm.get_value("ESPERANCA")
	var fase: Dictionary = arc_manager.advance_phase("jangada", fake_nm)
	assert_eq(fase.get("id", ""), "afunda", "A 4a fase (indice 3) e a que afunda")
	assert_eq(
		fake_nm.get_value("ESPERANCA"),
		esperanca_antes - 40.0,
		"ESPERANCA deve descer 40 ao afundar"
	)


## ESPERANCA desce 20 quando o barco da Sinalizacao passa sem parar (ultima fase).
func test_sinalizacao_esperanca_desce_20_quando_barco_nao_para() -> void:
	fake_nm.set_value("ESPERANCA", 55.0)
	for i in range(3):
		arc_manager.advance_phase("sinalizacao", fake_nm)
	var esperanca_antes: float = fake_nm.get_value("ESPERANCA")
	var fase: Dictionary = arc_manager.advance_phase("sinalizacao", fake_nm)
	assert_eq(fase.get("id", ""), "barco_passa_sem_parar", "A ultima fase e o barco que nao para")
	assert_eq(
		fake_nm.get_value("ESPERANCA"),
		esperanca_antes - 20.0,
		"ESPERANCA deve descer 20 quando o barco nao para"
	)


## O Companheiro so pode activar-se com SOLIDAO >= 70.
func test_companheiro_condicao_de_activacao_solidao_70() -> void:
	fake_nm.set_value("SOLIDAO", 40.0)
	assert_false(
		arc_manager.is_activation_condition_met("companheiro", fake_nm),
		"SOLIDAO=40 nao deve activar o companheiro"
	)
	fake_nm.set_value("SOLIDAO", 70.0)
	assert_true(
		arc_manager.is_activation_condition_met("companheiro", fake_nm),
		"SOLIDAO=70 deve activar o companheiro"
	)


## Arcos sem condicoes de activacao (jangada, sinalizacao) estao sempre disponiveis.
func test_arcos_sem_condicao_estao_sempre_activaveis() -> void:
	assert_true(arc_manager.is_activation_condition_met("jangada", fake_nm))
	assert_true(arc_manager.is_activation_condition_met("sinalizacao", fake_nm))


## reset_phase() volta explicitamente o indice de um arco para 0.
func test_reset_phase_explicito() -> void:
	arc_manager.advance_phase("companheiro", fake_nm)
	arc_manager.advance_phase("companheiro", fake_nm)
	assert_ne(arc_manager.phase_index("companheiro"), 0)
	arc_manager.reset_phase("companheiro")
	assert_eq(arc_manager.phase_index("companheiro"), 0, "reset_phase devolve o indice a 0")


## Arco desconhecido devolve fase vazia e nao rebenta.
func test_arco_desconhecido_devolve_fase_vazia() -> void:
	var fase: Dictionary = arc_manager.current_phase("arco_que_nao_existe")
	assert_true(fase.is_empty(), "arco inexistente devolve dicionario vazio")
	var avancada: Dictionary = arc_manager.advance_phase("arco_que_nao_existe", fake_nm)
	assert_true(avancada.is_empty(), "advance_phase de arco inexistente devolve dicionario vazio")


## Um arco UNICO (ex.: "O Naufragio", docs/narrative-design.md:57 -- ainda nao
## definido em arc_definitions.json, fora do ambito da T-114, que so entrega 3
## arcos CICLICO) nao pode reciclar como um CICLICO: tem de ficar parado na
## ultima fase e sinalizar fim via is_finished(), sem reaplicar os efeitos
## dessa fase em chamadas seguintes. Usa UNICO_PATH (JSON temporario) para nao
## alterar os 3 arcos base entregues por esta tarefa.
func _write_arco_unico_json() -> void:
	var data := {
		"arcs":
		{
			"teste_unico":
			{
				"tipo": "UNICO",
				"condicoes_activacao": {},
				"fases":
				[
					{"id": "inicio", "activities": ["X1"], "effects": {"ESPERANCA": 5}},
					{"id": "fim", "activities": ["X2"], "effects": {"ESPERANCA": -99}}
				]
			}
		}
	}
	var f := FileAccess.open(UNICO_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()


func _cleanup_unico_json() -> void:
	if FileAccess.file_exists(UNICO_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(UNICO_PATH))


## Um arco UNICO fica parado no indice da ultima fase depois de a processar,
## em vez de voltar ao indice 0 como um CICLICO.
func test_arco_unico_fica_na_ultima_fase_sem_reciclar() -> void:
	_write_arco_unico_json()
	var unico_manager: RefCounted = ArcManagerScript.new(UNICO_PATH)

	unico_manager.advance_phase("teste_unico", fake_nm)  # fase "inicio"
	var fase_final: Dictionary = unico_manager.advance_phase("teste_unico", fake_nm)  # fase "fim"
	assert_eq(fase_final.get("id", ""), "fim", "2a chamada processa a ultima fase")
	assert_eq(
		unico_manager.phase_index("teste_unico"),
		1,
		"UNICO fica parado no indice da ultima fase (1), nao recicla para 0"
	)
	_cleanup_unico_json()


## is_finished() so fica true depois de um arco UNICO processar a ultima fase,
## e chamadas seguintes de advance_phase nao reaplicam os efeitos dela.
func test_arco_unico_is_finished_e_nao_reaplica_efeitos() -> void:
	_write_arco_unico_json()
	var unico_manager: RefCounted = ArcManagerScript.new(UNICO_PATH)

	assert_false(
		unico_manager.is_finished("teste_unico"), "arco ainda nao comecou, nao pode estar terminado"
	)
	unico_manager.advance_phase("teste_unico", fake_nm)  # fase "inicio", ESPERANCA +5
	assert_false(
		unico_manager.is_finished("teste_unico"), "so entrou na 1a fase, ainda nao terminou"
	)

	fake_nm.set_value("ESPERANCA", 50.0)
	unico_manager.advance_phase("teste_unico", fake_nm)  # fase "fim", ESPERANCA -99
	assert_true(
		unico_manager.is_finished("teste_unico"), "processou a ultima fase, tem de terminar"
	)
	assert_eq(
		fake_nm.get_value("ESPERANCA"), -49.0, "efeito da ultima fase aplicado exactamente uma vez"
	)

	# Chamadas seguintes nao fazem nada: nem avancam, nem reaplicam efeitos.
	var resultado: Dictionary = unico_manager.advance_phase("teste_unico", fake_nm)
	assert_true(resultado.is_empty(), "arco terminado devolve {} em vez de repetir a ultima fase")
	assert_eq(
		fake_nm.get_value("ESPERANCA"),
		-49.0,
		"efeito da ultima fase NAO pode ser reaplicado depois de terminado"
	)
	_cleanup_unico_json()


## reset_phase() tambem limpa is_finished(), permitindo retomar um arco UNICO
## do inicio (ex.: um novo "Naufragio" gerado mais tarde pela IA, T-115+).
func test_arco_unico_reset_phase_limpa_is_finished() -> void:
	_write_arco_unico_json()
	var unico_manager: RefCounted = ArcManagerScript.new(UNICO_PATH)

	unico_manager.advance_phase("teste_unico", fake_nm)
	unico_manager.advance_phase("teste_unico", fake_nm)
	assert_true(unico_manager.is_finished("teste_unico"))

	unico_manager.reset_phase("teste_unico")
	assert_false(unico_manager.is_finished("teste_unico"), "reset_phase limpa is_finished")
	assert_eq(unico_manager.phase_index("teste_unico"), 0, "reset_phase volta ao indice 0")
	_cleanup_unico_json()


## CICLICO nunca fica "terminado": is_finished() e sempre false, mesmo depois
## de varios ciclos completos (contraste directo com o comportamento UNICO).
func test_arco_ciclico_nunca_fica_terminado() -> void:
	for i in range(20):
		arc_manager.advance_phase("jangada", fake_nm)
	assert_false(
		arc_manager.is_finished("jangada"),
		"arco CICLICO nunca fica terminado, mesmo apos varios ciclos"
	)

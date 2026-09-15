extends GutTest
## Testes de geracao de arcos originais pelo LLM (T-117): validacao de schema,
## deteccao de titulo repetido, fallback em falha de validacao.
## Sem cena, sem rede: as dependencias sao injectadas com doubles ou stubs.

const ArcHistoryScript = preload("res://world/arc_history.gd")

var director: LLMDirector
var arc_history: Node


func before_each() -> void:
	director = LLMDirector.new()
	arc_history = ArcHistoryScript.new()
	arc_history.completed_arcs = []
	arc_history.active_arc = {}
	director.arc_history = arc_history


func after_each() -> void:
	if director:
		director.free()
	if arc_history:
		arc_history.free()


## _validate_arc com schema correcto (titulo, fases >= 2 com nome e actividade)
## deve devolver true.
func test_validate_arc_valid() -> void:
	var data := {
		"titulo": "O Festival das Conchas",
		"tipo": "absurdo",
		"fases":
		[
			{"nome": "Preparacao", "actividade": "recolher_conchas", "duracao_ciclos": 2},
			{"nome": "Cerimonia", "actividade": "discurso_para_conchas", "duracao_ciclos": 1},
		],
		"necessidade_que_sobe": "TEDIO",
	}
	assert_true(director._validate_arc(data), "arco valido deve passar a validacao")


## _validate_arc sem campo titulo deve devolver false.
func test_validate_arc_no_title() -> void:
	var data := {
		"tipo": "absurdo",
		"fases":
		[
			{"nome": "Fase 1", "actividade": "passear", "duracao_ciclos": 1},
			{"nome": "Fase 2", "actividade": "pescar", "duracao_ciclos": 2},
		],
		"necessidade_que_sobe": "FOME",
	}
	assert_false(director._validate_arc(data), "arco sem titulo deve falhar a validacao")


## _validate_arc com titulo identico a arco ja completado (case-insensitive)
## deve devolver false.
func test_validate_arc_repeated_title() -> void:
	arc_history.completed_arcs = [
		{"titulo": "A Jangada", "id": "arc_jangada_1"},
	]
	var data := {
		"titulo": "a jangada",
		"tipo": "sobrevivencia",
		"fases":
		[
			{"nome": "Construcao", "actividade": "construir_jangada", "duracao_ciclos": 3},
			{"nome": "Lancamento", "actividade": "lancar_jangada", "duracao_ciclos": 1},
		],
		"necessidade_que_sobe": "ESPERANCA",
	}
	assert_false(
		director._validate_arc(data), "titulo repetido (case-insensitive) deve falhar a validacao"
	)


## _validate_arc com fases array vazio deve devolver false.
func test_validate_arc_no_phases() -> void:
	var data := {
		"titulo": "Arco Sem Fases",
		"tipo": "avulso",
		"fases": [],
		"necessidade_que_sobe": "TEDIO",
	}
	assert_false(director._validate_arc(data), "arco sem fases deve falhar a validacao")


## _validate_arc com apenas uma fase deve devolver false (minimo 2 exigido).
func test_validate_arc_single_phase() -> void:
	var data := {
		"titulo": "Arco Uma Fase",
		"tipo": "avulso",
		"fases": [{"nome": "Unica", "actividade": "descansar", "duracao_ciclos": 1}],
		"necessidade_que_sobe": "TEDIO",
	}
	assert_false(director._validate_arc(data), "arco com uma so fase deve falhar (minimo 2)")


## _validate_arc com fase sem campo actividade deve devolver false.
func test_validate_arc_phase_missing_actividade() -> void:
	var data := {
		"titulo": "Arco Fase Incompleta",
		"tipo": "avulso",
		"fases":
		[
			{"nome": "Fase 1", "actividade": "pescar", "duracao_ciclos": 1},
			{"nome": "Fase 2", "duracao_ciclos": 2},
		],
		"necessidade_que_sobe": "FOME",
	}
	assert_false(director._validate_arc(data), "fase sem actividade deve fazer falhar a validacao")


## Quando o LLM devolve JSON invalido (_on_arc_gen_ready com raw invalido),
## _validate_arc deve falhar e o fallback deve ser chamado (T-117 criterio 4).
## Este teste verifica que parse_directive devolve {} para texto invalido e
## que _validate_arc({}) devolve false.
func test_fallback_on_failure() -> void:
	var raw_invalido := "isto nao e JSON valido !!!"
	var data := LLMDirector.parse_directive(raw_invalido)
	# JSON.parse_string falha e regista um erro de motor -- consumi-lo (mesmo
	# padrao de test_llm_director.gd:78).
	assert_engine_error("error != Error::OK")
	assert_true(data.is_empty(), "parse de texto invalido deve devolver dicionario vazio")
	assert_false(director._validate_arc(data), "dicionario vazio deve falhar a validacao do arco")

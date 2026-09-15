extends SceneTree
## Smoke reprodutivel do ArcManager/SimpleDirector (T-114): prova em log que os
## 3 arcos base avancam de fase em fase e reiniciam em ciclo, sem depender do
## jogo estar ligado ao EventDirector (ainda nao esta -- ver Relatorio da
## T-114 em backlog/fase-3/T-114-arcos-base.md).
##
## Determinístico: needs_manager fixo por secção e SimpleDirector.rng com seed
## fixa, por isso duas corridas produzem exactamente o mesmo log (AGENTS.md
## §6.6).
##
## Uso (a partir da raiz do repositório):
##   godot --headless --path game -s res://tools/arc_smoke.gd
##
## 3 secções, uma por arco base:
## 1) "companheiro" (SOLIDAO alto, condição de activação própria): 10 ciclos
##    naturais, mostra o ciclo de 4 fases a repetir-se 2 vezes e meia.
## 2) "jangada" (rotação de TEDIO alto): 5 ciclos, forçando _last_tedio_arc
##    para isolar SÓ a progressão de fase da jangada (ver nota na secção),
##    mostra ESPERANCA a subir 30 na 1a fase e a descer 40 na fase "afunda".
## 3) "sinalizacao" (rotação de TEDIO alto, T-114 3a ronda -- antes desta
##    correcção este arco nunca era seleccionado em código de produção): 4
##    ciclos, mesma técnica de isolamento, mostra as 4 fases completas.
## Sai sempre com código 0 (só imprime, não falha o verify.sh; a prova é ler o
## log gerado, ex.: docs/proof/T-114-arco.log).

## SOLIDAO fixo acima do limiar de activação do arco "companheiro" (>= 70,
## arc_definitions.json). ESPERANCA neutra.
const NEEDS_COMPANHEIRO: Dictionary = {"SOLIDAO": 80.0, "TEDIO": 30.0, "ESPERANCA": 55.0}

## SOLIDAO baixo (para NAO disparar "companheiro", que tem prioridade sobre
## TEDIO em SimpleDirector._select_arc). TEDIO alto o suficiente para
## continuar >= 65 (limiar de "jangada"/"sinalizacao", THRESHOLD_TEDIO) mesmo
## depois do efeito TEDIO -30 da fase "construir" da propria jangada
## (arc_definitions.json): sem esta folga o arco cai para "avulso" a meio do
## ciclo e nunca chega as fases seguintes -- comportamento real e correcto do
## sistema, mas que esconderia fases deste smoke.
const NEEDS_TEDIO_ALTO: Dictionary = {"SOLIDAO": 20.0, "TEDIO": 95.0, "ESPERANCA": 55.0}

const CICLOS_COMPANHEIRO: int = 10
const CICLOS_JANGADA: int = 5
const CICLOS_SINALIZACAO: int = 4

## RNG do SimpleDirector: seed fixa para o log ser sempre o mesmo.
const RNG_SEED: int = 20260915

const SimpleDirectorScript = preload("res://llm/simple_director.gd")


class FakeNeeds:
	extends Node

	var _values: Dictionary = {}

	func get_value(n: String) -> float:
		return _values.get(n, 0.0)

	func set_value(n: String, v: float) -> void:
		_values[n] = v


## Corre "ciclos" chamadas de get_directive() num director cuja rotação de
## TEDIO alto é forçada, antes de CADA chamada, a cair sempre no mesmo arco
## (definindo _last_tedio_arc para a posição imediatamente anterior dele em
## SimpleDirector.TEDIO_ROTATION). Isto isola a progressão de fase desse arco
## específico da rotação com os outros 2 (T-114, 3a ronda: jangada e
## sinalização partilham o mesmo gatilho TEDIO alto, ver simple_director.gd).
func _run_isolated_tedio_arc(forcar_para: String, ciclos: int) -> void:
	var director = SimpleDirectorScript.new()
	var needs := FakeNeeds.new()
	needs._values = NEEDS_TEDIO_ALTO.duplicate()
	director.needs_manager = needs
	director.rng.seed = RNG_SEED
	for i in range(ciclos):
		director._last_tedio_arc = forcar_para
		var esperanca_antes: float = needs.get_value("ESPERANCA")
		var directive = director.get_directive()
		print(
			(
				"ciclo %02d: arc=%s fase=%s(%s) activity=%s ESPERANCA %.1f -> %.1f"
				% [
					i,
					directive.arc_id,
					directive.phrase_context_extra.get("fase_id", "-"),
					directive.phrase_context_extra.get("fase_index", -1),
					directive.activity,
					esperanca_antes,
					needs.get_value("ESPERANCA")
				]
			)
		)


func _initialize() -> void:
	print("=== T-114 ARC SMOKE: arco 'companheiro' (SOLIDAO=80, activa por condicao) ===")
	var director_companheiro = SimpleDirectorScript.new()
	var needs_companheiro := FakeNeeds.new()
	needs_companheiro._values = NEEDS_COMPANHEIRO.duplicate()
	director_companheiro.needs_manager = needs_companheiro
	director_companheiro.rng.seed = RNG_SEED
	for i in range(CICLOS_COMPANHEIRO):
		var directive = director_companheiro.get_directive()
		print(
			(
				"ciclo %02d: arc=%s fase=%s(%s) activity=%s"
				% [
					i,
					directive.arc_id,
					directive.phrase_context_extra.get("fase_id", "-"),
					directive.phrase_context_extra.get("fase_index", -1),
					directive.activity
				]
			)
		)

	print("=== T-114 ARC SMOKE: arco 'jangada' (rotacao de TEDIO alto, isolada) ===")
	_run_isolated_tedio_arc("diario", CICLOS_JANGADA)  # diario -> proxima e' jangada

	print("=== T-114 ARC SMOKE: arco 'sinalizacao' (rotacao de TEDIO alto, isolada) ===")
	_run_isolated_tedio_arc("jangada", CICLOS_SINALIZACAO)  # jangada -> proxima e' sinalizacao

	print("=== fim ===")
	quit(0)

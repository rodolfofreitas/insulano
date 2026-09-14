@tool
class_name SayGeneratedAction
extends ActionLeaf
## Pede uma frase ao LLMBridge (ou fallback) e di-la em `character.talking_text` (tech_design §4.6).
##
## Substitui o `TalkAction` fixo em inglês herdado da base: cada nó desta
## classe na árvore usa `fallback_category` para escolher a família de
## frases de recurso (game/data/phrases_fallback.json) quando o Ollama não
## responde. O contexto da frase (`PhraseContext`) vem de `current_action` no
## blackboard (escrito pelas acções de pesca, comer, observar o oceano e
## passear, ver fishing_action.gd, use_usable_action.gd, watch_ocean_action.gd
## e go_to_usable_action.gd), da necessidade de fome do `Character` e, quando
## os autoloads `Clock`/`Weather` existirem (T-201/T-304, ainda planeados),
## da hora e do tempo reais; até lá usa a hora do sistema e valores neutros
## ("sol", "nenhuma").
##
## Primeiro tick pede a frase e devolve `RUNNING`; quando o sinal
## `phrase_ready` chega com o `request_id` deste pedido, escreve o texto e
## devolve `SUCCESS`. Trata à parte o caso em que o `LLMBridge` responde
## SINCRONAMENTE, dentro da própria chamada a `request_phrase` (ponte
## desligada, pedido concorrente ou prompt vazio, ver llm_bridge.gd):
## liga-se o sinal ANTES de chamar `request_phrase`, por isso uma resposta
## síncrona já fica registada em `_has_result` quando a chamada devolve, e o
## mesmo tick resolve directamente em `SUCCESS` sem passar por `RUNNING`.
##
## Não decide SE deve falar (isso é a posição deste nó na árvore); só decide
## COM QUE FREQUÊNCIA fala, através de `LLMSettings.min_interval_s`, contado
## a partir de `say_last_at_s` no blackboard e partilhado por TODAS as
## instâncias desta classe na mesma árvore (para não haver dois nós a falar
## em sequência só porque cada um tinha o seu próprio relógio).
##
## Quando o intervalo mínimo bloqueia a fala, esta classe NUNCA toca em
## `character.talking_text`, nem para o limpar: só quem escreveu a frase
## decide quando ela desaparece, e desde a T-107 isso é o `SpeechBubble`
## (`game/ui/speech_bubble.gd`), não este nó (ver `tech_design.md` §4.6, "quem
## manda na duração"). Até à T-106 esta classe limpava o balão aqui mesmo
## depois de `MIN_VISIBLE_S` segundos, um padrão "fala antes, limpa depois"
## copiado do `TalkAction` da base; ficou a dois donos da mesma duração
## quando o `SpeechBubble` passou a ter a sua própria, e um ramo bloqueado
## podia apagar uma frase que o balão ainda estava a contar como visível.
##
## O `SpeechBubble` substitui o texto sem condição em `show_text()` (nunca
## espera que a frase anterior tenha ficado visível o suficiente); por isso a
## garantia de "nenhuma frase visível menos de 3 s" só se mantém verdadeira se
## `tick()` também garantir que só pede uma frase nova pelo menos
## `MIN_VISIBLE_S` depois da anterior, mesmo que `LLMSettings.min_interval_s`
## venha configurado (via `user://settings.cfg`, sem limite nenhum) com um
## valor menor do que isso, incluindo 0. É por isso que `tick()` usa
## `maxf(min_interval_s, MIN_VISIBLE_S)` como intervalo EFECTIVO, em vez de
## `min_interval_s` directamente: o intervalo efectivo nunca é inferior a
## `MIN_VISIBLE_S`, para qualquer `min_interval_s` configurado, e por isso a
## garantia vale sempre, não só quando alguém configura `min_interval_s` com
## bom senso (bloqueante da revisão da T-107, ronda 1, com prova por mutação
## no Relatório).

## Antigo limite inferior do clamp de duração desta classe, antes da T-107
## mover a duração visível do balão para `SpeechBubble`. Continua a ser lido
## por `tick()`, agora com outro papel: é o piso do intervalo EFECTIVO entre
## dois pedidos de frase (`maxf(min_interval_s, MIN_VISIBLE_S)`), para
## `LLMSettings.min_interval_s` nunca conseguir fazer `tick()` pedir uma frase
## nova antes de a anterior ter tido tempo de ficar visível o suficiente no
## `SpeechBubble`. Tem de continuar igual a `SpeechBubble.MIN_SECONDS`
## (testado em `test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s`,
## `test_speech_bubble.gd`), senão a garantia de "nenhuma frase visível menos
## de 3 s" divide-se em dois números que podem divergir sem ninguém notar.
const MIN_VISIBLE_S: float = 3.0

## Categoria de FallbackPhrases a usar quando a resposta cai em fallback
## (ex.: "fishing", "eating", "idle"; ver game/data/phrases_fallback.json).
@export var fallback_category: String = "idle"
## Nome da necessidade que alimenta o campo "hunger" do PhraseContext; a
## única que a base tem hoje é "hunger".
@export var hunger_need_name: String = "hunger"

## Ponte a usar; em testes injecta-se uma falsa, em jogo fica o autoload
## (code_patterns.md §5).
var bridge: Node = null
## Definições injectadas pelos testes (para fixar min_interval_s); em jogo
## carregam-se de LLMSettings na primeira utilização.
var settings: LLMSettings = null
## Relógio a usar para medir min_interval_s e MIN_VISIBLE_S. Em testes
## injecta-se um `Callable` sem argumentos que devolve segundos controlados
## (code_patterns.md §5, adaptado de nó para relógio); em jogo fica inválido
## (`Callable()`) e usa-se `Time.get_ticks_msec()` por defeito, porque o
## `Time` do Godot não é substituível directamente num teste.
var clock: Callable = Callable()

## request_id do pedido desta instância em curso, ou -1 se nenhum.
var _awaiting_request_id: int = -1
## Verdadeiro quando _on_phrase_ready já recebeu uma resposta ainda não
## consumida (pode ter chegado sincronamente, ver docstring da classe).
var _has_result: bool = false
## request_id associado a _result_text, só válido quando _has_result.
var _result_request_id: int = -1
## Texto recebido do último phrase_ready ainda não consumido.
var _result_text: String = ""


## Decide se fala (intervalo EFECTIVO desde a última frase de qualquer
## instância desta classe, guardado no blackboard: `maxf(min_interval_s,
## MIN_VISIBLE_S)`, nunca `min_interval_s` sozinho, ver docstring da classe) e,
## sendo esse o caso, pede a frase à ponte; devolve RUNNING até chegar o sinal
## do request_id deste pedido, e SUCCESS logo no mesmo tick se a resposta já
## tiver chegado (síncrona ou já pendente). Quando o intervalo efectivo ainda
## não passou, devolve SUCCESS sem tocar em `character.talking_text` (nem
## para falar, nem para o limpar: ver docstring da classe, quem manda no
## desaparecimento é o `SpeechBubble`). FAILURE se não há nenhuma ponte
## disponível (nem injectada, nem o autoload LLM).
func tick(actor: Node, blackboard: Blackboard) -> int:
	var character := actor as Character
	if character == null:
		return FAILURE

	if _awaiting_request_id != -1:
		return _resolve_awaiting(character, blackboard)

	var now_s := _now_s()
	var last_said_at: float = blackboard.get_value("say_last_at_s", -INF)
	var effective_interval_s: float = maxf(_get_settings().min_interval_s, MIN_VISIBLE_S)
	if now_s - last_said_at < effective_interval_s:
		return SUCCESS

	var current_bridge := _get_bridge()
	if current_bridge == null:
		push_error("[Insulano/Say] autoload LLM em falta e nenhuma ponte injectada")
		return FAILURE

	return _start_request(character, blackboard, current_bridge)


## Consome o resultado do pedido que já estava em curso, se já tiver chegado
## para o request_id certo; senão continua RUNNING.
func _resolve_awaiting(character: Character, blackboard: Blackboard) -> int:
	if _has_result and _result_request_id == _awaiting_request_id:
		_speak(character, blackboard, _result_text)
		_awaiting_request_id = -1
		_has_result = false
		return SUCCESS
	return RUNNING


## Liga o sinal (se ainda não estiver ligado), pede a frase e resolve já se a
## resposta chegou sincronamente dentro da própria chamada a request_phrase
## (a armadilha documentada na docstring da classe); senão fica à espera.
func _start_request(character: Character, blackboard: Blackboard, current_bridge: Node) -> int:
	_has_result = false
	if not current_bridge.phrase_ready.is_connected(_on_phrase_ready):
		current_bridge.phrase_ready.connect(_on_phrase_ready)

	var context := _build_context(character, blackboard)
	var request_id: int = current_bridge.request_phrase(context, fallback_category)

	if _has_result and _result_request_id == request_id:
		_speak(character, blackboard, _result_text)
		_has_result = false
		return SUCCESS

	_awaiting_request_id = request_id
	return RUNNING


## Escreve o texto recebido no balão do personagem e regista o momento no
## blackboard, para o min_interval_s valer entre QUALQUER par de frases desta
## árvore, não só entre chamadas do mesmo nó.
func _speak(character: Character, blackboard: Blackboard, text: String) -> void:
	character.talking_text = text
	blackboard.set_value("say_last_at_s", _now_s())


## Recetor de LLMBridge.phrase_ready: só guarda o resultado, nunca decide
## nada (a decisão é toda em tick(), síncrona ou no tick seguinte).
func _on_phrase_ready(request_id: int, text: String, _source: String) -> void:
	_has_result = true
	_result_request_id = request_id
	_result_text = text


## Chamado pela árvore quando este nó estava RUNNING (à espera de
## phrase_ready) e um ramo de prioridade mais alta o interrompe antes de
## chegar a FAILURE/SUCCESS. Esquece o pedido em curso: sem isto, se a MESMA
## instância for percorrida de novo mais tarde (os nós da árvore são
## reutilizados, nunca recriados), `tick()` via `_resolve_awaiting()`
## resolveria com o `_awaiting_request_id` antigo em vez de pedir uma frase
## nova, e uma resposta tardia desse pedido interrompido (código de fallback
## do LLMBridge inclusive) apareceria a falar sobre um contexto que já não é
## o actual.
##
## NÃO chama `super.interrupt()` de propósito: o `BeehaveNode.interrupt()` da
## base só notifica o debugger visual do Beehave
## (`BeehaveDebuggerMessages.process_interrupt`), e essa chamada aborta com
## `Can't send message. No active debugger` sempre que corre fora do editor
## com o debugger ligado (headless, incluindo os testes GUT deste ficheiro,
## AGENTS.md §10: ruído conhecido). Chamar `super` aqui faria o GUT marcar
## `test_interrupt_esquece_o_pedido_em_curso` como falhado por "Unexpected
## Errors", por um problema do addon Beehave em headless, não desta classe.
## Perde-se só a notificação ao debugger visual (uma ajuda de depuração
## opcional em jogo dentro do editor); o comportamento da árvore não depende
## dela.
func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	_awaiting_request_id = -1
	_has_result = false


## Ponte a usar: a injectada pelos testes, senão o autoload LLM.
func _get_bridge() -> Node:
	return bridge if bridge != null else get_node_or_null("/root/LLM")


## Definições a usar (só para ler min_interval_s); carregadas uma vez.
func _get_settings() -> LLMSettings:
	if settings == null:
		settings = LLMSettings.load_settings()
	return settings


## Segundos a usar para medir min_interval_s: o `clock` injectado, se válido
## (testes), senão `Time.get_ticks_msec()` (jogo real).
func _now_s() -> float:
	if clock.is_valid():
		return clock.call()
	return Time.get_ticks_msec() / 1000.0


## Monta o PhraseContext a partir do blackboard, da fome do personagem e de
## valores neutros para hora/tempo/feriado enquanto Clock/Weather/
## HolidayCalendar não existirem (T-201/T-304/T-401).
func _build_context(character: Character, blackboard: Blackboard) -> PhraseContext:
	var context := PhraseContext.new()
	var hour := _current_hour()
	context.hour = hour
	context.period = _period_for_hour(hour)
	context.action = String(blackboard.get_value("current_action", "estar na ilha"))

	var need := character.get_need(hunger_need_name)
	if need != null:
		context.hunger_label = PromptBuilder.hunger_label_for(need.get_percentage())
	else:
		context.hunger_label = "satisfeito"

	# Sem WeatherService (T-304) nem HolidayCalendar (T-401) ainda: valores
	# neutros que o PromptBuilder aceita (nenhum campo de texto em branco).
	context.weather = "sol"
	context.holiday = "nenhuma"
	return context


## Hora do dia (0-23). Sem GameClock (T-201) ainda: hora real do sistema.
func _current_hour() -> int:
	return int(Time.get_time_dict_from_system()["hour"])


## Período em pt-PT para `hour`, com as mesmas fronteiras usadas em
## evals/phrase_cases.json (8h/10h/11h manhã, 13h/15h tarde, 17h fim da
## tarde, 20h/23h noite): madrugada 0-5, manhã 6-11, tarde 12-16,
## fim da tarde 17-19, noite 20-23.
func _period_for_hour(hour: int) -> String:
	if hour < 6:
		return "madrugada"
	if hour < 12:
		return "manhã"
	if hour < 17:
		return "tarde"
	if hour < 20:
		return "fim da tarde"
	return "noite"

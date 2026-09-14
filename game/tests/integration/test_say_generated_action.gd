extends GutTest
## Testes de integração de [SayGeneratedAction] (T-106, tech_design.md §4.6):
## RUNNING até o sinal phrase_ready chegar, SUCCESS depois (incluindo quando a
## ponte responde SINCRONAMENTE dentro da própria chamada a request_phrase,
## a armadilha documentada em llm_bridge.gd e na docstring da classe); o
## respeito por min_interval_s partilhado entre instâncias via blackboard,
## incluindo o BLOQUEIO de uma 2ª instância pela 1ª; a rejeição de
## phrase_ready com o request_id de outro pedido; o esquecimento do pedido em
## curso ao interromper (interrupt()); e, desde a T-107, a garantia de que um
## ramo bloqueado pelo intervalo mínimo NUNCA toca em `character.talking_text`
## (nem para falar, nem para o limpar): quem manda no desaparecimento do
## balão passou a ser o `SpeechBubble` (game/ui/speech_bubble.gd), não esta
## classe (ver o Relatório da T-107 em backlog/fase-1/T-107-speech-bubble.md).


## Ponte falsa injectável (code_patterns.md §5): imita o contrato de
## LLMBridge.request_phrase() sem tocar em rede, com controlo total sobre SE
## e QUANDO phrase_ready é emitido, para reproduzir os dois caminhos reais da
## ponte real (síncrono e assíncrono).
class FakeBridge:
	extends Node
	signal phrase_ready(request_id: int, text: String, source: String)

	## Se verdadeiro, request_phrase() emite phrase_ready ANTES de devolver o
	## request_id, tal como o LLMBridge real faz nos caminhos de fallback
	## imediato (ponte desligada, pedido concorrente, prompt vazio).
	var synchronous: bool = false
	## Texto a emitir quando synchronous (ou via emit_now()).
	var text_to_emit: String = "frase de teste sincrona"
	## Quantas vezes request_phrase() foi chamado, para provar que o
	## min_interval_s impediu (ou não) uma nova chamada.
	var call_count: int = 0
	## request_id devolvido pela última chamada a request_phrase(), para os
	## testes emitirem manualmente o sinal correspondente.
	var last_request_id: int = -1

	var _next_id: int = 1

	## Atribui um request_id novo e, se synchronous, emite phrase_ready já
	## dentro desta chamada (a armadilha que a SayGeneratedAction tem de
	## tratar).
	func request_phrase(_context: PhraseContext, _fallback_category: String) -> int:
		call_count += 1
		var request_id := _next_id
		_next_id += 1
		last_request_id = request_id
		if synchronous:
			phrase_ready.emit(request_id, text_to_emit, "fallback")
		return request_id

	## Emite phrase_ready para o request_id dado, simulando a resposta
	## assíncrona que chegaria mais tarde de um Ollama real.
	func emit_now(request_id: int, text: String, source: String = "fallback") -> void:
		phrase_ready.emit(request_id, text, source)


## Relógio falso injectável via `SayGeneratedAction.clock` (Callable):
## `now_s` avança-se manualmente no teste, em vez de depender do tempo real
## que passa a correr o próprio teste (ronda 3, correcção do bloqueante 2).
class FakeClock:
	var now_s: float = 0.0

	func get_now() -> float:
		return now_s


var _character: Character
var _blackboard: Blackboard


func before_each() -> void:
	_character = Character.new()
	_character.needs = []
	add_child_autofree(_character)

	_blackboard = Blackboard.new()
	add_child_autofree(_blackboard)


## Constrói a acção com uma FakeBridge e min_interval_s = 0 (não interfere
## nos testes que não são sobre o intervalo mínimo).
func _make_action(bridge: FakeBridge) -> SayGeneratedAction:
	var action: SayGeneratedAction = autofree(SayGeneratedAction.new())
	action.bridge = bridge
	action.settings = LLMSettings.new()
	action.settings.min_interval_s = 0.0
	action.fallback_category = "idle"
	return action


func test_devolve_running_ate_sinal_chegar_e_success_depois() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	var action := _make_action(bridge)

	var first := action.tick(_character, _blackboard)
	assert_eq(first, action.RUNNING, "sem resposta ainda, o 1º tick tem de ficar RUNNING")
	assert_eq(_character.talking_text, "", "ainda não falou")

	bridge.emit_now(bridge.last_request_id, "Frase chegada mais tarde")

	var second := action.tick(_character, _blackboard)
	assert_eq(second, action.SUCCESS, "depois do sinal chegar, o próximo tick tem de ser SUCCESS")
	assert_eq(_character.talking_text, "Frase chegada mais tarde")


## A armadilha do enunciado da T-106: a ponte emite phrase_ready SINCRONAMENTE,
## dentro da própria chamada a request_phrase, antes de devolver o
## request_id. Uma implementação que só guardasse o request_id DEPOIS de
## chamar request_phrase perderia esta resposta e ficaria RUNNING para
## sempre; este teste falha nesse cenário e passa com a ligação do sinal
## antes da chamada.
func test_resposta_sincrona_dentro_de_request_phrase_ainda_resolve_para_success() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	bridge.synchronous = true
	bridge.text_to_emit = "Frase sincrona"
	var action := _make_action(bridge)

	var result := action.tick(_character, _blackboard)

	assert_eq(
		result, action.SUCCESS, "resposta síncrona tem de resolver já no mesmo tick, nunca RUNNING"
	)
	assert_eq(_character.talking_text, "Frase sincrona")


## Bloqueante da revisão da T-107, ronda 1: um `min_interval_s` configurado
## abaixo de `MIN_VISIBLE_S` (aqui 1.0, contra o mínimo real de 3.0) não pode
## fazer `tick()` pedir uma frase nova antes dos 3 s efectivos, porque o
## `SpeechBubble` substitui o texto sem condição em `show_text()` (nunca
## espera que a frase anterior tenha ficado visível o suficiente): se
## `tick()` só olhasse para `min_interval_s`, a frase B substituiria a A ao
## fim de 1 s, e A teria ficado visível só 1 s, não os 3 s garantidos. O
## relógio falso começa em 1000.0, nunca em 0.0 (T-106, bug de tempo
## absoluto).
func test_min_interval_s_abaixo_do_minimo_e_elevado_a_min_visible_s() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	bridge.synchronous = true
	bridge.text_to_emit = "Primeira frase"
	var action := _make_action(bridge)
	action.settings.min_interval_s = 1.0
	var clock := FakeClock.new()
	clock.now_s = 1000.0
	action.clock = Callable(clock, "get_now")

	var first := action.tick(_character, _blackboard)
	assert_eq(first, action.SUCCESS)
	assert_eq(bridge.call_count, 1, "a 1ª frase tem de chamar a ponte")
	assert_eq(_character.talking_text, "Primeira frase")

	# 1.5s depois: já passou o min_interval_s configurado (1.0), mas ainda não
	# passou o MIN_VISIBLE_S (3.0). Se o bloqueante não estivesse corrigido, a
	# ponte seria chamada aqui e a frase A teria ficado visível só 1.5s.
	bridge.text_to_emit = "Segunda frase"
	clock.now_s = 1001.5
	var second := action.tick(_character, _blackboard)

	assert_eq(
		second,
		action.SUCCESS,
		"a 1.5s, ainda dentro do intervalo EFECTIVO de 3s, o tick resolve-se sem falar de novo"
	)
	assert_eq(
		bridge.call_count,
		1,
		"a 1.5s a ponte não pode ser chamada outra vez, mesmo com min_interval_s=1.0"
	)
	assert_eq(
		_character.talking_text,
		"Primeira frase",
		"a frase A tem de continuar visível: só passaram 1.5s dos 3s efectivos garantidos"
	)

	# 3.1s depois da primeira frase: passou o MIN_VISIBLE_S efectivo, mesmo
	# com min_interval_s=1.0 configurado. Agora sim, a ponte pode ser chamada.
	clock.now_s = 1003.1
	var third := action.tick(_character, _blackboard)

	assert_eq(third, action.SUCCESS)
	assert_eq(bridge.call_count, 2, "passados os 3s efectivos, a ponte pode ser chamada de novo")
	assert_eq(_character.talking_text, "Segunda frase")


## min_interval_s partilhado via blackboard: se uma frase foi dita há pouco
## tempo (menos do que min_interval_s), um tick novo tem de devolver SUCCESS
## sem chamar a ponte outra vez. Desde a T-107 nunca limpa o balão, nem
## antes nem depois de qualquer tempo: um tick bloqueado pelo intervalo não
## toca em `character.talking_text`, ponto final; quem decide se e quando a
## frase desaparece é o `SpeechBubble`, não esta classe. O relógio falso
## começa em 1000.0, nunca em 0.0 (um bug de tempo absoluto não pode passar
## despercebido só porque 0.0 também seria um valor plausível).
func test_respeita_min_interval_s_entre_frases() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	bridge.synchronous = true
	bridge.text_to_emit = "Primeira frase"
	var action := _make_action(bridge)
	action.settings.min_interval_s = 1000.0
	var clock := FakeClock.new()
	clock.now_s = 1000.0
	action.clock = Callable(clock, "get_now")

	var first := action.tick(_character, _blackboard)
	assert_eq(first, action.SUCCESS)
	assert_eq(bridge.call_count, 1, "a 1ª frase tem de chamar a ponte")
	assert_eq(_character.talking_text, "Primeira frase")

	clock.now_s = 1000.1
	var second := action.tick(_character, _blackboard)

	assert_eq(
		second, action.SUCCESS, "dentro do intervalo mínimo, o tick resolve-se sem falar de novo"
	)
	assert_eq(
		bridge.call_count, 1, "dentro do intervalo mínimo, a ponte não pode ser chamada outra vez"
	)
	assert_eq(
		_character.talking_text,
		"Primeira frase",
		"bloqueado pelo intervalo, o tick nunca toca no balão: continua com a frase de A"
	)

	clock.now_s = 1000.0 + action.MIN_VISIBLE_S + 5.0
	var third := action.tick(_character, _blackboard)

	assert_eq(
		third, action.SUCCESS, "continua dentro do intervalo mínimo, resolve-se sem falar de novo"
	)
	assert_eq(
		bridge.call_count, 1, "ainda bloqueado pelo intervalo, a ponte não é chamada outra vez"
	)
	assert_eq(
		_character.talking_text,
		"Primeira frase",
		(
			"mesmo muito depois de MIN_VISIBLE_S, um tick bloqueado continua a não tocar no balão: "
			+ "quem o esconderia agora é o SpeechBubble, não esta classe"
		)
	)


## Depois de o intervalo EFECTIVO passar (aqui, `min_interval_s = 0.0`, elevado
## a `MIN_VISIBLE_S` pelo `maxf` do bloqueante da T-107 ronda 1), uma segunda
## instância consegue falar de novo. NÃO prova a partilha por si só (uma
## instância sem partilha nenhuma também passaria aqui, por nunca ter falado
## antes ela própria); quem prova a partilha é
## `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira`, que
## mostra a 2ª instância BLOQUEADA por um tempo escrito pela 1ª no MESMO
## blackboard. Este teste prova, isso sim, que esse bloqueio partilhado NÃO é
## permanente: passa ao fim do intervalo efectivo. As duas instâncias
## partilham o MESMO relógio falso (outra instância com o SEU próprio relógio
## real também passaria aqui ao lado, pela mesma razão de nunca ter falado
## antes).
func test_duas_instancias_partilham_o_intervalo_minimo_pelo_blackboard() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	bridge.synchronous = true
	bridge.text_to_emit = "Frase da primeira instância"
	var first_action := _make_action(bridge)
	var clock := FakeClock.new()
	clock.now_s = 1000.0
	first_action.clock = Callable(clock, "get_now")

	var first_result := first_action.tick(_character, _blackboard)
	assert_eq(first_result, first_action.SUCCESS)
	assert_true(
		_blackboard.has_value("say_last_at_s"),
		"a 1ª instância tem de marcar o momento em que falou no blackboard"
	)

	bridge.text_to_emit = "Frase da segunda instância"
	var second_action := _make_action(bridge)
	second_action.clock = Callable(clock, "get_now")
	clock.now_s = 1000.0 + second_action.MIN_VISIBLE_S + 0.1

	var second_result := second_action.tick(_character, _blackboard)

	assert_eq(
		second_result,
		second_action.SUCCESS,
		(
			"passado o intervalo EFECTIVO (MIN_VISIBLE_S, já que min_interval_s = 0.0), a 2ª instância "
			+ "também pode falar"
		)
	)
	assert_eq(_character.talking_text, "Frase da segunda instância")
	assert_eq(bridge.call_count, 2)


## A mesma partilha, mas provando o BLOQUEIO: com um min_interval_s enorme, a
## instância B (um nó diferente, o mesmo blackboard) tem de ficar impedida de
## falar pelo que a instância A acabou de escrever em say_last_at_s. Uma
## implementação em que cada nó lê o seu PRÓPRIO relógio (em vez do
## blackboard partilhado) passa aqui ao lado: a instância B chamaria a ponte
## outra vez, porque nunca tinha falado antes ela própria.
##
## Com um relógio controlado: a instância B, bloqueada, faz tick() LOGO A
## SEGUIR (o cenário real do bug original: a sequência seguinte chega ao
## destino poucos frames depois de A falar) e o texto de A tem de CONTINUAR
## visível, agora e sempre que B continuar bloqueada (T-107: nenhuma
## instância desta classe limpa o balão, seja o tempo que for; ver docstring
## do ficheiro). O relógio falso começa em 1000.0, nunca em 0.0.
func test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	bridge.synchronous = true
	bridge.text_to_emit = "Frase da primeira instância"
	var first_action := _make_action(bridge)
	first_action.settings.min_interval_s = 1000.0
	var clock := FakeClock.new()
	clock.now_s = 1000.0
	first_action.clock = Callable(clock, "get_now")

	var first_result := first_action.tick(_character, _blackboard)
	assert_eq(first_result, first_action.SUCCESS)
	assert_eq(bridge.call_count, 1, "a 1ª instância tem de chamar a ponte")

	bridge.text_to_emit = "Frase da segunda instância"
	var second_action := _make_action(bridge)
	second_action.settings.min_interval_s = 1000.0
	second_action.clock = Callable(clock, "get_now")

	clock.now_s = 1000.1
	var second_result := second_action.tick(_character, _blackboard)

	assert_eq(
		second_result,
		second_action.SUCCESS,
		"a 2ª instância resolve-se sem falar, bloqueada pelo intervalo partilhado"
	)
	assert_eq(
		bridge.call_count,
		1,
		"a 2ª instância não pode chamar a ponte: o intervalo mínimo ainda não passou"
	)
	assert_eq(
		_character.talking_text,
		"Frase da primeira instância",
		(
			"a frase de A, dita há só 0.1s, tem de continuar visível: "
			+ "a 2ª instância bloqueada não pode apagá-la"
		)
	)

	clock.now_s = 1000.0 + second_action.MIN_VISIBLE_S + 5.0
	var third_result := second_action.tick(_character, _blackboard)

	assert_eq(third_result, second_action.SUCCESS, "continua bloqueada pelo intervalo partilhado")
	assert_eq(bridge.call_count, 1, "ainda bloqueada, a ponte não é chamada outra vez")
	assert_eq(
		_character.talking_text,
		"Frase da primeira instância",
		(
			"mesmo muito depois de MIN_VISIBLE_S, bloqueada pelo intervalo mínimo, esta classe "
			+ "continua a não tocar no balão"
		)
	)


## `phrase_ready` chegado com o request_id de OUTRO pedido (nunca o desta
## instância) tem de ser ignorado: continua RUNNING, sem falar o texto
## errado. Uma implementação que resolvesse por qualquer `_has_result`, sem
## comparar o request_id, falaria com a frase de um pedido que não é o seu.
func test_ignora_phrase_ready_com_request_id_de_outro_pedido() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	var action := _make_action(bridge)

	var first := action.tick(_character, _blackboard)
	assert_eq(first, action.RUNNING, "sem resposta ainda, o 1º tick tem de ficar RUNNING")
	var own_request_id := bridge.last_request_id

	bridge.emit_now(own_request_id + 999, "Frase de outro pedido")
	var second := action.tick(_character, _blackboard)
	assert_eq(
		second,
		action.RUNNING,
		"phrase_ready de outro request_id tem de ser ignorado, continua RUNNING"
	)
	assert_eq(_character.talking_text, "", "não fala o texto de um pedido que não é o seu")

	bridge.emit_now(own_request_id, "Frase do pedido certo")
	var third := action.tick(_character, _blackboard)
	assert_eq(third, action.SUCCESS, "o request_id certo resolve normalmente")
	assert_eq(_character.talking_text, "Frase do pedido certo")


## interrupt() tem de esquecer o pedido em curso: sem isto, um tick() novo
## na MESMA instância (reutilizada pela árvore) resolveria com o
## _awaiting_request_id antigo, através de _resolve_awaiting(), em vez de
## pedir uma frase nova para o contexto actual. Prova: depois de
## interromper, a resposta TARDIA do pedido interrompido chega (como
## chegaria de um LLMBridge real cujo HTTPRequest só resolve mais tarde) e
## tem de ser ignorada; o tick seguinte pede um pedido NOVO e fica RUNNING
## de novo, nunca resolve com o texto antigo.
func test_interrupt_esquece_o_pedido_em_curso() -> void:
	var bridge: FakeBridge = autofree(FakeBridge.new())
	var action := _make_action(bridge)

	var first := action.tick(_character, _blackboard)
	assert_eq(first, action.RUNNING, "sem resposta ainda, o 1º tick tem de ficar RUNNING")
	var interrupted_request_id := bridge.last_request_id
	assert_eq(bridge.call_count, 1)

	action.interrupt(_character, _blackboard)

	bridge.emit_now(interrupted_request_id, "Frase tardia do pedido interrompido")
	var second := action.tick(_character, _blackboard)

	assert_eq(
		second,
		action.RUNNING,
		"depois de interrupt(), um tick novo pede outra frase, não resolve com o pedido antigo"
	)
	assert_eq(
		bridge.call_count,
		2,
		"interrupt() teve de permitir um pedido novo, não reaproveitar o request_id interrompido"
	)
	assert_eq(
		_character.talking_text,
		"",
		"não pode falar com a resposta tardia de um pedido já esquecido por interrupt()"
	)

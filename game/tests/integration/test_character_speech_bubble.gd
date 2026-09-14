extends GutTest
## Teste de integração da ligação Character -> SpeechBubble com os nós REAIS
## de `game/guy/guy.tscn` (T-107, tech_design.md §4.6), ao contrário de
## `test_speech_bubble.gd` que usa um `SpeechBubble.new()` isolado.
##
## `add_child_autofree(_guy)` fica em `before_each()`, nunca dentro do corpo
## de um teste: `guy.tscn` tem um `BeehaveTree`, cujo `_ready()` chama o
## depurador visual do Beehave (`register_tree`), que imprime "Can't send
## message. No active debugger" em headless (AGENTS.md §10, ruído
## conhecido). O GUT só conta como "inesperado" de um teste o que acontece
## entre `error_tracker.start_test()` (chamado depois de `before_each()`
## resolver, `gut.gd:618`) e a verificação em `gut.gd:624`; posto em
## `before_each()` (que corre antes disso, `gut.gd:612`), o erro cai fora
## dessa janela e não faz o teste falhar à toa (mesmo padrão de
## `test_main_scene.gd`, que também carrega uma cena com `BeehaveTree`). Um
## `SCRIPT ERROR` real disparado pela própria montagem da cena dentro de
## `before_each()` também cai fora dessa janela e NÃO faz nenhum destes
## testes GUT falhar: quem apanha esse caso é o `scripts/verify.sh`
## (`log_has_script_errors`, corrido sobre o log completo da suite), não o
## GUT por si só.


## Relógio falso injectável via `SpeechBubble.clock` (Callable), mesmo padrão
## de `test_speech_bubble.gd`: começa em 1000.0, nunca em 0.0.
class FakeClock:
	var now_s: float = 1000.0

	func get_now() -> float:
		return now_s


var _guy: Character


func before_each() -> void:
	var packed: PackedScene = load("res://guy/guy.tscn") as PackedScene
	assert_not_null(packed, "guy.tscn tem de carregar")
	_guy = packed.instantiate() as Character
	add_child_autofree(_guy)


## Escrever `Character.talking_text` tem de acender o `SpeechBubble` real de
## `guy.tscn` (`visible` e o texto do `Label` interno) e tem de passar pela
## duração agendada por `show_text()`, não só por uma escrita directa de
## `.text`/`.visible` que acende o balão mas nunca o agenda para desaparecer.
## As duas primeiras asserções por si só não distinguem as duas coisas (uma
## escrita directa também acende o balão com o texto certo); é a 3ª asserção,
## com um relógio falso avançado além de `display_seconds_for(texto)` e
## `check_hide()` chamado a seguir, que apanha essa mutação: sem passar por
## `show_text()`, `_hide_at_s` nunca fica agendado (continua em `-1.0`) e o
## balão real fica visível para sempre.
func test_talking_text_mostra_o_speech_bubble_real_com_o_texto() -> void:
	assert_not_null(_guy, "a raiz de guy.tscn tem de ser um Character (Guy)")
	assert_not_null(_guy.speech_bubble, "guy.tscn tem de ter o SpeechBubble ligado")

	var clock := FakeClock.new()
	_guy.speech_bubble.clock = Callable(clock, "get_now")

	var texto := "Frase de teste na cena real"
	_guy.talking_text = texto

	assert_true(
		_guy.speech_bubble.visible, "escrever talking_text tem de mostrar o SpeechBubble real"
	)
	assert_eq(_guy.speech_bubble.label.text, texto)

	clock.now_s += _guy.speech_bubble.display_seconds_for(texto) + 0.1
	_guy.speech_bubble.check_hide()
	assert_false(
		_guy.speech_bubble.visible,
		(
			"passada a duração agendada, o balão real tem de se esconder sozinho: só acontece se "
			+ "talking_text tiver passado por show_text(), que é quem agenda _hide_at_s"
		)
	)


## `talking_text = ""` tem de esconder o balão real, tal como esconde o
## `SpeechBubble` isolado em `test_speech_bubble.gd`.
func test_talking_text_vazio_esconde_o_speech_bubble_real() -> void:
	_guy.talking_text = "Frase de teste na cena real"
	assert_true(_guy.speech_bubble.visible, "pré-condição: o balão tem de estar visível")

	_guy.talking_text = ""

	assert_false(_guy.speech_bubble.visible, "talking_text = '' tem de esconder o balão real")

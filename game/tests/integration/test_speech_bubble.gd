extends GutTest
## Testes de integração de [SpeechBubble] (T-107, tech_design.md §4.6):
## `display_seconds_for()` segue `clamp(2.5 + 0.35 * palavras, 3, 9)`, e o
## balão esconde-se sozinho ao fim dessa duração, com um relógio controlado
## em vez de tempo real (mesmo padrão de `test_say_generated_action.gd`).
## Cobre também o reinício do temporizador quando `show_text()` é chamado
## enquanto o balão ainda está visível, e a posição do balão (o fundo fixo em
## `BOTTOM_OFFSET`, centrado horizontalmente) para frases de 1 e de várias
## linhas, incluindo mostradas a partir do balão escondido. A ligação
## `Character` -> `SpeechBubble` REAL, com a cena `guy.tscn`, tem um ficheiro
## à parte (`test_character_speech_bubble.gd`, mesmo motivo do `before_each`
## de `test_main_scene.gd`: o `add_child_autofree` de uma cena com
## `BeehaveTree` tem de ficar em `before_each()`, nunca dentro do corpo do
## teste, senão o "Can't send message. No active debugger" do Beehave em
## headless conta como erro inesperado deste teste, AGENTS.md §10).
##
## O relógio falso NUNCA começa em 0.0: começa em 1000.0 e avança a partir
## daí, para um bug de tempo absoluto (ex.: comparar contra 0.0 em vez de
## usar o `clock` injectado) não passar despercebido só porque 0.0 também
## seria, por coincidência, um valor plausível.


## Relógio falso injectável via `SpeechBubble.clock` (Callable): `now_s`
## avança-se manualmente no teste.
class FakeClock:
	var now_s: float = 1000.0

	func get_now() -> float:
		return now_s


var _bubble: SpeechBubble


func before_each() -> void:
	_bubble = SpeechBubble.new()
	var label := Label.new()
	# add_child ANTES de add_child_autofree(_bubble): assim o Label é filho
	# real do balão, e autofree liberta a subárvore inteira; um Label só
	# atribuído à propriedade `label` sem ser filho fica orfão quando o
	# balão é libertado (9 órfãos medidos antes desta correcção).
	_bubble.add_child(label)
	_bubble.label = label
	add_child_autofree(_bubble)


## Junta `count` palavras separadas por espaço (o conteúdo de cada palavra
## não importa para display_seconds_for(), só a contagem).
func _words(count: int) -> String:
	var parts: PackedStringArray = []
	for _i in range(count):
		parts.append("palavra")
	return " ".join(parts)


func test_display_seconds_for_zero_palavras_fica_no_minimo() -> void:
	assert_almost_eq(
		_bubble.display_seconds_for(""), 3.0, 0.001, "2.5 + 0.35*0 = 2.5, abaixo do mínimo de 3.0"
	)


func test_display_seconds_for_uma_palavra_fica_no_minimo() -> void:
	assert_almost_eq(
		_bubble.display_seconds_for("Olá"),
		3.0,
		0.001,
		"2.5 + 0.35*1 = 2.85, ainda abaixo do mínimo de 3.0"
	)


func test_display_seconds_for_quinze_palavras_segue_a_formula() -> void:
	var text := _words(15)
	assert_almost_eq(_bubble.display_seconds_for(text), 7.75, 0.001, "2.5 + 0.35*15 = 7.75")


func test_display_seconds_for_muitas_palavras_fica_no_maximo() -> void:
	var text := _words(20)
	assert_almost_eq(
		_bubble.display_seconds_for(text), 9.0, 0.001, "2.5 + 0.35*20 = 9.5, acima do máximo de 9.0"
	)


## O limite inferior do clamp (3.0) tem de continuar igual a
## `SayGeneratedAction.MIN_VISIBLE_S`: essa classe já não gere a duração do
## balão sozinha (T-107, quem manda é o `SpeechBubble`), mas continua a ler
## `MIN_VISIBLE_S` em `tick()`, como piso do intervalo EFECTIVO
## (`maxf(min_interval_s, MIN_VISIBLE_S)`, correcção da ronda 1 de revisão da
## T-107); a garantia de "nenhuma frase visível menos de 3 s" só se mantém se
## os dois números nunca se separarem. O nome desta função mantém-se (citado
## em `say_generated_action.gd` e no Relatório da T-107); só a docstring
## estava desactualizada.
func test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s() -> void:
	assert_eq(SpeechBubble.MIN_SECONDS, SayGeneratedAction.MIN_VISIBLE_S)


func test_show_text_torna_o_balao_visivel_com_o_texto() -> void:
	_bubble.show_text("Frase de teste")
	assert_true(_bubble.visible, "show_text() com texto não vazio mostra o balão")
	assert_eq(_bubble.label.text, "Frase de teste")


func test_show_text_com_texto_vazio_esconde_o_balao() -> void:
	_bubble.show_text("Frase de teste")
	_bubble.show_text("")
	assert_false(_bubble.visible, "show_text('') esconde o balão de imediato")
	assert_eq(_bubble.label.text, "")


## O balão desaparece sozinho ao fim de display_seconds_for(texto), com
## tempo simulado (relógio falso), nunca à espera de segundos reais.
func test_balao_desaparece_ao_fim_da_duracao_simulada() -> void:
	var clock := FakeClock.new()
	_bubble.clock = Callable(clock, "get_now")

	_bubble.show_text("Olá")
	var duration := _bubble.display_seconds_for("Olá")
	assert_almost_eq(duration, 3.0, 0.001)

	clock.now_s += duration - 0.5
	_bubble.check_hide()
	assert_true(_bubble.visible, "ainda não passou a duração inteira: continua visível")

	clock.now_s += 1.0
	_bubble.check_hide()
	assert_false(_bubble.visible, "passada a duração agendada, o balão esconde-se sozinho")
	assert_eq(_bubble.label.text, "", "esconder também limpa o texto")


## Uma frase mais longa fica visível mais tempo do que uma curta: prova que
## a duração agendada por show_text() depende mesmo do texto, não é um valor
## fixo.
func test_frase_mais_longa_fica_visivel_mais_tempo() -> void:
	var clock := FakeClock.new()
	_bubble.clock = Callable(clock, "get_now")

	_bubble.show_text(_words(20))

	clock.now_s += SpeechBubble.MAX_SECONDS - 0.5
	_bubble.check_hide()
	assert_true(
		_bubble.visible, "uma frase de 20 palavras (clamp máximo) ainda não devia ter desaparecido"
	)

	clock.now_s += 1.0
	_bubble.check_hide()
	assert_false(_bubble.visible)


## `show_text()` chamado enquanto o balão AINDA está visível (frase A a meio
## da sua duração) tem de reiniciar por completo o temporizador para a frase
## B: a duração de B conta-se a partir do 2º show_text(), não do 1º. Uma
## implementação que só agendasse `_hide_at_s` quando o balão ainda não
## estava visível (ex.: um `if not visible:` a proteger essa linha) deixaria
## o `_hide_at_s` antigo (o de A) por cima, e B desapareceria demasiado cedo,
## contado a partir de A em vez de B.
func test_show_text_reinicia_o_temporizador_mesmo_com_o_balao_ja_visivel() -> void:
	var clock := FakeClock.new()
	_bubble.clock = Callable(clock, "get_now")

	_bubble.show_text(_words(2))  # frase A, agenda o hide para 1000.0 + 3.2
	clock.now_s += 2.0  # 1002.0: A ainda visível, a meio da sua duração
	_bubble.show_text(_words(2))  # frase B, mesmo número de palavras que A

	var duration_b := _bubble.display_seconds_for(_words(2))
	clock.now_s += duration_b - 0.5
	_bubble.check_hide()
	assert_true(
		_bubble.visible,
		(
			"B ainda não passou a SUA PRÓPRIA duração (contada a partir do 2º show_text); "
			+ "um temporizador não reiniciado (herdado de A) já teria expirado aqui"
		)
	)
	assert_eq(_bubble.label.text, _words(2))

	clock.now_s += 1.0
	_bubble.check_hide()
	assert_false(
		_bubble.visible, "passada a duração de B contada a partir do 2º show_text(), esconde-se"
	)


## `position` (o fundo do balão) fica fixo em `BOTTOM_OFFSET` independente do
## número de linhas que o texto precisa, para o balão crescer sempre para
## CIMA (nunca sobre o personagem). Testado com uma frase curta (1 linha) e
## uma longa (várias linhas, mais alta): sem a linha que fixa `position`
## depois de `reset_size()`, o balão ficaria na posição por defeito (0, 0) e
## esta invariante falharia para qualquer texto.
func test_posicao_fixa_o_fundo_do_balao_para_frases_de_1_e_de_varias_linhas() -> void:
	var texts := [_words(1), _words(20)]
	var previous_height: float = -1.0
	for text in texts:
		_bubble.show_text(text)
		assert_almost_eq(
			_bubble.position.y + _bubble.size.y,
			SpeechBubble.BOTTOM_OFFSET,
			0.01,
			"o fundo do balão (position.y + size.y) tem de ficar fixo em BOTTOM_OFFSET: '%s'" % text
		)
		assert_almost_eq(
			_bubble.position.x,
			-_bubble.size.x / 2.0,
			0.01,
			"o balão tem de ficar centrado horizontalmente: '%s'" % text
		)
		assert_gt(
			_bubble.size.y,
			previous_height,
			"a frase mais longa tem de ocupar mais linhas (balão mais alto) do que a anterior"
		)
		previous_height = _bubble.size.y


## A mesma invariante de posição, agora mostrada com o balão ESCONDIDO antes
## de show_text() (não visible=true à partida): confirma que o recálculo de
## `position` não depende de o balão já estar visível.
func test_posicao_fixa_o_fundo_do_balao_mesmo_mostrada_com_o_balao_escondido() -> void:
	_bubble.hide_now()
	assert_false(_bubble.visible, "pré-condição: o balão começa escondido")

	_bubble.show_text(_words(20))

	assert_almost_eq(
		_bubble.position.y + _bubble.size.y,
		SpeechBubble.BOTTOM_OFFSET,
		0.01,
		"mostrado a partir de escondido, o fundo do balão tem de ficar fixo em BOTTOM_OFFSET"
	)
	assert_almost_eq(
		_bubble.position.x,
		-_bubble.size.x / 2.0,
		0.01,
		"mostrado a partir de escondido, o balão tem de ficar centrado horizontalmente"
	)

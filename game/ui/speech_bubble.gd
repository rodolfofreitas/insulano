class_name SpeechBubble
extends PanelContainer
## Balão de fala do personagem: fundo opaco e legível sobre qualquer fundo da
## ilha, largura máxima com quebra de linha e desaparecimento automático
## proporcional ao comprimento da frase (tech_design.md §4.6).
##
## Usado por `Character.speech_bubble` (`game/character/character.gd`) em vez
## do `Label` simples que a base trazia. Quem manda na duração de exibição é
## este nó, não quem lhe pede para falar: `show_text()` agenda o próprio
## desaparecimento, e `SayGeneratedAction` (T-106, `game/beehave/
## say_generated_action.gd`) já não limpa o balão, para não haver dois donos
## da mesma duração (ver o Relatório da T-107 em
## backlog/fase-1/T-107-speech-bubble.md). Não faz animações de entrada nem
## saída (fora de âmbito da T-107): aparece e desaparece instantaneamente.

## Segundos de exibição mínimos, máximos e por palavra do clamp da duração:
## clamp(2.5 + 0.35 * palavras, 3, 9) (tech_design.md §4.6). O mínimo (3 s)
## é o mesmo valor que `SayGeneratedAction.MIN_VISIBLE_S` usava antes desta
## tarefa, quando ainda era essa classe a decidir a duração.
const MIN_SECONDS: float = 3.0
const MAX_SECONDS: float = 9.0
const BASE_SECONDS: float = 2.5
const SECONDS_PER_WORD: float = 0.35

## Largura máxima do balão, em pixels do espaço do mundo (o `Character` é um
## `CharacterBody2D`; o balão herda o zoom da câmara tal como o resto do
## personagem). Uma frase mais larga do que isto quebra linha em vez de
## continuar a crescer para os lados e sair do ecrã (critério da T-107).
const MAX_WIDTH: float = 220.0

## Distância (unidades do mundo, eixo Y) entre a origem do `Character` e o
## fundo do balão. `show_text()` mantém-a fixa mesmo quando o balão precisa
## de mais linhas: sem isto, o balão crescia sempre para BAIXO (em direcção
## ao personagem, chegando a cobri-lo por cima, bug apanhado por inspecção
## visual antes da versão final de `docs/proof/T-107-balao-1080p.png`),
## porque `reset_size()` cresce a partir do canto superior esquerdo do
## rectângulo actual, e não respeita `grow_vertical` numa chamada directa a
## partir de código (só quando o redimensionamento vem do sistema de
## anchors, ex.: o viewport a mudar de tamanho).
const BOTTOM_OFFSET: float = -16.0

## Label onde o texto é desenhado; atribuído na cena (`game/guy/guy.tscn`) ou
## encontrado automaticamente em `_ready()` se ficar por preencher.
@export var label: Label

## Relógio a usar para agendar o desaparecimento. Testes injectam um
## `Callable` sem argumentos que devolve segundos controlados (mesmo padrão
## de `say_generated_action.gd`); em jogo fica inválido (`Callable()`) e
## usa-se `Time.get_ticks_msec()`.
var clock: Callable = Callable()

## Instante (segundos, mesma base do relógio) em que o balão se deve
## esconder, ou -1.0 se não há nada agendado.
var _hide_at_s: float = -1.0
## Conta palavras do mesmo modo que `PhraseFilter._word_pattern`
## (`game/llm/phrase_filter.gd`): sequências de não-espaço, com o prefixo
## "(*UCP)" para o `\S` tratar acentuados e o NBSP (U+00A0) como a base
## Unicode exige, em vez do ASCII por defeito do PCRE2 do Godot. Mesma
## contagem, para o clamp da duração nunca divergir do que o `PhraseFilter`
## considerou uma palavra ao aceitar a frase.
var _word_pattern: RegEx = RegEx.create_from_string("(*UCP)\\S+")


## Esconde o balão à partida (sem texto, não há nada para mostrar) e aplica
## o estilo visual (fundo opaco, contraste, largura máxima).
func _ready() -> void:
	visible = false
	if label == null:
		label = find_child("Label", true, false) as Label
	if label != null:
		label.custom_minimum_size.x = MAX_WIDTH
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_style()


## Mostra `text` no balão e agenda o desaparecimento automático ao fim de
## `display_seconds_for(text)`; `text` vazio esconde de imediato. Chamado por
## `Character.talking_text` (nunca directamente pela árvore de
## comportamento, que só conhece `Character`, tech_design.md §4.6).
func show_text(text: String) -> void:
	if label != null:
		label.text = text
	if text == "":
		hide_now()
		return
	# reset_size() força o PanelContainer a recalcular o seu tamanho a
	# partir do tamanho mínimo do Label (que, com autowrap e uma largura
	# mínima fixa, já reflecte quantas linhas o texto novo precisa): sem
	# isto o balão ficava com o tamanho da frase ANTERIOR até o motor
	# decidir recalcular por conta própria, um frame ou mais depois de
	# `show_text()` devolver, e a screenshot da T-107 apanhava esse atraso.
	# reset_size() sozinho cresce sempre para baixo (ver BOTTOM_OFFSET); a
	# linha seguinte reposiciona o balão para crescer para cima em vez de
	# tapar o personagem.
	reset_size()
	position = Vector2(-size.x / 2.0, BOTTOM_OFFSET - size.y)
	visible = true
	_hide_at_s = _now_s() + display_seconds_for(text)


## Esconde o balão de imediato, independentemente da duração agendada, e
## limpa o texto (para uma leitura de acessibilidade não repetir a frase
## antiga enquanto o balão está invisível).
func hide_now() -> void:
	visible = false
	_hide_at_s = -1.0
	if label != null:
		label.text = ""


## Segundos que uma frase deve ficar visível: `clamp(2.5 + 0.35 * palavras, 3, 9)`
## (tech_design.md §4.6). Pura em relação ao relógio: não agenda nada, só
## calcula.
func display_seconds_for(text: String) -> float:
	var word_count := _word_pattern.search_all(text).size()
	return clampf(BASE_SECONDS + SECONDS_PER_WORD * word_count, MIN_SECONDS, MAX_SECONDS)


## Chamado a cada frame (motor real); só delega em `check_hide()`. Exposto sem
## `_` a mais no nome só por ser chamado pelo motor; os testes GUT nunca
## chamam `_process()` directamente (o GUT não corre frames), chamam
## `check_hide()`, que é quem tem a lógica real (AGENTS.md §6, costuras de
## teste).
func _process(_delta: float) -> void:
	check_hide()


## Esconde o balão se já passou o instante agendado por `show_text()`; nunca
## faz nada se não há nada agendado (`_hide_at_s < 0`) ou se já está
## escondido. Separado de `_process()` para os testes chamarem sem depender
## do motor correr frames.
func check_hide() -> void:
	if visible and _hide_at_s >= 0.0 and _now_s() >= _hide_at_s:
		hide_now()


## Segundos a usar para agendar e verificar o desaparecimento: o `clock`
## injectado, se válido (testes), senão `Time.get_ticks_msec()` (jogo real).
func _now_s() -> float:
	if clock.is_valid():
		return clock.call()
	return Time.get_ticks_msec() / 1000.0


## Fundo branco opaco (#FFFFFF, alfa 1.0) e texto quase preto (#141414):
## contraste 18,4:1 pela luminância relativa WCAG, muito acima do mínimo de
## 4.5:1 pedido pela T-107, legível sobre a água azul e a relva verde da
## ilha. Cálculo completo no Relatório da tarefa. Moldura turquesa suave só
## por identidade visual; não entra no cálculo de contraste (só texto contra
## fundo conta).
func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	style.border_color = Color(0.16, 0.42, 0.46, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(6)
	add_theme_stylebox_override("panel", style)
	if label != null:
		label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1.0))

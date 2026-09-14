@tool
extends Node2D
## Marcador visual de um ponto de pesca, com círculo vermelho só no editor.
##
## O círculo ajuda a colocar os pontos durante a edição da cena e nunca aparece
## em jogo, no protector de ecrã nem nas capturas de ecrã (ver T-003: antes
## aparecia sempre).
##
## Puramente cosmético (debug/gameplay), sem lógica própria; o grupo a que o
## nó pertence (ex. "fishingSpot") é lido por `FindGroupSpotCondition`.


## Verdadeiro só quando a cena está aberta no editor do Godot, nunca em jogo.
func should_draw_debug_circle() -> bool:
	return Engine.is_editor_hint()


func _draw() -> void:
	if should_draw_debug_circle():
		draw_circle(Vector2.ZERO, 10, Color.RED, false, 2)


func _ready() -> void:
	queue_redraw()

extends Node2D
## Marcador visual de um ponto de pesca: desenha um círculo vermelho na cena.
##
## Puramente cosmético (debug/gameplay), sem lógica própria; o grupo a que o
## nó pertence (ex. "fishingSpot") é lido por `FindGroupSpotCondition`.


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.RED, false, 2)


func _ready() -> void:
	queue_redraw()

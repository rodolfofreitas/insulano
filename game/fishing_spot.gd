extends Node2D

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.RED, false, 2)

func _ready() -> void:
	queue_redraw()

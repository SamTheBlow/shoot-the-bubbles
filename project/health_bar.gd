@tool
class_name HealthBar
extends Node2D


var _amount_left: float = 1.0


func _draw() -> void:
	draw_rect(Rect2(-64.0, -6.0, 128.0, 12.0), Color.BLACK)
	draw_rect(Rect2(-62.0, -4.0, 124.0 * _amount_left, 8.0), Color.from_hsv(0, 0.5, 0.75))


## Input is a value from 0.0 to 1.0
func update_health(amount_left: float) -> void:
	_amount_left = amount_left
	queue_redraw()

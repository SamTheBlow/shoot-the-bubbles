extends Node2D


@export var bubble: Bubble
@export var movement_timer: Timer

var _is_moving: bool = true
var _movement_to: Vector2 = Vector2(345.5, 225.0)


func _process(_delta: float) -> void:
	if _is_moving:
		bubble.position = lerp(bubble.position, _movement_to, 0.02)
		if bubble.position.distance_to(_movement_to) <= 1.0:
			_is_moving = false
			_start_movement_timer()


func _start_movement_timer() -> void:
	movement_timer.stop()
	movement_timer.wait_time = randf() * 3.0 + 2.0
	movement_timer.start()


func _on_movement_timer_timeout() -> void:
	_movement_to = Vector2(randf() * 307.0 + 192.0, randf() * 50.0 + 200.0)
	_is_moving = true

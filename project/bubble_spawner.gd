class_name BubbleSpawner
extends Node2D


@export var game: Game

## Waits this amount of time (in seconds) before starting
@export var start_time: float = 0.0

## In seconds
@export var time_between_each: float = 1.0

## This is how many bubbles this spawner will spawn in total
@export var number_to_spawn: int = 1

## 0: small, 1: normal, 2: large
@export var bubble_size: int = 1

## 0: random upgrade, 1: orange, 2: blue, 3: pink, 4: green
@export var bubble_type: int = 4

@export var speed: float = 1.0

var _number_spawned: int = -1
var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.autostart = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	if start_time == 0.0:
		_start_spawning()
		return
	
	_timer.wait_time = start_time
	_timer.start()


func _start_spawning() -> void:
	_timer.stop()
	_timer.wait_time = time_between_each
	_timer.start()


func _on_timer_timeout() -> void:
	if _number_spawned == -1:
		_start_spawning()
		_number_spawned = 0
		return
	
	if _number_spawned >= number_to_spawn:
		_timer.queue_free()
		return
	
	var bubble: Bubble
	if bubble_size == 0:
		bubble = game.bubble_small_scene.instantiate() as Bubble
	elif bubble_size == 1:
		bubble = game.bubble_normal_scene.instantiate() as Bubble
	else:
		bubble = game.bubble_large_scene.instantiate() as Bubble
	bubble.position = position
	bubble.linear_velocity = Vector2.from_angle(rotation) * speed
	if bubble_type == 0:
		bubble.type = (randi() % 3) + 1
	else:
		bubble.type = bubble_type
	
	game.spawn_bubble(bubble)
	_number_spawned += 1

extends Node2D


@export var game: Game

@export var start_time: float = 1.0
@export var speed: float = 1.0
@export var bubbles_in_circle: int = 1
## 0: random, 1: orange, 2: blue, 3: pink, 4: green, 5: random upgrade
@export var bubble_type: int = 0
@export var spinning_speed: float = 0.0
@export var circle_size: float = 48.0

var _timer: Timer
var _started: bool = false
var _time_elapsed: float = 0.0
var _bubbles: Array[Bubble] = []


func _ready() -> void:
	if start_time == 0.0:
		_on_timer_timeout()
		return
	
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.autostart = false
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	_timer.wait_time = start_time
	_timer.start()


func _process(delta: float) -> void:
	if not _started:
		return
	
	for i in _bubbles.size():
		if is_instance_valid(_bubbles[i]):
			_bubbles[i].position = position + Vector2.from_angle(2.0 * PI * (i / float(bubbles_in_circle)) + _time_elapsed * spinning_speed) * circle_size
	
	position += Vector2.from_angle(rotation) * speed * delta * 60.0
	
	_time_elapsed += delta


func _on_timer_timeout() -> void:
	_started = true
	var random_type: int = (randi() % 3) + 1
	
	for i in bubbles_in_circle:
		var bubble := game.bubble_small_scene.instantiate() as Bubble
		bubble.position = position
		bubble.linear_velocity = Vector2.from_angle(rotation) * speed
		if bubble_type == 0:
			bubble.type = mini((randi() % 6) + 1, 4)
		elif bubble_type == 5:
			bubble.type = random_type
		else:
			bubble.type = bubble_type
		
		game.spawn_bubble(bubble)
		bubble.freeze = true
		_bubbles.append(bubble)

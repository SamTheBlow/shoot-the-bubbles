class_name Player
extends CharacterBody2D


signal wave_created(wave: Wave)

@export var wave_scene: PackedScene
@export var bump_sfx_scene: PackedScene
@export var shoot_sfx_scene: PackedScene

@export var wave_spawn_point: Node2D
@export var shoot_delay_timer: Timer

@export var movement_speed: float = 400.0
@export var jump_strength: float = 700.0
@export var gravity: float = 30.0

var number_of_waves: int = 3

# For bump sfx
var _old_vel: Vector2 = Vector2.ZERO


# Remember to keep this above at least 0.05
var shoot_delay_sec: float = 0.10:
	set(value):
		shoot_delay_sec = value
		shoot_delay_timer.stop()
		shoot_delay_timer.wait_time = shoot_delay_sec
		shoot_delay_timer.start()

var is_controls_locked: bool = false


func _ready() -> void:
	# This is to initialize the timer node
	shoot_delay_sec = 0.10


func _process(_delta: float) -> void:
	if is_controls_locked:
		return
	
	var angle: float = global_position.angle_to_point(get_viewport().get_mouse_position())
	global_rotation = angle + PI * 0.5
	
	if Input.is_action_pressed("shoot") and shoot_delay_timer.is_stopped():
		add_child(shoot_sfx_scene.instantiate())
		var reach: float = minf(0.6 + 0.05 * number_of_waves, 2.0)
		var spread_range: float = (number_of_waves - 1) * (PI * reach / number_of_waves)
		for i in number_of_waves:
			wave_created.emit(_new_wave(global_rotation - spread_range / 2.0 + spread_range * i / (number_of_waves - 1)))
		shoot_delay_timer.start()


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta * 60.0
	
	if not is_controls_locked:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -jump_strength
		
		if Input.is_action_pressed("left"):
			velocity.x = -movement_speed
		elif Input.is_action_pressed("right"):
			velocity.x = movement_speed
	
	velocity.x = lerpf(velocity.x, 0.0, 0.1)
	
	move_and_slide()
	
	if _old_vel.length() - velocity.length() >= movement_speed * 0.4:
		var bump_sfx := bump_sfx_scene.instantiate() as AudioStreamPlayer
		bump_sfx.volume_db = -22.0 + minf((_old_vel.length() - velocity.length()) * 0.03, 20.0)
		add_child(bump_sfx)
	
	_old_vel = velocity


func _new_wave(angle_rad: float) -> Wave:
	var wave := wave_scene.instantiate() as Wave
	wave.global_rotation = angle_rad
	wave.global_position = wave_spawn_point.global_position
	return wave

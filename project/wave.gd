class_name Wave
extends Node2D


@export var sprite: Sprite2D

@export var speed: float = 5.0
@export var damage_dealt: int = 10
@export var push_strength: float = 30.0

var total_energy: float = 1000.0

var energy: float = total_energy:
	set(value):
		energy = value
		sprite.modulate.a = energy / total_energy
		if energy < 0.0:
			_destroy()


func _process(delta: float) -> void:
	# Just in case it doesn't get destroyed, to prevent lag
	if position.x < -100 or position.x > 1000 or position.y < -100 or position.y > 1000:
		_destroy()
	
	position += Vector2.from_angle(global_rotation - PI * 0.5) * speed * delta * 60.0
	
	energy -= 1.0 * delta * 60.0


func _destroy() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Bubble:
		(body as Bubble).linear_velocity += Vector2.from_angle(global_rotation - PI * 0.5) * (energy / total_energy) * push_strength
		(body as Bubble).take_damage(floori(damage_dealt * (energy / total_energy)))
		_destroy()
		return
	
	# Touched the screen edges. Bounce!
	if body.is_in_group("left_wall"):
		global_rotation = -global_rotation
		energy *= 0.5
	elif body.is_in_group("right_wall"):
		global_rotation = -global_rotation
		energy *= 0.5
	elif body.is_in_group("top_wall"):
		global_rotation = -global_rotation + PI
		energy *= 0.5
	elif body.is_in_group("bottom_wall"):
		global_rotation = -global_rotation + PI
		energy *= 0.5

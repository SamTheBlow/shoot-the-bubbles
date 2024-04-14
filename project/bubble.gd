class_name Bubble
extends RigidBody2D


signal died(bubble: Bubble)

@export var total_health: int = 100
@export var score_for_destroying: int = 1000

@export var is_boss: bool = false

var type: int = 0:
	set(value):
		type = value
		var col: Color = Color.WHITE
		match type:
			1:
				col = Game.COLOR_TYPE_1
			2:
				col = Game.COLOR_TYPE_2
			3:
				col = Game.COLOR_TYPE_3
			4:
				col = Game.COLOR_TYPE_4
		($Sprite2D as Sprite2D).modulate = col

var _health: int = 0:
	set(value):
		_health = maxi(value, 0)
		
		if get_node_or_null("HealthBar"):
			(get_node("HealthBar") as HealthBar).update_health(_health / float(total_health))
		
		if _health <= 0:
			died.emit(self)
			if get_parent():
				get_parent().remove_child(self)
			queue_free()


func _ready() -> void:
	_health = total_health
	collision_mask = collision_mask & (~1)
	if is_boss:
		freeze = true


func _process(_delta: float) -> void:
	if (not (collision_mask & 1)) and position.x > 128 + 16 and position.x < 691 - 128 - 16 and position.y > 128 + 16 and position.y < 648 - 128 - 16:
		collision_mask = collision_mask | 1


func bubble_color() -> Color:
	return ($Sprite2D as Sprite2D).modulate


func take_damage(damage: int) -> void:
	_health -= damage
	# TODO play sfx
	# TODO update visuals, red tint maybe

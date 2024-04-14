class_name Bubble
extends RigidBody2D


signal took_damage(bubble: Bubble)
signal died(bubble: Bubble)

@export var total_health: int = 100
@export var score_for_destroying: int = 1000
@export var xp_gained: int = 1

@export var is_boss: bool = false

var game: Game


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

var is_spawning: bool = true

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
	if position.x > 128 and position.x < 691 - 128 and position.y > 128 and position.y < 648 - 128:
		collision_mask = collision_mask | 1
		is_spawning = false


func bubble_color() -> Color:
	return ($Sprite2D as Sprite2D).modulate


func take_damage(multiplier: float) -> void:
	_health -= roundi(game.player_damage() * multiplier)
	took_damage.emit(self)

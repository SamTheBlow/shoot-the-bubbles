class_name Bubble
extends RigidBody2D


signal died(bubble: Bubble)

@export var total_health: int = 100
@export var score_for_destroying: int = 1000

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
		($Sprite2D as Sprite2D).modulate = col

var _health: int = 0:
	set(value):
		_health = value
		
		if _health <= 0:
			died.emit(self)
			if get_parent():
				get_parent().remove_child(self)
			queue_free()


func _ready() -> void:
	_health = total_health


func take_damage(damage: int) -> void:
	_health -= damage
	# TODO play sfx
	# TODO update visuals, red tint maybe

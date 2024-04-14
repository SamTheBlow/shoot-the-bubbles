class_name EndOfLevelUI
extends Control


signal animation_ended()

@export var animation_player: AnimationPlayer


func _ready() -> void:
	modulate.a = 0.0
	animation_player.animation_finished.connect(_on_animation_finished)


func end_of_level() -> void:
	animation_player.play("end_of_level")


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "end_of_level":
		animation_ended.emit()

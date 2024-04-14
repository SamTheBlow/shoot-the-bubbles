class_name GameOverUI
extends Control


@export var tint: ColorRect
@export var color_rekt: ColorRect
@export var label: Label
@export var button: Button
@export var animation_player: AnimationPlayer


func _ready() -> void:
	hide_ui()


func game_over() -> void:
	animation_player.play("game_over")
	button.disabled = false


func hide_ui() -> void:
	tint.color.a = 0.0
	color_rekt.modulate.a = 0.0
	label.modulate.a = 0.0
	button.modulate.a = 0.0
	button.disabled = true

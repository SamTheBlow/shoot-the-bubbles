class_name MainMenu
extends Node


signal game_started()


func _on_button_pressed() -> void:
	game_started.emit()

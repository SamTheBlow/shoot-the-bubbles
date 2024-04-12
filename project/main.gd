extends Node


@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene

var _current_scene: Node:
	set(value):
		if _current_scene:
			remove_child(_current_scene)
			_current_scene.queue_free()
		
		_current_scene = value
		add_child(_current_scene)

var _save_data := SaveData.new()


func _ready() -> void:
	_save_data.load_data()
	_enter_main_menu()


func _start_game() -> void:
	var game := game_scene.instantiate() as Game
	game.game_ended.connect(_on_game_ended)
	game.returned_to_main_menu.connect(_on_returned_to_main_menu)
	_current_scene = game


func _enter_main_menu() -> void:
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.game_started.connect(_on_game_started)
	_current_scene = main_menu


func _on_game_started() -> void:
	_start_game()


func _on_game_ended(score: int) -> void:
	_save_data.register_new_score(score)


func _on_returned_to_main_menu() -> void:
	_enter_main_menu()

class_name Game
extends Node


signal game_ended(score: int)
signal returned_to_main_menu()
signal restarted()

const COLOR_TYPE_1: Color = Color("ffb380") # orange
const COLOR_TYPE_2: Color = Color("80d4ff") # blue
const COLOR_TYPE_3: Color = Color("ff80ff") # pink
const COLOR_TYPE_4: Color = Color("aaff80") # green

@export var bubble_normal_scene: PackedScene
@export var bubble_small_scene: PackedScene
@export var bubble_large_scene: PackedScene
@export var bubble_explosion_scene: PackedScene
@export var boss_scene: PackedScene
@export var boss_explosion_scene: PackedScene

@export var bgm: AudioStreamPlayer
@export var world: Node2D
@export var player: Player
@export var spawn_timer: Timer
@export var combo_timer: Timer
@export var bubble_type_timer: Timer
@export var game_over_ui: GameOverUI
@export var end_of_level_ui: EndOfLevelUI
@export var boss_end_timer: Timer

@export var boss_name: Control
@export var hiscore_label: Label
@export var score_label: Label
@export var upgrade_1_label: Label
@export var upgrade_2_label: Label
@export var upgrade_3_label: Label
@export var combo_label: Label
@export var bar_rect: TextureRect

@export var event_list: GameEventList

var high_score: int = 0:
	set(value):
		if not _is_playing:
			return
		
		high_score = value
		
		hiscore_label.text = "HI-SCORE " + ("%09d" % high_score)

var _score: int = 0:
	set(value):
		if not _is_playing:
			return
		
		_score = value
		
		score_label.text = "SCORE " + ("%09d" % _score)
		if _score > high_score:
			high_score = _score

var _upgrade_1_xp: int = 0:
	set(value):
		_upgrade_1_xp = value
		
		var xp_needed: int
		while true:
			xp_needed = floori(3 + 2 * 1.5 ** (_upgrade_1_level - 1))
			if _upgrade_1_xp < xp_needed:
				break
			_upgrade_1_level += 1
			_upgrade_1_xp -= xp_needed
		
		if _upgrade_1_level == 10:
			upgrade_1_label.text = "Level 10 (MAX)"
		else:
			upgrade_1_label.text = "Level " + str(_upgrade_1_level) + " (" + str(_upgrade_1_xp) + "/" + str(xp_needed) + ")"

var _upgrade_1_level: int = 1:
	set(value):
		if value > 10:
			return
		
		_upgrade_1_level = value
		player.number_of_waves = 2 + _upgrade_1_level

var _upgrade_2_xp: int = 0:
	set(value):
		_upgrade_2_xp = value
		
		var xp_needed: int
		while true:
			xp_needed = floori(3 + 2 * 1.5 ** (_upgrade_2_level - 1))
			if _upgrade_2_xp < xp_needed:
				break
			_upgrade_2_level += 1
			_upgrade_2_xp -= xp_needed
		
		if _upgrade_2_level == 10:
			upgrade_2_label.text = "Level 10 (MAX)"
		else:
			upgrade_2_label.text = "Level " + str(_upgrade_2_level) + " (" + str(_upgrade_2_xp) + "/" + str(xp_needed) + ")"

var _upgrade_2_level: int = 1:
	set(value):
		if value > 10:
			return
		
		_upgrade_2_level = value
		player.damage_dealt = 10 + _upgrade_2_level * 2

var _upgrade_3_xp: int = 0:
	set(value):
		_upgrade_3_xp = value
		
		var xp_needed: int
		while true:
			xp_needed = floori(3 + 2 * 1.5 ** (_upgrade_3_level - 1))
			if _upgrade_3_xp < xp_needed:
				break
			_upgrade_3_level += 1
			_upgrade_3_xp -= xp_needed
		
		if _upgrade_3_level == 10:
			upgrade_3_label.text = "Level 10 (MAX)"
		else:
			upgrade_3_label.text = "Level " + str(_upgrade_3_level) + " (" + str(_upgrade_3_xp) + "/" + str(xp_needed) + ")"

var _upgrade_3_level: int = 1:
	set(value):
		if value > 10:
			return
		
		_upgrade_3_level = value
		player.shoot_delay_sec = 0.105 - 0.005 * _upgrade_3_level

var _combo: int = 0:
	set(value):
		if not _is_playing:
			return
		
		if value > _combo:
			combo_timer.start()
		
		_combo = value
		
		if _combo == 0:
			combo_label.text = ""
		else:
			combo_label.text = "COMBO x" + str(_combo)

var _bar_level: float = 0.5:
	set(value):
		if not _is_playing:
			return
		
		_bar_level = clampf(value, 0.0, 1.0)
		
		if _bar_level <= 0.0:
			Engine.time_scale = 1.0
			_game_over()
			return
		
		_update_bar_visuals()
		if _bar_level <= 0.5:
			Engine.time_scale = 1.0 #(_bar_level + 0.5) ** 0.5
		else:
			Engine.time_scale = (_bar_level + 0.5) ** 2.0
		
		bgm.pitch_scale = roundi(Engine.time_scale * 50.0) * 0.02

var _speed_bar_locked: bool = true

# The time between each bubble spawn
var _spawn_rate: float = 0.5

# 0: small bubbles, 1: normal bubbles
var _spawn_bubble_size: int = 1

var _is_playing: bool = true


func _ready() -> void:
	# This is to initialize the visuals
	_combo = 0
	_bar_level = 0.5
	
	player.wave_created.connect(_on_wave_created)


func _process(delta: float) -> void:
	if not _speed_bar_locked:
		if _bar_level <= 0.5:
			_bar_level -= 0.05 * delta * (_bar_level + 0.5)
		else:
			_bar_level -= 0.1 * delta * (_bar_level + 0.5)


func spawn_bubble(bubble: Bubble) -> void:
	bubble.died.connect(_on_enemy_died)
	world.add_child(bubble)


func _game_over() -> void:
	_is_playing = false
	player.is_controls_locked = true
	game_ended.emit(_score)
	game_over_ui.game_over()
	get_tree().paused = true


func _victory() -> void:
	_is_playing = false
	game_ended.emit(_score)
	end_of_level_ui.end_of_level()
	boss_end_timer.start()


func _update_bar_visuals() -> void:
	(bar_rect.texture as AtlasTexture).region.size.x = 337 * _bar_level
	bar_rect.anchor_right = _bar_level


func _start_bubble_type_timer() -> void:
	bubble_type_timer.wait_time = randf() * 10.0 + 5.0
	_spawn_bubble_size = randi() % 2
	_spawn_rate = randf() * 3.0 + 1.0
	
	# Spawn the small bubbles at a faster rate
	if _spawn_bubble_size == 0:
		_spawn_rate *= 0.5
	
	bubble_type_timer.start()


func _start_spawn_timer() -> void:
	spawn_timer.wait_time = _spawn_rate
	spawn_timer.start()


#func _apply_game_event(event: GameEvent) -> void:
	#if event is GameEventList:
		#for sub_event in (event as GameEventList).events:
			#_apply_game_event(sub_event)
		#return
	#elif event is GameEventNewEnemy:
		#var event_typed := event as GameEventNewEnemy
		#var bubble := bubble_scene.instantiate() as Bubble
		#bubble.position = event_typed.spawn_position
		#bubble.linear_velocity = (
				#Vector2.from_angle(event_typed.movement_angle_degrees)
				#* event_typed.movement_speed
		#)
		#bubble.died.connect(_on_enemy_died)
		#print("New enemy at ", bubble.position)
		#
		#world.add_child(bubble)
		#return


func _on_start_timer_timeout() -> void:
	_speed_bar_locked = false
	
	bgm.play()
	
	_start_bubble_type_timer()
	_start_spawn_timer()


func _on_spawn_timer_timeout() -> void:
	var bubble: Bubble
	if _spawn_bubble_size == 0:
		bubble = bubble_small_scene.instantiate() as Bubble
	else:
		bubble = bubble_normal_scene.instantiate() as Bubble
	bubble.position = Vector2(randf_range(64 + 64, 691 - 64 - 64), randf_range(64 + 64, 648 - 64 - 64 - 128))
	bubble.type = mini((randi() % 15) + 1, 4)
	
	spawn_bubble(bubble)
	bubble.collision_mask = bubble.collision_mask | 1
	_start_spawn_timer()


func _on_wave_created(wave: Wave) -> void:
	world.add_child(wave)


func _on_enemy_died(bubble: Bubble) -> void:
	match bubble.type:
		1:
			_upgrade_1_xp += 1
		2:
			_upgrade_2_xp += 1
		3:
			_upgrade_3_xp += 1
	_combo += 1
	_bar_level += 0.01 * (_combo ** 0.4)
	_score += roundi(bubble.score_for_destroying * (_combo ** 1.69))
	
	var bubble_explosion := bubble_explosion_scene.instantiate() as CPUParticles2D
	if bubble.is_boss:
		bubble_explosion = boss_explosion_scene.instantiate() as CPUParticles2D
	bubble_explosion.position = bubble.position
	bubble_explosion.color = bubble.bubble_color()
	world.add_child(bubble_explosion)
	
	if bubble.is_boss:
		boss_name.hide()
		_victory()


func _on_combo_timer_timeout() -> void:
	_combo = 0


func _on_bubble_type_timer_timeout() -> void:
	_start_bubble_type_timer()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	restarted.emit()


func _on_boss_start_timer_timeout() -> void:
	boss_name.show()
	var boss := boss_scene.instantiate() as Bubble
	boss.position = Vector2(400.0, -50.0)
	boss.died.connect(_on_enemy_died)
	$BossLayer.add_child(boss)


func _on_boss_end_timer_timeout() -> void:
	var bonus_score: int = 50_000_000
	_is_playing = true
	_score += bonus_score
	_is_playing = false


func _on_end_of_level_ui_animation_ended() -> void:
	returned_to_main_menu.emit()

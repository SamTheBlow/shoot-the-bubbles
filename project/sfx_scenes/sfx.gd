class_name SFX
extends AudioStreamPlayer


@export var randomize_pitch: bool = false


func _ready() -> void:
	if randomize_pitch:
		pitch_scale += randf() * 0.4


func _on_finished() -> void:
	queue_free()

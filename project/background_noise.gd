extends TextureRect


func _process(_delta: float) -> void:
	modulate.a = 0.02 * sin(Time.get_ticks_msec() * 0.003) + 0.05

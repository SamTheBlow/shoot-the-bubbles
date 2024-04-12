class_name EventTimer
extends Timer


signal event_timeout(event: GameEvent)

var event: GameEvent


func _ready() -> void:
	timeout.connect(_on_timeout)


func _on_timeout() -> void:
	event_timeout.emit(event)

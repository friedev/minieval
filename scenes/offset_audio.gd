class_name OffsetAudio
extends AudioStreamPlayer

@export var from_position: float


func _ready() -> void:
	if autoplay:
		play(from_position)

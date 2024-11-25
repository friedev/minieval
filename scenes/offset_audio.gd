class_name OffsetAudio extends AudioStreamPlayer


@export var from_position: float


func _ready() -> void:
	if self.autoplay:
		self.play(self.from_position)

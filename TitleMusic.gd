extends AudioStreamPlayer

func _ready():
	stream = load("res://Audio/Music/title_music.ogg")
	set_bus("Background music")
	play()

func play(from_position: float = 56.6):
	.play(from_position)

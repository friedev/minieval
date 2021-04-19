extends AudioStreamPlayer

func _ready():
	stream = load("res://Audio/Music/title_music.ogg")
	set_bus("Background music")
	playing = true

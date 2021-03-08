extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
	# pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var cellv = (event.position / 64).floor()
		var id = self.get_cellv(cellv)
		
		# Increment cell ID on LMB, otherwise clear cell
		var new_id = (id + 1) % 27 if event.button_index == 1 else -1
		self.set_cellv(cellv, new_id)
		
		# Initialize and play the sound for building a building.
		if event.button_index == 1:
			var building = AudioStreamPlayer.new()
			self.add_child(building)
			building.stream = load("building.wav")
			building.play()
		else:
			var building_destroy = AudioStreamPlayer.new()
			self.add_child(building_destroy)
			building_destroy.stream = load("building_destroy.wav")
			building_destroy.play()

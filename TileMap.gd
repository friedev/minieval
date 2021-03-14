extends TileMap


var selected_building = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	for x in range(0, 64):
		for y in range(0, 32):
			self.set_cell(x, y, 0)


func _unhandled_input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var cellv = (event.position / 32).floor()
		var id = self.get_cellv(cellv)
		
		# Increment cell ID on LMB, otherwise clear cell
		var new_id
		if event.button_index == 1:
			new_id = self.selected_building
		elif event.button_index == 2:
			new_id = 0
		self.set_cellv(cellv, new_id)
		
		# Initialize and play the sound for building a building.
		if event.button_index == 1:
			var building = AudioStreamPlayer.new()
			self.add_child(building)
			building.stream = load("building.wav")
			building.play()
		elif event.button_index == 2:
			var building_destroy = AudioStreamPlayer.new()
			self.add_child(building_destroy)
			building_destroy.stream = load("building_destroy.wav")
			building_destroy.play()


func _select_building(id):
	self.selected_building = id
	print(self.selected_building)

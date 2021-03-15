extends TileMap


var selected_building = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	for x in range(0, 128):
		for y in range(0, 128):
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
		else:
			return
		
		# Don't destroy empty tiles, and don't overwrite buildings
		if (id == 0) == (new_id == 0):
			return
		
		self.set_cellv(cellv, new_id)
		
		# Initialize and play the sound for building a building.
		if event.button_index == 1:
			$BuildingPlaceSound.play()
		elif event.button_index == 2:
			$BuildingDestroySound.play()


func _select_building(id):
	self.selected_building = id	

extends TileMap

signal palette_selection(id)

func _input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var cellv = ((event.position - self.global_position) / 64).floor()
		var id = self.get_cellv(cellv)
		if id != INVALID_CELL:
			emit_signal("palette_selection", id)
	

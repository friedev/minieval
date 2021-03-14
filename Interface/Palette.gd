extends TileMap

signal palette_selection(id)

func _input(event):
	# Handle mouse clicks (and not unclicks)
	var cellv
	if event is InputEventMouseButton and event.pressed:
		cellv = ((event.position - self.global_position) / 64).floor()
	elif event is InputEventKey and event.pressed:
		cellv = Vector2(event.scancode - KEY_1, 0)
	else:
		return
	var id = self.get_cellv(cellv)
	if id != INVALID_CELL:
		emit_signal("palette_selection", id)

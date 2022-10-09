extends TileMap

signal palette_selection(id)

func _input(event: InputEvent):
	# Handle mouse clicks (and not unclicks)
	var cellv: Vector2
	if event is InputEventMouseButton and event.pressed:
		cellv = ((event.position - self.global_position) / 64).floor()
	elif event is InputEventKey and event.pressed:
		if event.scancode == KEY_0:
			cellv = Vector2(9, 0)
		else:
			cellv = Vector2(event.scancode - KEY_1, 0)
	else:
		return
	var id := self.get_cellv(cellv)
	if id != INVALID_CELL:
		# Hack to map nice road icon (21) to actual road ID (2)
		if id == 21:
			id = 2
		emit_signal("palette_selection", id)

extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(0, 64):
		for y in range(0, 32):
			self.set_cell(x, y, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var cellv = (event.position / 32).floor()
		var id = self.get_cellv(cellv)
		# Increment cell ID on LMB, otherwise clear cell
		var new_id = (id + 1) % 16 if event.button_index == 1 else 0
		self.set_cellv(cellv, new_id)

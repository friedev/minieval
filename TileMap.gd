extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
	# Sample cell initialization
	#for x in range(0, 15):
	#	for y in range(0, 8):
	#		self.set_cell(x, y, (x + y) % 27)


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

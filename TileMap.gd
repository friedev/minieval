extends TileMap


class Building:
	var cost
	var radius
	var interactions
	
	func _init(cost, radius, interactions):
		self.cost = cost
		self.radius = radius
		self.interactions = interactions


var buildings = [
	null,
	Building.new(1, 1, { # 1: Wooden hut
		1: 1,  # Wooden hut
		2: 2,  # Wooden house
		3: -1, # Stone hut
		4: -2, # Stone house
		5: 1,  # Castle
	}),
	Building.new(2, 1, {  # 2: Wooden house
		1: 2,  # Wooden hut
		2: 4,  # Wooden house
		3: -2, # Stone hut
		4: -4, # Stone house
		5: 1,  # Castle
	}),
	Building.new(3, 2, {  # 3: Stone hut
		1: -1, # Wooden hut
		2: -2, # Wooden house
		3: 1,  # Stone hut
		4: 2,  # Stone house
		5: 2,  # Castle
	}),
	Building.new(4, 2, { # 4: Stone house
		1: -2, # Wooden hut
		2: -4, # Wooden house
		3: 2,  # Stone hut
		4: 4,  # Stone house
		5: 2,  # Castle
	}),
	Building.new(10, 10, {  # 5: Castle
		1: 1,   # Wooden hut
		2: 1,   # Wooden house
		3: 2,   # Stone hut
		4: 2,   # Stone house
		5: -10, # Castle
		6: 5,   # Tower
	}),
	Building.new(5, 5, {  # 6: Tower
		5: 5,  # Castle
		6: -5, # Tower
	}),
	null, # 7: Wall
	Building.new(5, 5, {  # 8: Fountain
		1: 1, # Wooden hut
		2: 1, # Wooden house
		3: 1, # Stone hut
		4: 1, # Stone house
	}),
	Building.new(5, 5, {  # 9: Well
		1: 2,  # Wooden hut
		2: 2,  # Wooden house
		3: -2, # Stone hut
		4: -2, # Stone house
	}),
]


var currency = 10
var selected_building = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	get_node(@"/root/Root/CurrencyLayer/CurrencyLabel").text = "Currency: %d" % currency
	for x in range(0, 128):
		for y in range(0, 128):
			self.set_cell(x, y, 0)

func _unhandled_input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var cellv = (event.position / 32 + get_node(@"/root/Root/Camera2D").position / 8).floor()
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
		
		if new_id != 0:
			var building = buildings[new_id]
			if currency >= building.cost:
				currency -= building.cost
			else:
				return # Play error sound

			# Give currency based on nearby buildings
			for x in range(max(0, cellv.x - building.radius), min(127, cellv.x + building.radius + 1)):
				for y in range(max(0, cellv.y - building.radius), min(127, cellv.y + building.radius + 1)):
					var neighbor_id = self.get_cell(x, y)
					var currency_change = building.interactions.get(neighbor_id, 0)
					currency += currency_change

			get_node(@"/root/Root/CurrencyLayer/CurrencyLabel").text = "Currency: %d" % currency

			$BuildingPlaceSound.play()
		else:
			$BuildingDestroySound.play()
		
		self.set_cellv(cellv, new_id)

func _select_building(id):
	self.selected_building = id

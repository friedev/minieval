extends TileMap


class Building:
	var base_cost
	var cost
	var cost_increment
	var base_vp
	var vp
	var vp_increment
	var radius
	var currency_interactions
	var vp_interactions
	
	func _init(base_cost, cost_increment, base_vp, vp_increment, radius, currency_interactions, vp_interactions):
		self.base_cost = base_cost
		self.cost = base_cost
		self.cost_increment = cost_increment
		self.base_vp = base_vp
		self.vp = base_vp
		self.vp_increment = vp_increment
		self.radius = radius
		self.currency_interactions = currency_interactions
		self.vp_interactions = vp_interactions


var buildings = [
	null,
	Building.new(1, 0.25, 1, 0, 1, { # 1: Wooden hut
		1: 1,  # Wooden hut
		2: 2,  # Wooden house
		3: -1, # Stone hut
		4: -2, # Stone house
		5: 1,  # Castle
	}, {
	}),
	Building.new(2, 0.5, 1, 0, 1, {  # 2: Wooden house
		1: 2,  # Wooden hut
		2: 4,  # Wooden house
		3: -2, # Stone hut
		4: -4, # Stone house
		5: 1,  # Castle
	}, {
	}),
	Building.new(3, 0.25, 2, 0, 2, {  # 3: Stone hut
		1: -1, # Wooden hut
		2: -2, # Wooden house
		3: 1,  # Stone hut
		4: 2,  # Stone house
		5: 2,  # Castle
	}, {
	}),
	Building.new(4, 0.5, 2, 0, 2, { # 4: Stone house
		1: -2, # Wooden hut
		2: -4, # Wooden house
		3: 2,  # Stone hut
		4: 4,  # Stone house
		5: 2,  # Castle
	}, {
	}),
	Building.new(10, 10, 10, 0, 10, {  # 5: Castle
		1: 1,   # Wooden hut
		2: 1,   # Wooden house
		3: 2,   # Stone hut
		4: 2,   # Stone house
		5: -10, # Castle
		6: 5,   # Tower
	}, {
	}),
	Building.new(5, 5, 5, 0, 5, {  # 6: Tower
		5: 5,  # Castle
		6: -5, # Tower
	}, {
	}),
	null, # 7: Wall
	Building.new(5, 2.5, 2, 0, 5, {  # 8: Fountain
		1: 1, # Wooden hut
		2: 1, # Wooden house
		3: 1, # Stone hut
		4: 1, # Stone house
	}, {
	}),
	Building.new(5, 2.5, 2, 0, 5, {  # 9: Well
		1: 2,  # Wooden hut
		2: 2,  # Wooden house
		3: -2, # Stone hut
		4: -2, # Stone house
	}, {
	}),
]


class Placement:
	var id
	var cellv
	var placed # True if building was placed, false if it was destroyed
	
	func _init(id, cellv, placed):
		self.id = id
		self.cellv = cellv
		self.placed = placed


var currency = 10
var vp = 0
var selected_building = 1

var label_format = "Currency: %d\nVictory Points: %d"

var history = []
var future = []


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	get_node(@"/root/Root/CurrencyLayer/CurrencyLabel").text = label_format % [currency, vp]
	for x in range(0, 128):
		for y in range(0, 128):
			self.set_cell(x, y, 0)


func _unhandled_input(event):
	# Handle mouse clicks (and not unclicks)
	if event is InputEventMouseButton and event.pressed:
		var camera = get_node(@"/root/Root/Camera2D")
		var cellv = ((event.position * camera.zoom + camera.position) / 8).floor() # 8 = tile size
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
			if currency >= floor(building.cost):
				currency -= floor(building.cost)
			else:
				return # Play error sound
			
			vp += floor(building.vp)
			
			# Give currency based on nearby buildings
			# TODO prevent currency from going negative if net currency change is negative
			for x in range(max(0, cellv.x - building.radius), min(127, cellv.x + building.radius + 1)):
				for y in range(max(0, cellv.y - building.radius), min(127, cellv.y + building.radius + 1)):
					var neighbor_id = self.get_cell(x, y)
					currency += building.currency_interactions.get(neighbor_id, 0)
					vp += building.vp_interactions.get(neighbor_id, 0)
			
			building.cost += building.cost_increment
			building.vp += building.vp_increment
			
			history.append(Placement.new(new_id, cellv, true))
			future.clear()
			
			get_node(@"/root/Root/CurrencyLayer/CurrencyLabel").text = label_format % [currency, vp]
			
			$BuildingPlaceSound.play()
		else:
			var building = buildings[id]
			building.cost -= building.cost_increment
			building.vp -= building.vp_increment
			
			history.append(Placement.new(id, cellv, false))
			future.clear()
			
			$BuildingDestroySound.play()
		
		self.set_cellv(cellv, new_id)
	elif event is InputEventKey and event.pressed:
		# TODO generalize to place_building and destroy_building methods
		# TODO currency, vp, and building increment changes
		if event.scancode == KEY_U or event.scancode == KEY_Z:
			var prev_placement = history.pop_back()
			if prev_placement:
				if prev_placement.placed:
					self.set_cellv(prev_placement.cellv, 0)
				else:
					self.set_cellv(prev_placement.cellv, prev_placement.id)
				future.append(prev_placement)
		elif event.scancode == KEY_R or event.scancode == KEY_Y:
			var next_placement = future.pop_back()
			if next_placement:
				if next_placement.placed:
					self.set_cellv(next_placement.cellv, next_placement.id)
				else:
					self.set_cellv(next_placement.cellv, 0)
				history.append(next_placement)


func _select_building(id):
	self.selected_building = id

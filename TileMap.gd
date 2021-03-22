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
	var currency_change
	var vp_change
	
	func _init(id, cellv, placed, currency_change, vp_change):
		self.id = id
		self.cellv = cellv
		self.placed = placed
		self.currency_change = currency_change
		self.vp_change = vp_change


var currency = 10
var vp = 0
var selected_building = 1

var label_format = "Currency: %d\nVictory Points: %d"

var history = []
var future = []
var mouse_cellv = null
var preview_cellv = null


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	mouse_cellv = position_to_cellv(get_viewport().get_mouse_position())
	self._update_label()
	for x in range(0, 128):
		for y in range(0, 128):
			self.set_cell(x, y, 0)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_cellv = self.position_to_cellv(event.position)
	elif event is InputEventMouseButton and event.pressed:
		self._clear_preview()
		
		# Increment cell ID on LMB, otherwise clear cell
		var placement
		if event.button_index == 1:
			placement = self.place_building(mouse_cellv, self.selected_building)
		elif event.button_index == 2:
			placement = self.destroy_building(mouse_cellv)
		else:
			return
		
		if placement:
			currency += placement.currency_change
			vp += placement.vp_change
			history.append(placement)
			future.clear()
			self._update_label()
		else:
			pass # Play error sound
	elif event is InputEventKey and event.pressed:
		if event.scancode == KEY_U or event.scancode == KEY_Z: # Undo
			var prev_placement = history.pop_back()
			if prev_placement:
				if prev_placement.placed:
					self.destroy_building(prev_placement.cellv)
				else:
					self.place_building(prev_placement.cellv, prev_placement.id)
				currency -= prev_placement.currency_change
				vp -= prev_placement.vp_change
				future.append(prev_placement)
				self._update_label()
		elif event.scancode == KEY_R or event.scancode == KEY_Y: # Redo
			var next_placement = future.pop_back()
			if next_placement:
				if next_placement.placed:
					self.place_building(next_placement.cellv, next_placement.id)
				else:
					self.destroy_building(next_placement.cellv)
				currency += next_placement.currency_change
				vp += next_placement.vp_change
				history.append(next_placement)
				self._update_label()
	
	self._update_preview()


# Event handler for the palette
func _select_building(id):
	self.selected_building = id


func _update_label():
	get_node(@"/root/Root/CurrencyLayer/CurrencyLabel").text = label_format % [currency, vp]


func _clear_preview():
	if preview_cellv != null:
		self.set_cellv(preview_cellv, 0)
		$Preview.set_cellv(preview_cellv, INVALID_CELL)
		preview_cellv = null


func _update_preview():
	self._clear_preview()
	var id = self.get_cellv(mouse_cellv)
	if id == 0:
		preview_cellv = mouse_cellv
		self.set_cellv(preview_cellv, INVALID_CELL)
		$Preview.set_cellv(preview_cellv, self.selected_building)
		

func position_to_cellv(position):
	var camera = get_node(@"/root/Root/Camera2D")
	return ((position * camera.zoom + camera.position) / 8).floor() # 8 = tile size


func place_building(cellv, id):
	if self.get_cellv(cellv) != 0:
		$BuildingPlaceErrorSound.play()
		return null
	
	var building = buildings[id]
	var currency_change = -floor(building.cost)
	var vp_change = floor(building.vp)
	# Check if building can be built in the first place
	if currency + currency_change < 0:
		$BuildingPlaceErrorSound.play()
		return null
	
	# Give currency based on nearby buildings
	# TODO prevent currency from going negative if net currency change is negative
	for x in range(max(0, cellv.x - building.radius), min(127, cellv.x + building.radius + 1)):
		for y in range(max(0, cellv.y - building.radius), min(127, cellv.y + building.radius + 1)):
			var neighbor_id = self.get_cell(x, y)
			currency_change += building.currency_interactions.get(neighbor_id, 0)
			vp_change += building.vp_interactions.get(neighbor_id, 0)
	
	# Check if the additional cost from interactions would lead to negative currency
	if currency + currency_change < 0:
		return null
	
	building.cost += building.cost_increment
	building.vp += building.vp_increment
	
	$BuildingPlaceSound.play()
	
	self.set_cellv(cellv, id)
	return Placement.new(id, cellv, true, currency_change, vp_change)


func destroy_building(cellv):
	var id = self.get_cellv(cellv)
	if id == 0:
		$BuildingPlaceErrorSound.play()
		return null
	
	var building = buildings[id]
	building.cost -= building.cost_increment
	building.vp -= building.vp_increment
	
	$BuildingDestroySound.play()
	
	self.set_cellv(cellv, 0)
	return Placement.new(id, cellv, false, 0, 0)

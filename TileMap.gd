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
var buildings_placed = 0 # TODO fix undo behavior

onready var currency_label = get_node(@"/root/Root/UITextLayer/CurrencyLabel")
const currency_format = "Currency: %d\nVictory Points: %d"
onready var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
const turn_format = "%d Turns Left"

const game_length = 50
var history = []
var future = []

onready var camera = get_node(@"/root/Root/Camera2D")
onready var preview_label = get_node(@"/root/Root/PreviewLayer/PreviewLabel")
var mouse_cellv = null
var preview_cellv = null
var show_preview = true


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection", self, "_select_building")
	self._update_mouse_cellv()
	self._update_labels()
	for x in range(0, 128):
		for y in range(0, 128):
			self.set_cell(x, y, 0)


func _process(delta):
	if show_preview:
		self._update_preview()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
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
			self._update_labels()
			if get_turns_remaining() == 0:
				pass # TODO show score recap scene
		else:
			$BuildingPlaceErrorSound.play()
	elif event.is_action_pressed("undo"):
		var prev_placement = history.pop_back()
		if prev_placement:
			if prev_placement.placed:
				self.destroy_building(prev_placement.cellv)
			else:
				self.place_building(prev_placement.cellv, prev_placement.id)
			currency -= prev_placement.currency_change
			vp -= prev_placement.vp_change
			future.append(prev_placement)
			self._update_labels()
	elif event.is_action_pressed("redo"):
		var next_placement = future.pop_back()
		if next_placement:
			if next_placement.placed:
				self.place_building(next_placement.cellv, next_placement.id)
			else:
				self.destroy_building(next_placement.cellv)
			currency += next_placement.currency_change
			vp += next_placement.vp_change
			history.append(next_placement)
			self._update_labels()
	elif event.is_action_pressed("score_report"):
		show_preview = false
		self._clear_preview()
	elif event.is_action_released("score_report"):
		show_preview = true


# Event handler for the palette
func _select_building(id):
	self.selected_building = id


func get_turn():
	return len(history)


func get_turns_remaining():
	return game_length - get_turn()


func _update_labels():
	currency_label.text = currency_format % [currency, vp]
	turn_label.text = turn_format % get_turns_remaining()


func _update_mouse_cellv():
	mouse_cellv = position_to_cellv(get_viewport().get_mouse_position())


func _clear_preview():
	if preview_cellv != null:
		self.set_cellv(preview_cellv, 0)
		preview_cellv = null
		$Preview.clear()
		preview_label.text = ''


func _update_preview():
	# Only update the preview if the mouse has moved to a different cell
	var old_mouse_cellv = mouse_cellv
	self._update_mouse_cellv()
	if mouse_cellv == old_mouse_cellv:
		return
	
	self._clear_preview()
	
	# Only show a preview if a building is not already present
	var id = self.get_cellv(mouse_cellv)
	if id != 0:
		return
	
	preview_cellv = mouse_cellv
	
	# For loops show radius of current building with a 50% opacity white square
	var radius = buildings[selected_building].radius
	for x in range(max(0, preview_cellv.x - radius), min(127, preview_cellv.x + radius + 1)):
		for y in range(max(0, preview_cellv.y - radius), min(127, preview_cellv.y + radius + 1)):
			var neighbor_id = Vector2(x, y)
			$Preview.set_cellv(neighbor_id,7)
	
	# Preview selected building using the actual tilemap
	self.set_cellv(preview_cellv, self.selected_building)
	
	# Update preview label with expected building value
	var value = get_building_value(preview_cellv, self.selected_building)
	preview_label.text = "%d, %d" % value
	preview_label.rect_position = cellv_to_position(preview_cellv) + \
			Vector2(4, -2) / camera.zoom - preview_label.rect_size / 2


func position_to_cellv(position):
	return ((position * camera.zoom + camera.position) / 8).floor() # 8 = tile size


func cellv_to_position(cellv):
	return (8 * cellv - camera.position) / camera.zoom # 8 = tile size


# Gets the total value that would result from placing the building with the
# given ID at the given cellv, returned in the form [currency, vp]
# Includes the building's flat cost and VP, as well as interactions
func get_building_value(cellv, id):
	var building = buildings[id]
	var radius = building.radius
	var currency_value = -floor(building.cost)
	var vp_value = floor(building.vp)
	for x in range(max(0, cellv.x - radius), min(127, cellv.x + radius + 1)):
		for y in range(max(0, cellv.y - radius), min(127, cellv.y + radius + 1)):
			# Ignore the exact cell where the building is being placed
			if not (x == cellv.x and y == cellv.y):
				var neighbor_id = self.get_cell(x, y)
				currency_value += building.currency_interactions.get(neighbor_id, 0)
				vp_value += building.vp_interactions.get(neighbor_id, 0)
	return [currency_value, vp_value]


func place_building(cellv, id):
	if self.get_cellv(cellv) != 0:
		return null
	
	var building = buildings[id]
	
	# Check if building can be built in the first place
	if currency - floor(building.cost) < 0:
		return null
	
	# Give currency based on nearby buildings
	var building_value = get_building_value(cellv, id)
	var currency_change = building_value[0]
	var vp_change = building_value[1]
	
	# Check if the additional cost from interactions would lead to negative currency
	if currency + currency_change < 0:
		return null
	
	building.cost += building.cost_increment
	building.vp += building.vp_increment
	
	$BuildingPlaceSound.play()
	
	# TODO Prevent buildings placed from going to infinity if you place, undo, re-place etc.
	buildings_placed += 1
	
	self.set_cellv(cellv, id)
	return Placement.new(id, cellv, true, currency_change, vp_change)


func destroy_building(cellv):
	var id = self.get_cellv(cellv)
	if id <= 0:
		return null
	
	var building = buildings[id]
	building.cost -= building.cost_increment
	building.vp -= building.vp_increment
	
	$BuildingDestroySound.play()
	
	self.set_cellv(cellv, 0)
	return Placement.new(id, cellv, false, 0, 0)

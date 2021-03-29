extends TileMap


class Building:
	var is_tile: bool
	var base_cost: int
	var cost: float
	var cost_increment: float
	var base_vp: int
	var vp: float
	var vp_increment: float
	var area: Vector2
	var texture: Texture
	var cells: Array
	var currency_interactions: Dictionary
	var vp_interactions: Dictionary
	
	func _init(is_tile: bool,
			base_cost: int,
			cost_increment: float,
			base_vp: int,
			vp_increment: float,
			area: Vector2,
			texture: Texture,
			cells: Array,
			currency_interactions: Dictionary,
			vp_interactions: Dictionary):
		self.is_tile = is_tile
		self.base_cost = base_cost
		self.cost = base_cost
		self.cost_increment = cost_increment
		self.base_vp = base_vp
		self.vp = base_vp
		self.vp_increment = vp_increment
		self.area = area
		self.texture = texture
		self.cells = cells
		self.currency_interactions = currency_interactions
		self.vp_interactions = vp_interactions
	
	func get_size():
		return Vector2(get_width(), get_height())
	
	func get_width():
		return len(self.cells[0])
	
	func get_height():
		return len(self.cells)
	
	func get_cells(cellv = Vector2(0, 0)):
		var cells = []
		for x in range(0, len(self.cells)):
			for y in range(0, len(self.cells[x])):
				if self.cells[x][y]:
					cells.append(Vector2(x, y) + cellv)
					# TODO prevent placing buildings partially out of bounds
		return cells
	
	func get_area_cells(cellv = Vector2(0, 0)):
		var area_cells = []
		var offset = (get_size() / 2).floor()
		var radius = (area / 2)
		for x in range(max(0, cellv.x - floor(radius.x) + offset.x),
				min(128, cellv.x + ceil(radius.x) + offset.x)):
			for y in range(max(0, cellv.y - floor(radius.y) + offset.y),
					min(128, cellv.y + ceil(radius.y) + offset.y)):
						area_cells.append(Vector2(x, y))
		return area_cells


var BUILDINGS = [
	null,
	# 1: Wooden hut
	Building.new(false, 1, 0.25, 1, 0, Vector2(3, 3),
			preload("res://Art/house.png"), [
				[1],
			], {
				1: 1,  # Wooden hut
				2: 2,  # Wooden house
				3: -1, # Stone hut
				4: -2, # Stone house
				5: 1,  # Castle
			}, {
			}),
	# 2: Wooden house
	Building.new(false, 2, 0.5, 1, 0, Vector2(4, 3),
			preload("res://Art/shop.png"), [
				[1, 1],
			], {
				1: 2,  # Wooden hut
				2: 4,  # Wooden house
				3: -2, # Stone hut
				4: -4, # Stone house
				5: 1,  # Castle
			}, {
			}),
	# 3: Stone hut
	Building.new(false, 3, 0.25, 2, 0, Vector2(4, 4),
			preload("res://Art/big_house.png"), [
				[1, 1],
				[1, 0],
			], {
				1: -1, # Wooden hut
				2: -2, # Wooden house
				3: 1,  # Stone hut
				4: 2,  # Stone house
				5: 2,  # Castle
			}, {
			}),
	# 4: Stone house
	Building.new(false, 4, 0.5, 2, 0, Vector2(4, 4),
			preload("res://Art/forge.png"), [
				[1, 1],
				[1, 1],
			], {
				1: -2, # Wooden hut
				2: -4, # Wooden house
				3: 2,  # Stone hut
				4: 4,  # Stone house
				5: 2,  # Castle
			}, {
			}),
	# 5: Castle
	Building.new(false, 10, 10, 10, 0, Vector2(5, 5),
			preload("res://Art/field.png"), [
				[1, 1, 1],
				[1, 1, 1],
				[1, 1, 1],
			], {
				1: 1,   # Wooden hut
				2: 1,   # Wooden house
				3: 2,   # Stone hut
				4: 2,   # Stone house
				5: -10, # Castle
				6: 5,   # Tower
			}, {
			}),
	# 6: Tower
	Building.new(false, 5, 5, 5, 0, Vector2(6, 5),
			preload("res://Art/cathedral.png"), [
				[0, 1, 0, 0],
				[1, 1, 1, 1],
				[0, 1, 0, 0],
			], {
				5: 5,  # Castle
				6: -5, # Tower
			}, {
			}),
	# 7: White square
	Building.new(false, 5, 5, 5, 0, Vector2(8, 7),
			preload("res://Art/keep.png"), [
				[1, 1, 1],
				[1, 1, 1],
				[1, 1, 1],
				[1, 1, 1],
			], {
				5: 5,  # Castle
				6: -5, # Tower
			}, {
			}),
	# 8: Fountain
	Building.new(false, 5, 2.5, 2, 0, Vector2(7, 5),
			preload("res://Art/tower.png"), [
				[1],
				[1],
				[1],
			], {
				1: 1, # Wooden hut
				2: 1, # Wooden house
				3: 1, # Stone hut
				4: 1, # Stone house
			}, {
			}),
	# 9: Well
	Building.new(false, 5, 2.5, 2, 0, Vector2(16, 12),
			preload("res://Art/pyramid.png"), [
				[0, 0, 0, 1, 1, 0, 0, 0],
				[0, 0, 1, 1, 1, 1, 0, 0],
				[0, 1, 1, 1, 1, 1, 1, 0],
				[1, 1, 1, 1, 1, 1, 1, 1],
			], {
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


const TILE_SIZE = 8
const BASE_BUILDING_INDEX = 9 # First non-special index: -1 = INVALID, 0 = EMPTY

var world_map = []
var building_types = []
var building_roots = []
var building_index = BASE_BUILDING_INDEX

var building_scene = preload("res://Building.tscn")

var currency = 10
var vp = 0
var selected_building = 1
var buildings_placed = 0 # TODO fix undo behavior

onready var currency_label = get_node(@"/root/Root/UITextLayer/CurrencyLabel")
const currency_format = "%d\n%d"
onready var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
const turn_format = "%d Turns Left"

const game_length = 50
var history = []
var future = []

onready var camera = get_node(@"/root/Root/Camera2D")
onready var preview_label = get_node(@"/root/Root/PreviewLayer/PreviewNode/PreviewLabel")
onready var preview_building = get_node(@"/root/Root/TileMap/PreviewBuilding")
var mouse_cellv = null
var preview_cellv = null
var show_preview = true


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection",
			self, "_select_building")
	self._update_mouse_cellv()
	self._update_labels()
	for x in range(0, 128):
		world_map.append([])
		for y in range(0, 128):
			world_map[x].append(0)
			.set_cell(x, y, 0)
	for i in range(BASE_BUILDING_INDEX):
		building_types.append(null)
		building_roots.append(null)
	_select_building(1)


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
	elif event is InputEventKey and event.scancode == KEY_B:
		# Manually break for debugging
		breakpoint


func get_cell(x: int, y: int):
	if x < 0 or x >= len(world_map) or y < 0 or y >= len(world_map[x]):
		return INVALID_CELL
	var cell = world_map[x][y]
	return cell


func get_cellv(position: Vector2):
	return get_cell(position.x, position.y)


func set_cell(x: int, y: int, tile: int, flip_x: bool = false,
		flip_y: bool = false, transpose: bool = false,
		autotile_coord: Vector2 = Vector2( 0, 0 )):
	if x < 0 or x >= len(world_map) or y < 0 or y >= len(world_map[x]):
		push_error('Tried to set a cell out of bounds')
	if tile < 0 and tile >= len(BUILDINGS) and tile != INVALID_CELL:
		push_error('Tried to place an invalid building type')
	var cellv = Vector2(x, y)
	var building = BUILDINGS[tile]
	if building and not building.is_tile:
		# TODO move to place_building or other helper method
		for building_cellv in building.get_cells(cellv):
			world_map[building_cellv.x][building_cellv.y] = building_index
		building_types.append(tile)
		building_roots.append(cellv)
		building_index += 1
	else:
		world_map[x][y] = tile
		.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)


func set_cellv(position: Vector2, tile: int, flip_x: bool = false,
		flip_y: bool = false, transpose: bool = false,
		autotile_coord: Vector2 = Vector2( 0, 0 )):
	set_cell(position.x, position.y, tile, flip_x, flip_y, transpose,
			autotile_coord)


func get_type(id):
	if id < BASE_BUILDING_INDEX:
		return id
	return building_types[id]


# Event handler for the palette
func _select_building(id):
	self.selected_building = id
	var building = BUILDINGS[id]
	if not building.is_tile:
		$PreviewBuilding.texture = building.texture
	_clear_preview()
	_update_preview()


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
		#self.set_cellv(preview_cellv, 0)
		preview_cellv = null
		$Preview.clear()
		$PreviewTile.clear()
		$PreviewBuilding.visible = false
		preview_label.text = ''


func _update_preview():
	# Only update the preview if the mouse has moved to a different cell
	self._update_mouse_cellv()
	if mouse_cellv == preview_cellv:
		return
	
	self._clear_preview()
	preview_cellv = mouse_cellv
	var building = BUILDINGS[selected_building]
	
	# Move the building preview
	if building.is_tile:
		$PreviewTile.set_cellv(preview_cellv, selected_building)
	else:
		$PreviewBuilding.position = cellv_to_world_position(preview_cellv)
		$PreviewBuilding.visible = true
	
	# Shade preview building in red if the placement is blocked
	if building.is_tile:
		$PreviewTile.modulate = Color.white
		if self.get_cellv(preview_cellv) != 0:
			$PreviewTile.modulate = Color.red
	else:
		$PreviewBuilding.modulate = Color.white
		for cellv in building.get_cells(preview_cellv):
			if self.get_cellv(cellv) != 0:
				$PreviewBuilding.modulate = Color.red
	
	# Show area of current building with a 50% opacity white square
	for cellv in building.get_area_cells(preview_cellv):
		$Preview.set_cellv(cellv, 7)
	
	# Update preview label with expected building value
	var value = get_building_value(preview_cellv, self.selected_building)
	preview_label.text = "%d, %d" % value
	preview_label.rect_position = cellv_to_screen_position(preview_cellv) + \
			Vector2(4, -2) / camera.zoom - preview_label.rect_size / 2


func position_to_cellv(position):
	return ((position * camera.zoom + camera.position) / TILE_SIZE).floor()


func cellv_to_world_position(cellv):
	return cellv * TILE_SIZE


func cellv_to_screen_position(cellv):
	return (cellv_to_world_position(cellv) - camera.position) / camera.zoom


# Gets the total value that would result from placing the building with the
# given ID at the given cellv, returned in the form [currency, vp]
# Includes the building's flat cost and VP, as well as interactions
func get_building_value(cellv, id):
	var building = BUILDINGS[id]
	var currency_value = -floor(building.cost)
	var vp_value = floor(building.vp)
	var counted_ids = []
	var occupied_cells = building.get_cells(cellv)
	for area_cellv in building.get_area_cells(cellv):
		# Ignore the exact cells where the building is being placed
		if occupied_cells.has(area_cellv):
			continue
		
		var neighbor_id = self.get_cellv(area_cellv)
		if counted_ids.has(neighbor_id):
			continue
		counted_ids.append(neighbor_id)
		
		var neighbor_type = get_type(neighbor_id)
		currency_value += building.currency_interactions.get(neighbor_type, 0)
		vp_value += building.vp_interactions.get(neighbor_type, 0)
	return [currency_value, vp_value]


func place_building(cellv, id):
	var building = BUILDINGS[id]
	
	# Prevent placement f building overlaps any existing buildings
	for building_cellv in building.get_cells(cellv):
		if get_type(self.get_cellv(building_cellv)) != 0:
			return null
	
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
	
	var instance = building_scene.instance()
	instance.position = cellv_to_world_position(cellv)
	instance.texture = building.texture
	instance.set_name("building_%d" % building_index)
	$Buildings.add_child(instance)
	self.set_cellv(cellv, id)
	return Placement.new(id, cellv, true, currency_change, vp_change)


func destroy_building(cellv):
	var id = self.get_cellv(cellv)
	if get_type(id) <= 0:
		return null
	
	var type = id
	if id >= BASE_BUILDING_INDEX:
		var instance = get_node(NodePath("Buildings/building_%d" % id))
		if instance and not instance.is_queued_for_deletion():
			instance.free()
		type = building_types[id]
	var building = BUILDINGS[type]
	building.cost -= building.cost_increment
	building.vp -= building.vp_increment
	
	$BuildingDestroySound.play()

	buildings_placed -= 1
	
	var root = cellv
	if id >= BASE_BUILDING_INDEX:
		root = building_roots[id]
		for building_cellv in building.get_cells(root):
			self.set_cellv(building_cellv, 0)
	else:
		self.set_cellv(cellv, 0)
	return Placement.new(type, root, false, 0, 0)

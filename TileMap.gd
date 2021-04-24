extends TileMap


class Building:
	var is_tile: bool
	var groupable: bool
	var cost: int
	var vp: int
	var area: Vector2
	var texture: Texture
	var cells: Array
	var currency_interactions: Dictionary
	var vp_interactions: Dictionary
	
	
	func _init(is_tile: bool,
			groupable: bool,
			cost: int,
			vp: int,
			area: Vector2,
			texture: Texture,
			cells: Array,
			currency_interactions: Dictionary,
			vp_interactions: Dictionary):
		self.is_tile = is_tile
		self.groupable = groupable
		self.cost = cost
		self.vp = vp
		self.area = area
		self.texture = texture
		self.cells = cells
		self.currency_interactions = currency_interactions
		self.vp_interactions = vp_interactions
	
	
	func get_size():
		return Vector2(get_width(), get_height())
	
	
	func get_cell_offset():
		return (get_size() / 2).ceil() - Vector2(1, 1)
	
	
	func get_area_offset():
		return (get_size() / 2).floor()
	
	
	func get_width():
		return len(self.cells[0])
	
	
	func get_height():
		return len(self.cells)
	
	
	# Returns a list of all cell vectors orthogonally adjacent to the given cell
	# Duplicated from outer scope
	static func get_orthogonal(cellv):
		var orthogonal = []
		if cellv.x > 0:
			orthogonal.append(Vector2(cellv.x - 1, cellv.y))
		if cellv.x < Global.game_size:
			orthogonal.append(Vector2(cellv.x + 1, cellv.y))
		if cellv.y > 0:
			orthogonal.append(Vector2(cellv.x, cellv.y - 1))
		if cellv.y < Global.game_size:
			orthogonal.append(Vector2(cellv.x, cellv.y + 1))
		return orthogonal
	
	
	static func get_cells_in_radius(cellv, radius = Vector2(1.5, 1.5)):
		if radius is int:
			radius = Vector2(radius, radius)
		var cells = []
		for x in range(max(0, cellv.x - floor(radius.x)),
				min(Global.game_size, cellv.x + ceil(radius.x))):
			for y in range(max(0, cellv.y - floor(radius.y)),
					min(Global.game_size, cellv.y + ceil(radius.y))):
						cells.append(Vector2(x, y))
		return cells
	
	
	func get_cells(cellv = Vector2(0, 0)):
		var cells = []
		for y in range(0, len(self.cells)):
			for x in range(0, len(self.cells[y])):
				if self.cells[y][x]:
					cells.append(Vector2(x, y) + cellv)
					# TODO prevent placing buildings partially out of bounds
		return cells
	
	
	func get_area_cells(cellv = Vector2(0, 0)):
		return get_cells_in_radius(cellv + get_area_offset(), area / 2)
	
	
	func get_adjacent_cells(cellv = Vector2(0, 0)):
		var adjacent_cell_map = []
		for y in range(0, len(self.cells) + 2):
			adjacent_cell_map.append([])
			for x in range(0, len(self.cells[0]) + 2):
				adjacent_cell_map[y].append(0)
		for building_cellv in get_cells(Vector2(1, 1)):
			adjacent_cell_map[building_cellv.y][building_cellv.x] = 2
			for adjacent_cellv in get_orthogonal(building_cellv):
				adjacent_cell_map[adjacent_cellv.y][adjacent_cellv.x] = max(1,
						adjacent_cell_map[adjacent_cellv.y][adjacent_cellv.x])
		var adjacent_cells = []
		for y in range(0, len(adjacent_cell_map)):
			for x in range(0, len(adjacent_cell_map[y])):
				if adjacent_cell_map[y][x] == 1:
					adjacent_cells.append(Vector2(x - 1, y - 1) + cellv)
		return adjacent_cells


var BUILDINGS = [
	null, # 0: Empty
	null, # 1: Selection box
	# 2: Road
	Building.new(true, true, 1, 0, Vector2(0, 0), null, [
				[1],
			], {
			}, {
			}),
	null, # 3: Unused
	null, # 4: Unused
	null, # 5: Unused
	null, # 6: Unused
	null, # 7: Unused
	null, # 8: Unused
	null, # 9: Unused
	null, # 10: Unused
	# 11: House
	Building.new(false, false, 1, 1, Vector2(3, 3),
			preload("res://Art/house.png"), [
				[1],
			], {
				12: 2, # Shop
			}, {
				15: 2, # Statue
			}),
	# 12: Shop
	Building.new(false, false, 5, 1, Vector2(6, 5),
			preload("res://Art/shop2.png"), [
				[1, 1],
			], {
				11: 1,  # House
				12: -5, # Shop
				13: 2,  # Big house
				14: 2,  # Forge
			}, {
				16: -5, # Cathedral
			}),
	# 13: Big house
	Building.new(false, false, 5, 2, Vector2(4, 4),
			preload("res://Art/big_house.png"), [
				[1, 1],
				[1, 0],
			], {
				12: 4, # Shop
			}, {
				15: 4, # Statue
			}),
	# 14: Forge
	Building.new(false, false, 10, 2, Vector2(6, 6),
			preload("res://Art/forge.png"), [
				[1, 1],
				[1, 1],
			], {
				12: 2,  # Shop
				14: -5, # Forge
			}, {
				16: -5, # Cathedral
				17: 5,  # Keep
			}),
	# 15: Statue
	Building.new(false, false, 5, 5, Vector2(5, 6),
			preload("res://Art/statue.png"), [
				[1],
				[1],
			], {
			}, {
				11: 1,  # House
				13: 2,  # Big house
				15: -5, # Statue
				16: 10, # Cathedral
			}),
	# 16: Cathedral
	Building.new(false, false, 40, 20, Vector2(8, 7),
			preload("res://Art/cathedral3.png"), [
				[0, 1, 0, 0],
				[1, 1, 1, 1],
				[0, 1, 0, 0],
			], {
				14: 10,  # Forge
				16: -20, # Cathedral
			}, {
				12: -5,  # Shop
				14: -5,  # Forge
				15: 10,  # Statue
				16: -20, # Cathedral
			}),
	# 17: Keep
	Building.new(false, false, 80, 20, Vector2(9, 8),
			preload("res://Art/keep.png"), [
				[1, 1, 1],
				[1, 1, 1],
				[1, 1, 1],
				[1, 1, 1],
			], {
				14: 10,  # Forge
				17: -40, # Keep
			}, {
				14: 10,  # Forge
				17: -20, # Keep
				18: 20,  # Tower
			}),
	# 18: Tower
	Building.new(false, false, 20, 0, Vector2(5, 5),
			preload("res://Art/tower.png"), [
				[1],
				[1],
				[1],
			], {
				14: 5, # Forge
			}, {
				17: 20,  # Keep
				18: -10, # Tower
			}),
	# 19: Pyramid
	Building.new(false, false, 150, 50, Vector2(16, 12),
			preload("res://Art/pyramid.png"), [
				[0, 0, 0, 1, 1, 0, 0, 0],
				[0, 0, 1, 1, 1, 1, 0, 0],
				[0, 1, 1, 1, 1, 1, 1, 0],
				[1, 1, 1, 1, 1, 1, 1, 1],
			], {
				11: -5,
				12: -5,
				13: -5,
				14: -5,
				15: -5,
				16: -5,
				17: -5,
				18: -5,
				19: -5,
			}, {
				11: 5,
				12: 5,
				13: 5,
				14: 5,
				15: 5,
				16: 5,
				17: 5,
				18: 5,
				19: 5,
			}),
]


class Placement:
	var id: int
	var cellv: Vector2
	var currency_change: int
	var vp_change: int
	var group_joins: Array
	
	
	func _init(id: int,
			cellv: Vector2,
			currency_change: int,
			vp_change: int,
			group_joins: Array):
		self.id = id
		self.cellv = cellv
		self.currency_change = currency_change
		self.vp_change = vp_change
		self.group_joins = group_joins


const TILE_SIZE = 8
const BASE_BUILDING_INDEX = 20 # First unused index
const BASE_GROUP_INDEX = 1
const DEFAULT_BUILDING = 2
var CREATIVE_MODE = false
var ALLOW_DESTROYING = false

# 2D array of building IDs; 0 is empty, and all tile buildings share the same ID
var world_map = []
# 1D array mapping a building ID (the index into this array) to its type (an
# index in the BUILDINGS array)
# Content starts at BASE_BUILDING_INDEX, everything before that is null
var building_types = []
# 1D array mapping a building ID (the index into this array) to its root
# position (a cell vector)
var building_roots = []
# 2D array of group IDs; 0 is no group
var groups = []
# 1D array mapping a group (the index into this array) to the group it has been
# merged into (another group)
# A group that has not been merged will map to its own index
# Recursively indexing into this array will get you to the "base group"
var group_joins = []
# 2D array mapping a group to a 1D array of building IDs adjacent to the group
var adjacent_buildings = []
var building_index = BASE_BUILDING_INDEX
var group_index = BASE_GROUP_INDEX

var building_scene = preload("res://Building.tscn")

var currency = 10
var vp = 0
var selected_building = DEFAULT_BUILDING
var buildings_placed = 0

onready var ui_text_layer = get_node(@"/root/Root/UITextLayer")
onready var currency_label = get_node(@"/root/Root/UITextLayer/CurrencyLabel")
var currency_format = "%d\n%d"
onready var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
const turn_format = "%d Turns Left"
onready var timer = get_node(@"/root/Root/UITextLayer/Timer/timeLeftLabel")

var game_length = Global.num_turns
var history = []
var future = []

onready var camera = get_node(@"/root/Root/Camera2D")
onready var preview_label = get_node(@"/root/Root/PreviewLayer/PreviewNode/PreviewLabel")
onready var preview_node = get_node(@"/root/Root/PreviewLayer/PreviewNode")
onready var preview_building = get_node(@"/root/Root/TileMap/PreviewBuilding")
var mouse_cellv = null
var preview_cellv = null
var show_preview = true
const PREVIEW_COLOR = Color.white
const PREVIEW_COLOR_INVALID = Color(1, 0.25, 0.25, 0.5)
const PREVIEW_COLOR_GOOD = Color(0.25, 1, 0.25, 1)
const PREVIEW_COLOR_MIXED = Color(1, 1, 0.25, 1)
const PREVIEW_COLOR_BAD = Color(1, 0.25, 0.25, 1)
var modulated_buildings = []


# Called when the node enters the scene tree for the first time.
func _ready():
	TitleMusic.playing = false
	#enable turn based
	if Global.game_mode == 0:
		turn_label.visible = true
		timer.visible = false
	#enable time based
	elif Global.game_mode == 1:
		turn_label.visible = false
		timer.visible = true
	#enable freeplay
	elif Global.game_mode == 2:
		turn_label.visible = false
		timer.visible = false
	elif Global.game_mode == 3:
		turn_label.visible = false
		timer.visible = false
		CREATIVE_MODE = true
		ALLOW_DESTROYING = true
		
		# Hide UIs in creative mode
		# TODO extract to method to reduce redundancy
		# Same code duplicated in StatsOverlayUIScript.gd
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = false
	
	# Change the selected building when a building is clicked on the palette
	get_node(@"/root/Root/Palette/Menu/TileMap").connect("palette_selection",
			self, "_select_building")
	
	self._update_mouse_cellv()
	self._update_labels()
	
	for x in range(0, Global.game_size):
		world_map.append([])
		groups.append([])
		for y in range(0, Global.game_size):
			world_map[x].append(0)
			groups[x].append(0)
			.set_cell(x, y, 0)
	
	camera.position = cellv_to_world_position(Vector2(Global.game_size / 2,
			Global.game_size / 2)) - camera.offset
	
	for i in range(BASE_BUILDING_INDEX):
		building_types.append(null)
		building_roots.append(null)
	
	for i in range(BASE_GROUP_INDEX):
		groups.append(null)
		group_joins.append(null)
		adjacent_buildings.append(null)
	
	_select_building(DEFAULT_BUILDING)


func _process(delta):
	if show_preview:
		self._update_preview()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		self._clear_preview()
		
		var building = BUILDINGS[self.selected_building]
		var placement
		if event.button_index == 1:
			placement = self.place_building(
					mouse_cellv - building.get_cell_offset(),
					self.selected_building,
					CREATIVE_MODE)
		elif ALLOW_DESTROYING and event.button_index == 2:
			placement = self.destroy_building(mouse_cellv)
		else:
			return
		
		if placement:
			currency += placement.currency_change
			vp += placement.vp_change
			history.append(placement)
			future.clear()
			self._update_labels()
		else:
			$BuildingPlaceErrorSound.play()
	elif event.is_action_pressed("undo"):
		self._clear_preview()
		var prev_placement = history.pop_back()
		if prev_placement:
			self.destroy_building(prev_placement.cellv, prev_placement.id)
			currency -= prev_placement.currency_change
			vp -= prev_placement.vp_change
			for join in prev_placement.group_joins:
				group_joins[join] = join
			future.append(prev_placement)
			self._update_labels()
	elif event.is_action_pressed("redo"):
		self._clear_preview()
		var next_placement = future.pop_back()
		if next_placement:
			self.place_building(next_placement.cellv, next_placement.id, true)
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


# Overridden from TileMap
# Returns the building ID at the given position instead of the tile ID
func get_cell(x: int, y: int):
	if x < 0 or x >= len(world_map) or y < 0 or y >= len(world_map[x]):
		return INVALID_CELL
	return world_map[x][y]


# Overridden from TileMap
func get_cellv(position: Vector2):
	return get_cell(position.x, position.y)


# Overridden from TileMap
# Updates world map, building types, and building roots where applicable
# Does NOT spawn a building sprite, update groups, or fully clean up destroyed
# buildings
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
			# Hide the empty tiles behind the building by setting them to invalid
			.set_cellv(building_cellv, INVALID_CELL)
		building_types.append(tile)
		building_roots.append(cellv)
		building_index += 1
	else:
		world_map[x][y] = tile
		.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
		update_bitmask_area(cellv)


# Overridden from TileMap
func set_cellv(position: Vector2, tile: int, flip_x: bool = false,
		flip_y: bool = false, transpose: bool = false,
		autotile_coord: Vector2 = Vector2( 0, 0 )):
	set_cell(position.x, position.y, tile, flip_x, flip_y, transpose,
			autotile_coord)


# Helper function to get a building's type (an index into the BUILDINGS array)
# from its ID
func get_type(id):
	if id < BASE_BUILDING_INDEX:
		return id
	return building_types[id]


func get_group(cellv):
	if cellv.x < 0 or cellv.x >= len(world_map) or \
			cellv.y < 0 or cellv.y >= len(world_map[cellv.x]):
		return INVALID_CELL
	return groups[cellv.x][cellv.y]


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_base_group(group):
	if group < BASE_GROUP_INDEX or group >= len(groups):
		return INVALID_CELL
	var join = group_joins[group]
	while join != group:
		group = join
		join = group_joins[group]
	return group


# Returns a list of all cell vectors orthogonally adjacent to the given cell
func get_orthogonal(cellv):
	var orthogonal = []
	if cellv.x > 0:
		orthogonal.append(Vector2(cellv.x - 1, cellv.y))
	if cellv.x < Global.game_size:
		orthogonal.append(Vector2(cellv.x + 1, cellv.y))
	if cellv.y > 0:
		orthogonal.append(Vector2(cellv.x, cellv.y - 1))
	if cellv.y < Global.game_size:
		orthogonal.append(Vector2(cellv.x, cellv.y + 1))
	return orthogonal


# Returns a list of all building IDs adjacent to a group, starting at given tile
# Uses a recursive depth-first search
func get_adjacent_buildings(cellv, adjacent = [], visited = []):
	var group = get_base_group(get_group(cellv))
	if group < BASE_GROUP_INDEX:
		return
	visited.append(cellv)
	for adjacent_cellv in get_orthogonal(cellv):
		var adjacent_group = get_base_group(get_group(adjacent_cellv))
		if adjacent_group == group:
			if not visited.has(adjacent_cellv):
				adjacent = get_adjacent_buildings(adjacent_cellv, adjacent, visited)
		else:
			var adjacent_id = get_cellv(adjacent_cellv)
			if adjacent_id >= BASE_BUILDING_INDEX:
				var adjacent_building = BUILDINGS[get_type(adjacent_id)]
				if not adjacent_building.is_tile and \
						not adjacent.has(adjacent_id):
					adjacent.append(adjacent_id)
	return adjacent


# Event handler for palette selections
func _select_building(id):
	var building = BUILDINGS[id]
	if not building:
		return
	self.selected_building = id
	if not building.is_tile:
		$PreviewBuilding.texture = building.texture
	_clear_preview()
	_update_preview()


func get_turn():
	return len(history)


func get_turns_remaining():
	return game_length - get_turn()


# May be a redundant implementation of TileMap's world_to_map function
func position_to_cellv(position):
	return ((position * camera.zoom + camera.position) / TILE_SIZE).floor()


func cellv_to_world_position(cellv):
	return cellv * TILE_SIZE


func cellv_to_screen_position(cellv):
	return (cellv_to_world_position(cellv) - camera.position) / camera.zoom


func get_building_sprite(id):
	return get_node(NodePath("Buildings/building_%d" % id))


# Updates the currency label and turn label
func _update_labels():
	# Don't update anything if in creative mode
	if not CREATIVE_MODE:
		currency_label.text = currency_format % [currency, vp]
		var turns_remaining = get_turns_remaining()
		if turns_remaining > 0:
			turn_label.text = turn_format % turns_remaining
		else:
			turn_label.text = ""


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
		preview_node.visible = false
		for modulated_building in modulated_buildings:
			var sprite = get_building_sprite(modulated_building)
			if sprite != null and not sprite.is_queued_for_deletion():
				sprite.modulate = Color.white
		modulated_buildings.clear()

func _update_preview():
	# Only update the preview if the mouse has moved to a different cell
	self._update_mouse_cellv()
	if mouse_cellv == preview_cellv:
		return
	
	self._clear_preview()
	# Don't show cost information in creative mode
	preview_node.visible = not CREATIVE_MODE
	preview_cellv = mouse_cellv
	var building = BUILDINGS[selected_building]
	var building_cellv = preview_cellv - building.get_cell_offset()
	
	# Move the building preview
	$PreviewBuilding.position = cellv_to_world_position(building_cellv)
	if building.is_tile:
		$PreviewTile.set_cellv(building_cellv, selected_building)
	else:
		$PreviewBuilding.visible = true
	
	# Shade preview building in red if the placement is blocked
	if building.is_tile:
		$PreviewTile.modulate = PREVIEW_COLOR
		if self.get_cellv(building_cellv) != 0:
			$PreviewTile.modulate = PREVIEW_COLOR_INVALID
	else:
		$PreviewBuilding.modulate = PREVIEW_COLOR
		for cellv in building.get_cells(building_cellv):
			if self.get_cellv(cellv) != 0:
				$PreviewBuilding.modulate = PREVIEW_COLOR_INVALID
				break
	
	if CREATIVE_MODE:
		return
	
	# Show area of current building with a 50% opacity white square
	for cellv in building.get_area_cells(building_cellv):
		$Preview.set_cellv(cellv, 1)
		var area_building = get_cellv(cellv)
		if area_building > 0:
			var area_building_type = get_type(area_building)
			var area_building_sprite = get_building_sprite(area_building)
			var currency_interaction = building.currency_interactions.get(area_building_type, 0)
			var vp_interaction = building.vp_interactions.get(area_building_type, 0)
			var modulation = null
			if (currency_interaction > 0 and vp_interaction >= 0) or \
					(currency_interaction >= 0 and vp_interaction > 0):
						modulation = PREVIEW_COLOR_GOOD
			elif (currency_interaction < 0 and vp_interaction <= 0) or \
					(currency_interaction <= 0 and vp_interaction < 0):
						modulation = PREVIEW_COLOR_BAD
			elif (currency_interaction < 0 and vp_interaction > 0) or \
					(currency_interaction > 0 and vp_interaction < 0):
						modulation = PREVIEW_COLOR_MIXED
			if modulation:
				area_building_sprite.modulate = modulation
				modulated_buildings.append(area_building)
	
	# Update preview label with expected building value
	var value = get_building_value(building_cellv, self.selected_building)
	preview_label.text = "%s\n%s" % format_value(value)
	preview_node.rect_position = \
			cellv_to_screen_position(Vector2(preview_cellv.x, building_cellv.y)) + \
			Vector2((1.0 / camera.zoom.x * 4) + 15, -35)


# Gets the total value that would result from placing the building with the
# given ID at the given cellv, returned in the form [currency, vp]
# Includes the building's flat cost and VP, as well as interactions
func get_building_value(cellv, id):
	var building = BUILDINGS[id]
	var currency_value = -building.cost
	var vp_value = building.vp
	var counted_ids = []
	var occupied_cells = building.get_cells(cellv)
	
	# Account for nearby buildings
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
	
	# Account for buildings connected via road
	var counted_groups = []
	for adjacent_cellv in building.get_adjacent_cells(cellv):
		var adjacent_group = get_base_group(get_group(adjacent_cellv))
		if adjacent_group >= BASE_GROUP_INDEX and not counted_groups.has(adjacent_group):
			counted_groups.append(adjacent_group)
			for adjacent_building in adjacent_buildings[adjacent_group]:
				if not counted_ids.has(adjacent_building):
					# Only add currency value
					counted_ids.append(adjacent_building)
					var adjacent_type = get_type(adjacent_building)
					currency_value += building.currency_interactions.get(adjacent_type, 0)
	
	return [floor(currency_value), floor(vp_value)]


func format_value(value):
	return [('+%d' if value[0] > 0 else '%d') % value[0],
			('+%d' if value[1] > 0 else '%d') % value[1]]

func place_building(cellv, id, force = false):
	var building = BUILDINGS[id]
	
	# Prevent placement if building overlaps any existing buildings
	for building_cellv in building.get_cells(cellv):
		if get_type(self.get_cellv(building_cellv)) != 0:
			return null
	
	# Check if building can be built in the first place
	#if currency - floor(building.cost) < 0:
	#	return null
	
	# Give currency based on nearby buildings
	var building_value = get_building_value(cellv, id)
	var currency_change = building_value[0]
	var vp_change = building_value[1]
	
	# Check if the additional cost from interactions would lead to negative currency
	if currency + currency_change < 0 and not force:
		return null
	
	$BuildingPlaceSound.play()
	
	buildings_placed += 1
	
	var neighbor_groups = []
	if building.groupable:
		for neighbor in get_orthogonal(cellv):
			var neighbor_type = get_type(get_cellv(neighbor))
			if neighbor_type == id:
				neighbor_groups.append(get_base_group(get_group(neighbor)))
		var x = cellv.x
		var y = cellv.y
		# If no neighboring groups exist, make a new group
		if len(neighbor_groups) == 0:
			groups[x][y] = group_index
			group_joins.append(group_index)
			adjacent_buildings.append([])
			group_index += 1
		# If there's exactly one neighboring group, use that
		elif len(neighbor_groups) == 1:
			groups[x][y] = neighbor_groups[0]
		# If this tile bridges more than one group, join them all
		else:
			var joined_group = neighbor_groups.min()
			for group in neighbor_groups:
				group_joins[group] = joined_group
			groups[x][y] = joined_group
		
		# Update the list of buildings adjacent to the group
		adjacent_buildings[groups[x][y]] = get_adjacent_buildings(cellv)
	else:
		# Update all adjacency lists to include this building
		var adjacent_groups = []
		for adjacent_cellv in building.get_adjacent_cells(cellv):
			var group = get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_groups.append(group)
				adjacent_buildings[group].append(building_index)
	
	# Instance a new sprite if this building is not a tile
	if not building.is_tile:
		var instance = building_scene.instance()
		instance.position = cellv_to_world_position(cellv)
		instance.texture = building.texture
		instance.set_name("building_%d" % building_index)
		$Buildings.add_child(instance)
	
	self.set_cellv(cellv, id)
	return Placement.new(id, cellv, currency_change, vp_change, neighbor_groups)


func destroy_building(cellv, id = null):
	# If an ID is given, use it to offset the cellv, ensuring that we won't
	# select part of the building with empty space
	# DON'T supply an ID if the cellv is already a tile the building occupies
	# Use it deletion where you only know the root cellv
	# There may be an edge case for a building with an empty center (e.g. a 3x3
	# donut-shaped building)
	if id:
		cellv += BUILDINGS[get_type(id)].get_cell_offset()
	id = self.get_cellv(cellv)
	if id <= 0:
		return null
	
	var is_tile = id < BASE_BUILDING_INDEX
	
	var type = id
	if not is_tile:
		# If this isn't a tile building, free its sprite
		var instance = get_building_sprite(id)
		if instance and not instance.is_queued_for_deletion():
			instance.free()
		type = building_types[id]
	var building = BUILDINGS[type]
	
	$BuildingDestroySound.play()

	buildings_placed -= 1
	
	var root = cellv
	if is_tile:
		self.set_cellv(cellv, 0)
		groups[cellv.x][cellv.y] = 0

		var adjacent_groups = []
		for adjacent_cellv in get_orthogonal(cellv):
			var group = get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_buildings[group] = get_adjacent_buildings(adjacent_cellv)
	else:
		# Reset all cells (in the world map and groups) occupied by this building
		# Does NOT modify the group_joins array; currently handled by the undo code
		root = building_roots[id]
		for building_cellv in building.get_cells(root):
			self.set_cellv(building_cellv, 0)
			groups[building_cellv.x][building_cellv.y] = 0
		
		var adjacent_groups = []
		for adjacent_cellv in building.get_adjacent_cells(root):
			var group = get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_buildings[group].erase(id)

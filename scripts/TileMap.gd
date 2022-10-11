extends TileMap


class Building:
	var name: String
	var is_tile: bool
	var groupable: bool
	var gp: int
	var vp: int
	var area: Vector2
	var texture: Texture
	var cells: Array
	var gp_interactions: Dictionary
	var vp_interactions: Dictionary

	func _init(
		name: String,
		is_tile: bool,
		groupable: bool,
		gp: int,
		vp: int,
		area: Vector2,
		texture: Texture,
		cells: Array,
		gp_interactions: Dictionary,
		vp_interactions: Dictionary
	):
		self.name = name
		self.is_tile = is_tile
		self.groupable = groupable
		self.gp = gp
		self.vp = vp
		self.area = area
		self.texture = texture
		self.cells = cells
		self.gp_interactions = gp_interactions
		self.vp_interactions = vp_interactions

	func get_size() -> Vector2:
		return Vector2(get_width(), get_height())

	func get_cell_offset() -> Vector2:
		return (get_size() / 2).ceil() - Vector2(1, 1)

	func get_area_offset() -> Vector2:
		return (get_size() / 2).floor()

	func get_width() -> int:
		return len(self.cells[0])

	func get_height() -> int:
		return len(self.cells)

	# Returns a list of all cell vectors orthogonally adjacent to the given cell
	# Duplicated from outer scope
	static func get_orthogonal(cellv: Vector2) -> Array:
		var orthogonal := []
		if cellv.x > 0:
			orthogonal.append(Vector2(cellv.x - 1, cellv.y))
		if cellv.x < Global.game_size:
			orthogonal.append(Vector2(cellv.x + 1, cellv.y))
		if cellv.y > 0:
			orthogonal.append(Vector2(cellv.x, cellv.y - 1))
		if cellv.y < Global.game_size:
			orthogonal.append(Vector2(cellv.x, cellv.y + 1))
		return orthogonal

	static func get_cells_in_radius(
		cellv: Vector2,
		radius = Vector2(1.5, 1.5)
	) -> Array:
		if radius is int:
			radius = Vector2(radius, radius)
		var cells := []
		for x in range(max(0, cellv.x - floor(radius.x)),
				min(Global.game_size, cellv.x + ceil(radius.x))):
			for y in range(max(0, cellv.y - floor(radius.y)),
					min(Global.game_size, cellv.y + ceil(radius.y))):
						cells.append(Vector2(x, y))
		return cells

	func get_cells(cellv := Vector2(0, 0)) -> Array:
		var cells := []
		for y in range(0, len(self.cells)):
			for x in range(0, len(self.cells[y])):
				if self.cells[y][x]:
					cells.append(Vector2(x, y) + cellv)
					# TODO prevent placing buildings partially out of bounds
		return cells

	func get_area_cells(cellv := Vector2(0, 0)) -> Array:
		return get_cells_in_radius(cellv + get_area_offset(), area / 2)

	func get_adjacent_cells(cellv := Vector2(0, 0)) -> Array:
		var adjacent_cell_map := []
		for y in range(0, len(self.cells) + 2):
			adjacent_cell_map.append([])
			for x in range(0, len(self.cells[0]) + 2):
				adjacent_cell_map[y].append(0)
		for building_cellv in get_cells(Vector2(1, 1)):
			adjacent_cell_map[building_cellv.y][building_cellv.x] = 2
			for adjacent_cellv in get_orthogonal(building_cellv):
				adjacent_cell_map[adjacent_cellv.y][adjacent_cellv.x] = max(1,
						adjacent_cell_map[adjacent_cellv.y][adjacent_cellv.x])
		var adjacent_cells := []
		for y in range(0, len(adjacent_cell_map)):
			for x in range(0, len(adjacent_cell_map[y])):
				if adjacent_cell_map[y][x] == 1:
					adjacent_cells.append(Vector2(x - 1, y - 1) + cellv)
		return adjacent_cells


enum {
	EMPTY = 0,
	SELECTION = 1,
	ROAD = 2,
	HOUSE = 11,
	SHOP = 12,
	MANSION = 13,
	FORGE = 14,
	STATUE = 15,
	CATHEDRAL = 16,
	KEEP = 17,
	TOWER = 18,
	PYRAMID = 19,
}


var BUILDINGS := {
	EMPTY: null,
	ROAD: Building.new(
		"Road", # name
		true, # is_tile
		true, # groupable
		-1, # gp
		0, # vp
		Vector2(0, 0), # area
		null, # texture
		[ # cells
			[1],
		],
		{}, # gp_interactions
		{} # vp_interactions
	),
	HOUSE: Building.new(
		"House", # name
		false, # is_tile
		false, # groupable
		-1, # gp
		1, # vp
		Vector2(3, 3), # area
		preload("res://sprites/house.png"), # texture
		[ # cells
			[1],
		],
		{ # gp_interactions
			SHOP: 2,
		},
		{ # vp_interactions
			STATUE: 2,
		}
	),
	SHOP: Building.new(
		"Shop", # name
		false, # is_tile
		false, # groupable
		-5, # gp
		1, # vp
		Vector2(6, 5), # area
		preload("res://sprites/shop.png"), # texture
		[ # cells
			[1, 1],
		],
		{ # gp_interactions
			HOUSE: 1,
			SHOP: -5,
			MANSION: 2,
			FORGE: 3,
		},
		{ # vp_interactions
			CATHEDRAL: -5,
		}
	),
	MANSION: Building.new(
		"Mansion", # name
		false, # is_tile
		false, # groupable
		-5, # gp
		2, # vp
		Vector2(4, 4), # area
		preload("res://sprites/mansion.png"), # texture
		[
			[1, 1],
			[1, 0],
		], {
			SHOP: 4,
			MANSION: -2,
		}, {
			STATUE: 4,
		}
	),
	FORGE: Building.new(
		"Forge", # name
		false, # is_tile
		false, # groupable
		-10, # gp
		2, # vp
		Vector2(6, 6), # area
		preload("res://sprites/forge.png"), # texture
		[ # cells
			[1, 1],
			[1, 1],
		],
		{ # gp_interactions
			SHOP: 3,
			FORGE: -5,
		},
		{ # vp_interactions
			CATHEDRAL: -5,
			KEEP: 5,
		}
	),
	STATUE: Building.new(
		"Statue", # name
		false, # is_tile
		false, # groupable
		-5, # gp
		5, # vp
		Vector2(5, 6), # area
		preload("res://sprites/statue.png"), # texture
		[ # cells
			[1],
			[1],
		],
		{}, # gp_interactions
		{ # vp_interactions
			HOUSE: 1,
			MANSION: 2,
			STATUE: -5,
			CATHEDRAL: 5,
		}
	),
	CATHEDRAL: Building.new(
		"Cathedral", # name
		false, # is_tile
		false, # groupable
		-40, # gp
		20, # vp
		Vector2(8, 7), # area,
		preload("res://sprites/cathedral.png"), # texture
		[ # cells
			[0, 1, 0, 0],
			[1, 1, 1, 1],
			[0, 1, 0, 0],
		],
		{ # gp_interactions
			FORGE: 10,  # Forge
			CATHEDRAL: -20, # Cathedral
		},
		{ # vp_interactions
			SHOP: -10,
			FORGE: -10,
			STATUE: 10,
			CATHEDRAL: -20,
		}
	),
	KEEP: Building.new(
		"Keep", # name
		false, # is_tile
		false, # groupable
		-80, # gp
		20, # vp
		Vector2(9, 8), # area
		preload("res://sprites/keep.png"), # sprite
		[ # cells
			[1, 1, 1],
			[1, 1, 1],
			[1, 1, 1],
			[1, 1, 1],
		],
		{ # gp_interactions
			FORGE: 10,
			KEEP: -40,
		},
		{ # vp_interactions
			FORGE: 10,
			KEEP: -20,
			TOWER: 20,
		}
	),
	TOWER: Building.new(
		"Tower", # name
		false, # is_tile
		false, # groupable
		-20, # gp
		0, # vp
		Vector2(5, 5), # area
		preload("res://sprites/tower.png"), # texture
		[ # cells
			[1],
			[1],
			[1],
		],
		{ # gp_interactions
			FORGE: 5,
		},
		{ # vp_interactions
			KEEP: 20,
			TOWER: -10,
		}
	),
	PYRAMID: Building.new(
		"Pyramid", # name
		false, # is_tile
		false, # groupable
		-150, # gp
		50, # vp
		Vector2(16, 12), # area
		preload("res://sprites/pyramid.png"), # texture
		[ # cells
			[0, 0, 0, 1, 1, 0, 0, 0],
			[0, 0, 1, 1, 1, 1, 0, 0],
			[0, 1, 1, 1, 1, 1, 1, 0],
			[1, 1, 1, 1, 1, 1, 1, 1],
		],
		{ # gp_interactions
			HOUSE: -5,
			SHOP: -5,
			MANSION: -5,
			FORGE: -5,
			STATUE: -5,
			CATHEDRAL: -5,
			KEEP: -5,
			TOWER: -5,
			PYRAMID: -5,
		},
		{ # vp_interactions
			HOUSE: 5,
			SHOP: 5,
			MANSION: 5,
			FORGE: 5,
			STATUE: 5,
			CATHEDRAL: 5,
			KEEP: 5,
			TOWER: 5,
			PYRAMID: 5,
		}
	),
}


class Placement:
	var id: int
	var cellv: Vector2
	var gp_change: int
	var vp_change: int
	var group_joins: Array

	func _init(
		id: int,
		cellv: Vector2,
		gp_change: int,
		vp_change: int,
		group_joins: Array
	):
		self.id = id
		self.cellv = cellv
		self.gp_change = gp_change
		self.vp_change = vp_change
		self.group_joins = group_joins


const TILE_SIZE := 8
const BASE_BUILDING_INDEX := 20 # First unused index
const BASE_GROUP_INDEX := 1
const DEFAULT_BUILDING := 11

# 2D array of building IDs; 0 is empty, and all tile buildings share the same ID
var world_map := []
# 1D array mapping a building ID (the index into this array) to its type (an
# index in the BUILDINGS array)
# Content starts at BASE_BUILDING_INDEX, everything before that is null
var building_types := []
# 1D array mapping a building ID (the index into this array) to its root
# position (a cell vector)
var building_roots := []
# 2D array of group IDs; 0 is no group
var groups := []
# 1D array mapping a group (the index into this array) to the group it has been
# merged into (another group)
# A group that has not been merged will map to its own index
# Recursively indexing into this array will get you to the "base group"
var group_joins := []
# 2D array mapping a group to a 1D array of building IDs adjacent to the group
var adjacent_buildings := []
var building_index := BASE_BUILDING_INDEX
var group_index := BASE_GROUP_INDEX

var building_scene := preload("res://scenes/Building.tscn")

var gp := 25
var vp := 0
var selected_building := DEFAULT_BUILDING

onready var ui_text_layer := get_node(@"/root/Root/UITextLayer")
onready var gp_label := get_node(@"/root/Root/UITextLayer/GPLabel")
onready var vp_label := get_node(@"/root/Root/UITextLayer/VPLabel")
onready var turn_label := get_node(@"/root/Root/UITextLayer/TurnLabel")
const turn_format := "%d Turns Left"

var game_length: int = Global.num_turns
var history := []
var future := []

onready var camera := get_node(@"/root/Root/Camera2D")
onready var preview_label := get_node(@"/root/Root/PreviewLayer/PreviewNode/PreviewLabel")
onready var preview_node := get_node(@"/root/Root/PreviewLayer/PreviewNode")
onready var preview_building := get_node(@"/root/Root/TileMap/PreviewBuilding")
var mouse_cellv = null
var preview_cellv = null
var show_preview := true
const PREVIEW_COLOR := Color.white
const PREVIEW_COLOR_INVALID := Color(1, 0.25, 0.25, 0.5)
const PREVIEW_COLOR_GOOD := Color(0.25, 1, 0.25, 1)
const PREVIEW_COLOR_MIXED := Color(1, 1, 0.25, 1)
const PREVIEW_COLOR_BAD := Color(1, 0.25, 0.25, 1)
var modulated_buildings := []


func _ready():
	TitleMusic.playing = false
	turn_label.visible = not Global.endless

	# Change the selected building when a building is clicked on the palette
	get_node(@"/root/Root/Palette/Menu/TileMap").connect(
		"palette_selection",
		self,
		"_select_building"
	)

	self._update_mouse_cellv()
	self._update_labels()

	for x in range(0, Global.game_size):
		world_map.append([])
		groups.append([])
		for y in range(0, Global.game_size):
			world_map[x].append(0)
			groups[x].append(0)
			.set_cell(x, y, 0)

	camera.position = cellv_to_world_position(
		Vector2(Global.game_size / 2, Global.game_size / 2)
	) - camera.offset

	for i in range(BASE_BUILDING_INDEX):
		building_types.append(null)
		building_roots.append(null)

	for i in range(BASE_GROUP_INDEX):
		groups.append(null)
		group_joins.append(null)
		adjacent_buildings.append(null)

	_select_building(DEFAULT_BUILDING)


func _process(delta: float):
	if show_preview:
		self._update_preview()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		self._clear_preview()

		var building: Building = BUILDINGS[self.selected_building]
		var placement: Placement
		if event.button_index == 1:
			placement = self.place_building(
				mouse_cellv - building.get_cell_offset(),
				self.selected_building,
				false
			)

			if placement:
				gp += placement.gp_change
				vp += placement.vp_change
				history.append(placement)
				future.clear()
				self._update_labels()
			else:
				$BuildingPlaceErrorSound.play()
	elif event.is_action_pressed("undo"):
		self._clear_preview()
		var prev_placement: Placement = history.pop_back()
		if prev_placement:
			self.destroy_building(prev_placement.cellv, prev_placement.id)
			gp -= prev_placement.gp_change
			vp -= prev_placement.vp_change
			for join in prev_placement.group_joins:
				group_joins[join] = join
			future.append(prev_placement)
			self._update_labels()
	elif event.is_action_pressed("redo"):
		self._clear_preview()
		var next_placement: Placement = future.pop_back()
		if next_placement:
			self.place_building(next_placement.cellv, next_placement.id, true)
			gp += next_placement.gp_change
			vp += next_placement.vp_change
			history.append(next_placement)
			self._update_labels()
	#elif event is InputEventKey and event.scancode == KEY_B:
	#	# Manually break for debugging
	#	breakpoint


# Overridden from TileMap
# Returns the building ID at the given position instead of the tile ID
func get_cell(x: int, y: int) -> int:
	if x < 0 or x >= len(world_map) or y < 0 or y >= len(world_map[x]):
		return INVALID_CELL
	return world_map[x][y]


# Overridden from TileMap
func get_cellv(position: Vector2) -> int:
	return get_cell(position.x, position.y)


# Overridden from TileMap
# Updates world map, building types, and building roots where applicable
# Does NOT spawn a building sprite, update groups, or fully clean up destroyed
# buildings
func set_cell(
	x: int,
	y: int,
	tile: int,
	flip_x: bool = false,
	flip_y: bool = false,
	transpose: bool = false,
	autotile_coord: Vector2 = Vector2(0, 0)
) -> void:
	if x < 0 or x >= len(world_map) or y < 0 or y >= len(world_map[x]):
		push_error('Tried to set a cell out of bounds')
	if tile < 0 and tile >= len(BUILDINGS) and tile != INVALID_CELL:
		push_error('Tried to place an invalid building type')
	var cellv := Vector2(x, y)
	var building: Building = BUILDINGS[tile]
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
func set_cellv(
	position: Vector2,
	tile: int,
	flip_x: bool = false,
	flip_y: bool = false,
	transpose: bool = false,
	autotile_coord: Vector2 = Vector2(0, 0)
) -> void:
	set_cell(
		position.x,
		position.y,
		tile,
		flip_x,
		flip_y,
		transpose,
		autotile_coord
	)


# Helper function to get a building's type (an index into the BUILDINGS array)
# from its ID
func get_type(id: int) -> int:
	if id < BASE_BUILDING_INDEX:
		return id
	return building_types[id]


func get_group(cellv: Vector2) -> int:
	if (
		cellv.x < 0 or cellv.x >= len(world_map)
		or cellv.y < 0 or cellv.y >= len(world_map[cellv.x])
	):
		return INVALID_CELL
	return groups[cellv.x][cellv.y]


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_base_group(group: int) -> int:
	if group < BASE_GROUP_INDEX or group >= len(groups):
		return INVALID_CELL
	var join: int = group_joins[group]
	while join != group:
		group = join
		join = group_joins[group]
	return group


# Returns a list of all cell vectors orthogonally adjacent to the given cell
func get_orthogonal(cellv: Vector2) -> Array:
	var orthogonal := []
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
func get_adjacent_buildings(cellv: Vector2, adjacent := [], visited := []) -> Array:
	var group := get_base_group(get_group(cellv))
	if group < BASE_GROUP_INDEX:
		return []
	visited.append(cellv)
	for adjacent_cellv in get_orthogonal(cellv):
		var adjacent_group := get_base_group(get_group(adjacent_cellv))
		if adjacent_group == group:
			if not visited.has(adjacent_cellv):
				adjacent = get_adjacent_buildings(
					adjacent_cellv,
					adjacent,
					visited
				)
		else:
			var adjacent_id := get_cellv(adjacent_cellv)
			if adjacent_id >= BASE_BUILDING_INDEX:
				var adjacent_building: Building = BUILDINGS[get_type(adjacent_id)]
				if (
					not adjacent_building.is_tile
					and not adjacent.has(adjacent_id)
				):
					adjacent.append(adjacent_id)
	return adjacent


# Event handler for palette selections
func _select_building(id: int) -> void:
	var building: Building = BUILDINGS[id]
	if not building:
		return
	self.selected_building = id
	if not building.is_tile:
		$PreviewBuilding.texture = building.texture
	_clear_preview()
	_update_preview()


func get_turn() -> int:
	return len(history)


func get_turns_remaining() -> int:
	return game_length - get_turn()


# May be a redundant implementation of TileMap's world_to_map function
func position_to_cellv(position: Vector2) -> Vector2:
	return ((position * camera.zoom + camera.position) / TILE_SIZE).floor()


func cellv_to_world_position(cellv: Vector2) -> Vector2:
	return cellv * TILE_SIZE


func cellv_to_screen_position(cellv: Vector2) -> Vector2:
	return (cellv_to_world_position(cellv) - camera.position) / camera.zoom


func get_building_sprite(id: int) -> Sprite:
	return get_node(NodePath("Buildings/building_%d" % id)) as Sprite


# Returns the buildings connected by road to the given building
func get_road_connections(cellv: Vector2, id: int) -> Array:
	var building: Building = BUILDINGS[id]
	var road_connections := []
	var counted_groups := []
	for adjacent_cellv in building.get_adjacent_cells(cellv):
		var adjacent_group := get_base_group(get_group(adjacent_cellv))
		if (
			adjacent_group >= BASE_GROUP_INDEX
			and not counted_groups.has(adjacent_group)
		):
			counted_groups.append(adjacent_group)
			for adjacent_building in adjacent_buildings[adjacent_group]:
				# Only add GP value
				road_connections.append(adjacent_building)
	return road_connections


# Updates the GP/VP label and turn label
func _update_labels() -> void:
	gp_label.text = str(gp)
	vp_label.text = str(vp)
	var turns_remaining := get_turns_remaining()
	turn_label.text = turn_format % turns_remaining


func _update_mouse_cellv() -> void:
	mouse_cellv = position_to_cellv(get_viewport().get_mouse_position())


func _clear_preview() -> void:
	if preview_cellv != null:
		#self.set_cellv(preview_cellv, 0)
		preview_cellv = null
		$Preview.clear()
		$PreviewTile.clear()
		$PreviewBuilding.visible = false
		preview_label.text = ''
		preview_node.visible = false
		for modulated_building in modulated_buildings:
			var sprite := get_building_sprite(modulated_building)
			if sprite != null and not sprite.is_queued_for_deletion():
				sprite.modulate = Color.white
		modulated_buildings.clear()

# Modulates the building with the given id based on its interaction with the
# given building type
# id is the modulated building's id, building is what it's modulated relative to
func modulate_building(building: Building, id: int, road_connection) -> void:
	if id < BASE_BUILDING_INDEX:
		return

	var type := get_type(id)
	var gp_interaction: int = building.gp_interactions.get(type, 0)
	var vp_interaction: int = (
		0
		if road_connection
		else building.vp_interactions.get(type, 0)
	)

	var modulation = null
	if (
		(gp_interaction > 0 and vp_interaction >= 0)
		or (gp_interaction >= 0 and vp_interaction > 0)
	):
		modulation = PREVIEW_COLOR_GOOD
	elif (
		(gp_interaction < 0 and vp_interaction <= 0)
		or (gp_interaction <= 0 and vp_interaction < 0)
	):
		modulation = PREVIEW_COLOR_BAD
	elif (
		(gp_interaction < 0 and vp_interaction > 0)
		or (gp_interaction > 0 and vp_interaction < 0)
	):
		modulation = PREVIEW_COLOR_MIXED

	if modulation != null:
		get_building_sprite(id).modulate = modulation
		modulated_buildings.append(id)

func _update_preview() -> void:
	# Only update the preview if the mouse has moved to a different cell
	self._update_mouse_cellv()
	if mouse_cellv == preview_cellv:
		return

	self._clear_preview()
	preview_node.visible = true
	preview_cellv = mouse_cellv
	var building: Building = BUILDINGS[selected_building]
	var building_cellv: Vector2 = preview_cellv - building.get_cell_offset()

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

	# Show area of current building with a 50% opacity white square
	for cellv in building.get_area_cells(building_cellv):
		$Preview.set_cellv(cellv, SELECTION)
		var id := get_cellv(cellv)
		modulate_building(building, id, false)

	var road_connections := get_road_connections(building_cellv, selected_building)
	for connected_building in road_connections:
		if !modulated_buildings.has(connected_building):
			modulate_building(building, connected_building, true)

	# Update preview label with expected building value
	var value := get_building_value(
		building_cellv,
		self.selected_building,
		road_connections
	)
	preview_label.text = "%s\n%s" % format_value(value)
	preview_node.rect_position = cellv_to_screen_position(
		Vector2(preview_cellv.x, building_cellv.y)
	) + Vector2((1.0 / camera.zoom.x * 4) + 15, -35)

	# Shade preview building in red if you can't afford to place it
	if value[0] + gp < 0:
		if building.is_tile:
			$PreviewTile.modulate = PREVIEW_COLOR_INVALID
		else:
			$PreviewBuilding.modulate = PREVIEW_COLOR_INVALID


# Gets the total value that would result from placing the building with the
# given ID at the given cellv, returned in the form [gp, vp]
# Includes the building's flat GP and VP, as well as interactions
func get_building_value(cellv: Vector2, id: int, road_connections = null) -> Array:
	var building: Building = BUILDINGS[id]
	var gp_value := building.gp
	var vp_value := building.vp
	var counted_ids := []
	var occupied_cells := building.get_cells(cellv)

	# Account for nearby buildings
	for area_cellv in building.get_area_cells(cellv):
		# Ignore the exact cells where the building is being placed
		if occupied_cells.has(area_cellv):
			continue

		var neighbor_id := self.get_cellv(area_cellv)
		if counted_ids.has(neighbor_id):
			continue
		counted_ids.append(neighbor_id)

		var neighbor_type := get_type(neighbor_id)
		gp_value += building.gp_interactions.get(neighbor_type, 0)
		vp_value += building.vp_interactions.get(neighbor_type, 0)

	# Account for buildings connected via road
	if road_connections == null:
		road_connections = get_road_connections(cellv, id)

	for connected_building in road_connections:
		if not counted_ids.has(connected_building):
			counted_ids.append(connected_building)
			# Only add gp value
			var connected_type := get_type(connected_building)
			gp_value += building.gp_interactions.get(connected_type, 0)

	return [floor(gp_value), floor(vp_value)]


func format_value(value: Array) -> Array:
	return [
		('+%d' if value[0] > 0 else '%d') % value[0],
		('+%d' if value[1] > 0 else '%d') % value[1],
	]

func place_building(cellv: Vector2, id: int, force := false):
	var building: Building = BUILDINGS[id]

	# Prevent placement if building overlaps any existing buildings
	for building_cellv in building.get_cells(cellv):
		if get_type(self.get_cellv(building_cellv)) != 0:
			return null

	# Check if building can be built in the first place
#	if gp + floor(building.gp) < 0:
#		return null

	# Give GP based on nearby buildings
	var building_value := get_building_value(cellv, id)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if gp + gp_change < 0 and not force:
		return null

	$BuildingPlaceSound.play()

	var neighbor_groups := []
	if building.groupable:
		for neighbor in get_orthogonal(cellv):
			var neighbor_type := get_type(get_cellv(neighbor))
			if neighbor_type == id:
				neighbor_groups.append(get_base_group(get_group(neighbor)))
		var x := cellv.x
		var y := cellv.y
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
			var joined_group: int = neighbor_groups.min()
			for group in neighbor_groups:
				group_joins[group] = joined_group
			groups[x][y] = joined_group

		# Update the list of buildings adjacent to the group
		adjacent_buildings[groups[x][y]] = get_adjacent_buildings(cellv)
	else:
		# Update all adjacency lists to include this building
		var adjacent_groups := []
		for adjacent_cellv in building.get_adjacent_cells(cellv):
			var group := get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_groups.append(group)
				adjacent_buildings[group].append(building_index)

	# Instance a new sprite if this building is not a tile
	if not building.is_tile:
		var instance := building_scene.instance()
		instance.position = cellv_to_world_position(cellv)
		instance.texture = building.texture
		instance.set_name("building_%d" % building_index)
		$Buildings.add_child(instance)

	self.set_cellv(cellv, id)
	return Placement.new(id, cellv, gp_change, vp_change, neighbor_groups)


func destroy_building(cellv: Vector2, id = null):
	# If an ID is given, use it to offset the cellv, ensuring that we won't
	# select part of the building with empty space
	# DON'T supply an ID if the cellv is already a tile the building occupies
	# Use it deletion where you only know the root cellv
	# There may be an edge case for a building with an empty center (e.g. a 3x3
	# donut-shaped building)
	if id != null:
		cellv += BUILDINGS[get_type(id)].get_cell_offset()
	id = self.get_cellv(cellv)
	if id <= 0:
		return null

	var is_tile: bool = id < BASE_BUILDING_INDEX

	var type: int = id
	if not is_tile:
		# If this isn't a tile building, free its sprite
		var instance := get_building_sprite(id)
		if instance and not instance.is_queued_for_deletion():
			instance.free()
		type = building_types[id]
	var building: Building = BUILDINGS[type]

	$BuildingDestroySound.play()

	var root := cellv
	if is_tile:
		self.set_cellv(cellv, 0)
		groups[cellv.x][cellv.y] = 0

		var adjacent_groups := []
		for adjacent_cellv in get_orthogonal(cellv):
			var group := get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_buildings[group] = get_adjacent_buildings(adjacent_cellv)
	else:
		# Reset all cells (in the world map and groups) occupied by this building
		# Does NOT modify the group_joins array; currently handled by the undo code
		root = building_roots[id]
		for building_cellv in building.get_cells(root):
			self.set_cellv(building_cellv, 0)
			groups[building_cellv.x][building_cellv.y] = 0

		var adjacent_groups := []
		for adjacent_cellv in building.get_adjacent_cells(root):
			var group := get_base_group(get_group(adjacent_cellv))
			if group >= BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_buildings[group].erase(id)

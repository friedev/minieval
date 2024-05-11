extends TileMap


class Building:
	var name: String
	var is_tile: bool
	var groupable: bool
	var gp: int
	var vp: int
	var area: Vector2i
	var texture: Texture2D
	var cells: Array[Array]
	var gp_interactions: Dictionary
	var vp_interactions: Dictionary

	func _init(
		name: String,
		is_tile: bool,
		groupable: bool,
		gp: int,
		vp: int,
		area: Vector2i,
		texture: Texture2D,
		cells: Array[Array],
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

	func get_size() -> Vector2i:
		return Vector2i(self.get_width(), self.get_height())

	func get_cell_offset() -> Vector2i:
		return Vector2i((Vector2(self.get_size()) / 2).ceil()) - Vector2i(1, 1)

	func get_area_offset() -> Vector2i:
		return Vector2i((Vector2(self.get_size()) / 2).floor())

	func get_width() -> int:
		return len(self.cells[0])

	func get_height() -> int:
		return len(self.cells)

	# Returns a list of all cell vectors orthogonally adjacent to the given cell
	# Duplicated from outer scope
	static func get_orthogonal(coords: Vector2i) -> Array[Vector2i]:
		var orthogonal: Array[Vector2i] = []
		if coords.x > 0:
			orthogonal.append(Vector2i(coords.x - 1, coords.y))
		if coords.x < Global.game_size:
			orthogonal.append(Vector2i(coords.x + 1, coords.y))
		if coords.y > 0:
			orthogonal.append(Vector2i(coords.x, coords.y - 1))
		if coords.y < Global.game_size:
			orthogonal.append(Vector2i(coords.x, coords.y + 1))
		return orthogonal

	static func get_cells_in_radius(
		coords: Vector2i,
		radius: Vector2
	) -> Array[Vector2i]:
		var cells: Array[Vector2i] = []
		for x in range(maxi(0, coords.x - floori(radius.x)),
				mini(Global.game_size, coords.x + ceili(radius.x))):
			for y in range(maxi(0, coords.y - floori(radius.y)),
					mini(Global.game_size, coords.y + ceili(radius.y))):
						cells.append(Vector2i(x, y))
		return cells

	func get_cells(coords := Vector2i(0, 0)) -> Array[Vector2i]:
		var cells: Array[Vector2i] = []
		for y in range(0, len(self.cells)):
			for x in range(0, len(self.cells[y])):
				if self.cells[y][x]:
					cells.append(Vector2i(x, y) + coords)
		return cells

	func get_area_cells(coords := Vector2i(0, 0)) -> Array[Vector2i]:
		return Building.get_cells_in_radius(
			coords + self.get_area_offset(),
			Vector2(self.area) / 2
		)

	func get_adjacent_cells(coords := Vector2i(0, 0)) -> Array[Vector2i]:
		var adjacent_cell_map: Array[Array] = []
		for y in range(0, len(self.cells) + 2):
			adjacent_cell_map.append([])
			for x in range(0, len(self.cells[0]) + 2):
				adjacent_cell_map[y].append(0)
		for building_coords in self.get_cells(Vector2i(1, 1)):
			adjacent_cell_map[building_coords.y][building_coords.x] = 2
			for adjacent_coords in self.get_orthogonal(building_coords):
				adjacent_cell_map[adjacent_coords.y][adjacent_coords.x] = maxi(
					1,
					adjacent_cell_map[adjacent_coords.y][adjacent_coords.x]
				)
		var adjacent_cells: Array[Vector2i] = []
		for y in range(0, len(adjacent_cell_map)):
			for x in range(0, len(adjacent_cell_map[y])):
				if adjacent_cell_map[y][x] == 1:
					adjacent_cells.append(Vector2i(x - 1, y - 1) + coords)
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
		Vector2i(0, 0), # area
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
		Vector2i(3, 3), # area
		preload("res://sprites/buildings/house.png"), # texture
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
		Vector2i(6, 5), # area
		preload("res://sprites/buildings/shop.png"), # texture
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
		Vector2i(4, 4), # area
		preload("res://sprites/buildings/mansion.png"), # texture
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
		Vector2i(6, 6), # area
		preload("res://sprites/buildings/forge.png"), # texture
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
		Vector2i(5, 6), # area
		preload("res://sprites/buildings/statue.png"), # texture
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
		Vector2i(8, 7), # area,
		preload("res://sprites/buildings/cathedral.png"), # texture
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
		Vector2i(9, 8), # area
		preload("res://sprites/buildings/keep.png"), # sprite
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
		Vector2i(5, 5), # area
		preload("res://sprites/buildings/tower.png"), # texture
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
		Vector2i(16, 12), # area
		preload("res://sprites/buildings/pyramid.png"), # texture
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
	var coords: Vector2i
	var gp_change: int
	var vp_change: int
	var group_joins: Array[int]

	func _init(
		id: int,
		coords: Vector2i,
		gp_change: int,
		vp_change: int,
		group_joins: Array[int]
	):
		self.id = id
		self.coords = coords
		self.gp_change = gp_change
		self.vp_change = vp_change
		self.group_joins = group_joins


const INVALID_BUILDING := -1
const INVALID_COORDS := Vector2i(-1, -1)
const INVALID_GROUP := -1

const PREVIEW_COLOR := Color.WHITE
const PREVIEW_COLOR_INVALID := Color(1, 0.25, 0.25, 0.5)
const PREVIEW_COLOR_GOOD := Color(0.25, 1, 0.25, 1)
const PREVIEW_COLOR_MIXED := Color(1, 1, 0.25, 1)
const PREVIEW_COLOR_BAD := Color(1, 0.25, 0.25, 1)

const TILE_SIZE := 8 # TODO determine from node properties
const BASE_BUILDING_INDEX := 20 # First unused index
const BASE_GROUP_INDEX := 1
const DEFAULT_BUILDING := 11

const MOUSE_SPEED := 1000.0
const MOUSE_SPEED_MIN := 0.25
const MOUSE_ACCELERATION := 0.8

const building_scene := preload("res://scenes/building.tscn")

const turn_format := "%d Turns Left"

# 2D array of building IDs; 0 is empty, and all tile buildings share the same ID
var world_map: Array[Array] = []
# 1D array mapping a building ID (the index into this array) to its type (an
# index in the BUILDINGS array)
# Content starts at BASE_BUILDING_INDEX, everything before that is null
var building_types: Array[int] = []
# 1D array mapping a building ID (the index into this array) to its root
# position (a cell vector)
var building_roots: Array[Vector2i] = []
# 2D array of group IDs; 0 is no group
var groups: Array[Array] = []
# 1D array mapping a group (the index into this array) to the group it has been
# merged into (another group)
# A group that has not been merged will map to its own index
# Recursively indexing into this array will get you to the "base group"
var group_joins: Array[int] = []
# 2D array mapping a group to a 1D array of building IDs adjacent to the group
var adjacent_buildings: Array[Array] = []
var building_index := self.BASE_BUILDING_INDEX
var group_index := self.BASE_GROUP_INDEX

var gp := 25
var vp := 0
var selected_building := self.DEFAULT_BUILDING

var game_length := Global.num_turns
var history: Array[Placement] = []
var future: Array[Placement] = []

var mouse_coords := INVALID_COORDS
var preview_coords := INVALID_COORDS
var modulated_buildings: Array[int] = []
var in_menu := false
var mouse_direction := Vector2.ZERO

@onready var main := self.get_node("/root/Main")

@onready var ui_text_layer: CanvasLayer = self.main.find_child("UITextLayer")
@onready var gp_label: Label = self.main.find_child("GPLabel")
@onready var vp_label: Label = self.main.find_child("VPLabel")
@onready var turn_label: Label = self.main.find_child("TurnLabel")
@onready var undo_label: Label = self.main.find_child("UndoLabel")

@onready var palette := self.main.find_child("Palette")
@onready var palette_tilemap := self.palette.find_child("TileMap")

@onready var recap := self.main.find_child("Recap")

@onready var camera: Camera2D = self.main.find_child("Camera2D")
@onready var preview_label: Label = self.main.find_child("PreviewLabel")
@onready var preview_node: Control = self.main.find_child("PreviewNode")
@onready var preview_building: Sprite2D = self.main.find_child("PreviewBuilding")

@onready var building_particles: GPUParticles2D = $BuildingParticles
@onready var particles_material: ParticleProcessMaterial = self.building_particles.process_material
@onready var particles_amount := self.building_particles.amount
@onready var particles_scale := self.particles_material.scale_min
@onready var particles_velocity := self.particles_material.initial_velocity_min
@onready var particles_accel := self.particles_material.linear_accel_min


func _ready() -> void:
	self.turn_label.visible = not Global.endless

	# Change the selected building when a building is clicked on the palette
	self.palette_tilemap.palette_selection.connect(self._select_building)

	self._update_mouse_coords()
	self._update_labels()

	for x in range(0, Global.game_size):
		self.world_map.append([])
		self.groups.append([])
		for y in range(0, Global.game_size):
			self.world_map[x].append(0)
			self.groups[x].append(0)
			super.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)

	self.camera.position = self.map_to_local(
		Vector2(Global.game_size / 2, Global.game_size / 2)
	) - self.camera.offset

	for i in range(self.BASE_BUILDING_INDEX):
		self.building_types.append(self.INVALID_BUILDING)
		self.building_roots.append(self.INVALID_COORDS)

	for i in range(self.BASE_GROUP_INDEX):
		self.groups.append([])
		self.group_joins.append(self.INVALID_GROUP)
		self.adjacent_buildings.append([])

	self._select_building(self.DEFAULT_BUILDING)


func _process(delta: float) -> void:
	var mouse_input_direction := Vector2(
		Input.get_axis(&"mouse_left", &"mouse_right"),
		Input.get_axis(&"mouse_up", &"mouse_down")
	)
	if mouse_input_direction.is_zero_approx():
		self.mouse_direction = Vector2.ZERO
	elif (
		self.mouse_direction.is_zero_approx()
		or self.mouse_direction.angle_to(mouse_input_direction) > PI / 2
	):
		self.mouse_direction = mouse_input_direction * self.MOUSE_SPEED_MIN
	else:
		self.mouse_direction = self.mouse_direction.lerp(
			mouse_input_direction,
			self.MOUSE_ACCELERATION * delta
		)
	var mouse_velocity := self.mouse_direction * self.MOUSE_SPEED * delta
	self.get_viewport().warp_mouse(get_viewport().get_mouse_position() + mouse_velocity)

	if not self.in_menu:
		# Update the preview if the mouse has moved to a different cell
		self._update_mouse_coords()
		if self.mouse_coords != self.preview_coords:
			self._update_preview()
	else:
		self._clear_preview()


func select_cell(coords: Vector2i) -> void:
	self.get_viewport().warp_mouse(self.coords_to_screen_position(coords))


func _unhandled_input(event: InputEvent) -> void:
	if self.in_menu:
		return

	if event.is_action_pressed(&"place_building"):
		self._clear_preview()

		var building: Building = self.BUILDINGS[self.selected_building]
		var placement: Placement = self.place_building(
			self.mouse_coords - building.get_cell_offset(),
			self.selected_building,
			false
		)

		if placement:
			self.gp += placement.gp_change
			self.vp += placement.vp_change
			self.history.append(placement)
			self.future.clear()
			self._update_labels()
			if self.is_game_over():
				self.recap.end_game()
		else:
			if event is InputEventMouseButton:
				$BuildingPlaceErrorSound.play()
	elif event.is_action_pressed(&"undo"):
		self.undo()
	elif event.is_action_pressed(&"redo"):
		self.redo()
	elif event.is_action_pressed(&"select_cell_left"):
		self.select_cell(self.mouse_coords + Vector2i.LEFT)
	elif event.is_action_pressed(&"select_cell_right"):
		self.select_cell(self.mouse_coords + Vector2i.RIGHT)
	elif event.is_action_pressed(&"select_cell_up"):
		self.select_cell(self.mouse_coords + Vector2i.UP)
	elif event.is_action_pressed(&"select_cell_down"):
		self.select_cell(self.mouse_coords + Vector2i.DOWN)


func undo() -> void:
	self._clear_preview()
	var prev_placement: Placement = self.history.pop_back()
	if prev_placement:
		self.destroy_building(prev_placement.coords, prev_placement.id)
		self.gp -= prev_placement.gp_change
		self.vp -= prev_placement.vp_change
		for join in prev_placement.group_joins:
			self.group_joins[join] = join
		self.future.append(prev_placement)
		self._update_labels()


func redo() -> void:
	self._clear_preview()
	var next_placement: Placement = self.future.pop_back()
	if next_placement:
		self.place_building(next_placement.coords, next_placement.id, true)
		self.gp += next_placement.gp_change
		self.vp += next_placement.vp_change
		self.history.append(next_placement)
		self._update_labels()


func is_in_bounds(coords: Vector2i) -> bool:
	return (
		coords.x >= 0
		and coords.x < len(self.world_map)
		and coords.y >= 0
		and coords.y < len(self.world_map[coords.x])
	)


# Return the building ID at the given coords
func get_coords(coords: Vector2i) -> int:
	if not self.is_in_bounds(coords):
		return self.INVALID_BUILDING
	return self.world_map[coords.x][coords.y]


# Updates world map, building types, and building roots where applicable
# Does NOT spawn a building sprite, update groups, or fully clean up destroyed
# buildings
func set_buildingv(coords: Vector2i, tile: int) -> void:
	assert(self.is_in_bounds(coords))
	assert(tile in self.BUILDINGS or tile == self.INVALID_BUILDING)

	var building: Building = self.BUILDINGS[tile]
	if building and not building.is_tile:
		# TODO move to place_building or other helper method
		for building_coords in building.get_cells(coords):
			self.world_map[building_coords.x][building_coords.y] = self.building_index
			# Hide the empty tiles behind the building by setting them to invalid
			super.set_cell(0, building_coords, 0)
		self.building_types.append(tile)
		self.building_roots.append(coords)
		self.building_index += 1
		return

	self.world_map[coords.x][coords.y] = tile

	# Update autotiling (assumes all tiles are roads)
	if building != null:
		super.set_cells_terrain_connect(0, [coords], 0, 0)
		return

	# We're removing this tile, so update the autotiling of all surrounding
	# tiles, as it's not done automatically
	var terrain_cells: Array[Vector2i] = []
	super.set_cell(0, coords, tile, Vector2i.ZERO)
	for orthogonal in self.get_orthogonal(coords):
		if self.get_type(self.get_coords(orthogonal)) == self.ROAD:
			# Delete and recreate surrounding roads to force them to refresh
			# Only calling set_cells_terrain_connect is insufficient
			super.set_cell(0, orthogonal, tile, Vector2i.ZERO)
			terrain_cells.append(orthogonal)
	super.set_cells_terrain_connect(0, terrain_cells, 0, 0)


# Helper function to get a building's type (an index into the BUILDINGS array)
# from its ID
func get_type(id: int) -> int:
	if id < self.BASE_BUILDING_INDEX:
		return id
	return self.building_types[id]


func get_group(coords: Vector2i) -> int:
	if (
		coords.x < 0 or coords.x >= len(self.world_map)
		or coords.y < 0 or coords.y >= len(self.world_map[coords.x])
	):
		return self.INVALID_BUILDING
	return self.groups[coords.x][coords.y]


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_base_group(group: int) -> int:
	if group < self.BASE_GROUP_INDEX or group >= len(self.groups):
		return self.INVALID_BUILDING
	var join: int = self.group_joins[group]
	while join != group:
		group = join
		join = self.group_joins[group]
	return group


# Returns a list of all cell vectors orthogonally adjacent to the given cell
func get_orthogonal(coords: Vector2i) -> Array[Vector2i]:
	var orthogonal: Array[Vector2i] = []
	if coords.x > 0:
		orthogonal.append(Vector2i(coords.x - 1, coords.y))
	if coords.x < Global.game_size:
		orthogonal.append(Vector2i(coords.x + 1, coords.y))
	if coords.y > 0:
		orthogonal.append(Vector2i(coords.x, coords.y - 1))
	if coords.y < Global.game_size:
		orthogonal.append(Vector2i(coords.x, coords.y + 1))
	return orthogonal


# Returns a list of all building IDs adjacent to a group, starting at given tile
# Uses a recursive depth-first search
func get_adjacent_buildings(
	coords: Vector2i,
	adjacent: Array[int] = [],
	visited: Array[Vector2i] = []
) -> Array[int]:
	var group := self.get_base_group(self.get_group(coords))
	if group < self.BASE_GROUP_INDEX:
		return []
	visited.append(coords)
	for adjacent_coords in self.get_orthogonal(coords):
		var adjacent_group := self.get_base_group(self.get_group(adjacent_coords))
		if adjacent_group == group:
			if not visited.has(adjacent_coords):
				adjacent = self.get_adjacent_buildings(
					adjacent_coords,
					adjacent,
					visited
				)
		else:
			var adjacent_id := self.get_coords(adjacent_coords)
			if adjacent_id >= self.BASE_BUILDING_INDEX:
				var adjacent_building: Building = self.BUILDINGS[self.get_type(adjacent_id)]
				if (
					not adjacent_building.is_tile
					and not adjacent.has(adjacent_id)
				):
					adjacent.append(adjacent_id)
	return adjacent


# Event handler for palette selections
func _select_building(id: int) -> void:
	var building: Building = self.BUILDINGS[id]
	if not building:
		return
	self.selected_building = id
	if not building.is_tile:
		$PreviewBuilding.texture = building.texture
	self._update_preview()


func get_turn() -> int:
	return len(self.history)


func get_turns_remaining() -> int:
	return self.game_length - self.get_turn()


func is_game_over() -> bool:
	return not Global.endless and self.get_turns_remaining() == 0


func coords_to_screen_position(coords: Vector2i) -> Vector2:
	return (
		(self.map_to_local(coords) - self.camera.get_screen_center_position()) * self.camera.zoom
		+ self.get_viewport_rect().size / 2
	)


func get_building_sprite(id: int) -> Sprite2D:
	return self.get_node(NodePath("Buildings/building_%d" % id)) as Sprite2D


# Returns the buildings connected by road to the given building
func get_road_connections(coords: Vector2i, id: int) -> Array[int]:
	var building: Building = self.BUILDINGS[id]
	var road_connections: Array[int] = []
	var counted_groups: Array[int] = []
	for adjacent_coords in building.get_adjacent_cells(coords):
		var adjacent_group := self.get_base_group(self.get_group(adjacent_coords))
		if (
			adjacent_group >= self.BASE_GROUP_INDEX
			and not counted_groups.has(adjacent_group)
		):
			counted_groups.append(adjacent_group)
			for adjacent_building in self.adjacent_buildings[adjacent_group]:
				# Only add GP value
				road_connections.append(adjacent_building)
	return road_connections


# Updates the GP/VP label and turn label
func _update_labels() -> void:
	self.gp_label.text = str(self.gp)
	self.vp_label.text = str(self.vp)
	var turns_remaining := self.get_turns_remaining()
	self.turn_label.text = self.turn_format % turns_remaining
	self.undo_label.visible = self.gp == 0


func _update_mouse_coords() -> void:
	self.mouse_coords = self.local_to_map(self.get_local_mouse_position())


func _clear_preview() -> void:
	if self.preview_coords != self.INVALID_COORDS:
		#self.set_buildingv(self.preview_coords, 0)
		self.preview_coords = self.INVALID_COORDS
		$Preview.clear()
		$PreviewTile.clear()
		$PreviewBuilding.visible = false
		self.preview_label.text = ""
		self.preview_node.visible = false
		for modulated_building in self.modulated_buildings:
			var sprite := self.get_building_sprite(modulated_building)
			if sprite != null and not sprite.is_queued_for_deletion():
				sprite.modulate = Color.WHITE
		self.modulated_buildings.clear()


# Modulates the building with the given id based on its interaction with the
# given building type
# id is the modulated building's id, building is what it's modulated relative to
func modulate_building(building: Building, id: int, road_connection: bool) -> void:
	if id < self.BASE_BUILDING_INDEX:
		return

	var type := self.get_type(id)
	var gp_interaction: int = building.gp_interactions.get(type, 0)
	var vp_interaction: int = (
		0
		if road_connection
		else building.vp_interactions.get(type, 0)
	)

	var modulation: Color
	if (
		(gp_interaction > 0 and vp_interaction >= 0)
		or (gp_interaction >= 0 and vp_interaction > 0)
	):
		modulation = self.PREVIEW_COLOR_GOOD
	elif (
		(gp_interaction < 0 and vp_interaction <= 0)
		or (gp_interaction <= 0 and vp_interaction < 0)
	):
		modulation = self.PREVIEW_COLOR_BAD
	elif (
		(gp_interaction < 0 and vp_interaction > 0)
		or (gp_interaction > 0 and vp_interaction < 0)
	):
		modulation = self.PREVIEW_COLOR_MIXED
	else:
		# Don't apply modulation
		return

	self.get_building_sprite(id).modulate = modulation
	self.modulated_buildings.append(id)


func _update_preview() -> void:
	self._clear_preview()
	self.preview_node.visible = true
	self.preview_coords = self.mouse_coords
	var building: Building = self.BUILDINGS[self.selected_building]
	var building_coords: Vector2i = self.preview_coords - building.get_cell_offset()

	# Move the building preview
	$PreviewBuilding.position = self.map_to_local(building_coords)
	if building.is_tile:
		$PreviewTile.set_cells_terrain_connect(0, [building_coords], 0, 0)
	else:
		$PreviewBuilding.visible = true

	# Shade preview building in red if the placement is blocked
	if building.is_tile:
		$PreviewTile.modulate = self.PREVIEW_COLOR
		if self.get_coords(building_coords) != 0:
			$PreviewTile.modulate = self.PREVIEW_COLOR_INVALID
	else:
		$PreviewBuilding.modulate = self.PREVIEW_COLOR
		for coords in building.get_cells(building_coords):
			if self.get_coords(coords) != 0:
				$PreviewBuilding.modulate = self.PREVIEW_COLOR_INVALID
				break

	# Show area of current building with a 50% opacity white square
	for coords in building.get_area_cells(building_coords):
		$Preview.set_cell(0, coords, self.SELECTION, Vector2i.ZERO)
		var id := self.get_coords(coords)
		self.modulate_building(building, id, false)

	var road_connections := self.get_road_connections(building_coords, self.selected_building)
	for connected_building in road_connections:
		if not self.modulated_buildings.has(connected_building):
			self.modulate_building(building, connected_building, true)

	# Update preview label with expected building value
	var value := self.get_building_value(
		building_coords,
		self.selected_building,
		false,
		road_connections
	)
	self.preview_label.text = "%s\n%s" % self.format_value(value)
	self.preview_node.position = self.coords_to_screen_position(
		Vector2i(self.preview_coords.x, building_coords.y)
	)
	self.preview_node.position.y -= self.TILE_SIZE / 2 * self.camera.zoom.y

	# Shade preview building in red if you can't afford to place it
	if value[0] + self.gp < 0:
		if building.is_tile:
			$PreviewTile.modulate = self.PREVIEW_COLOR_INVALID
		else:
			$PreviewBuilding.modulate = self.PREVIEW_COLOR_INVALID


# Gets the total value that would result from placing the building with the
# given ID at the given coords, returned in the form [gp, vp]
# Includes the building's flat GP and VP, as well as interactions
func get_building_value(
	coords: Vector2i,
	id: int,
	get_road_connections := true,
	road_connections: Array[int] = []
) -> Array[int]:
	var building: Building = self.BUILDINGS[id]
	var gp_value := building.gp
	var vp_value := building.vp
	var counted_ids: Array[int] = []
	var occupied_cells := building.get_cells(coords)

	# Account for nearby buildings
	for area_coords in building.get_area_cells(coords):
		# Ignore the exact cells where the building is being placed
		if occupied_cells.has(area_coords):
			continue

		var neighbor_id := self.get_coords(area_coords)
		if counted_ids.has(neighbor_id):
			continue
		counted_ids.append(neighbor_id)

		var neighbor_type := self.get_type(neighbor_id)
		gp_value += building.gp_interactions.get(neighbor_type, 0)
		vp_value += building.vp_interactions.get(neighbor_type, 0)

	# Account for buildings connected via road
	if get_road_connections:
		assert(road_connections == [])
		road_connections = self.get_road_connections(coords, id)

	for connected_building in road_connections:
		if not counted_ids.has(connected_building):
			counted_ids.append(connected_building)
			# Only add gp value
			var connected_type := self.get_type(connected_building)
			gp_value += building.gp_interactions.get(connected_type, 0)

	return [floor(gp_value), floor(vp_value)]


func format_value(value: Array[int]) -> Array[String]:
	return [
		("+%d" if value[0] > 0 else "%d") % value[0],
		("+%d" if value[1] > 0 else "%d") % value[1],
	]


func reset_particles() -> void:
	$BuildingParticles.amount = self.particles_amount
	self.particles_material.scale_min = self.particles_scale
	self.particles_material.scale_max = self.particles_scale
	self.particles_material.initial_velocity_min = self.particles_velocity
	self.particles_material.initial_velocity_max = self.particles_velocity
	self.particles_material.linear_accel_min = self.particles_accel
	self.particles_material.linear_accel_max = self.particles_accel


func emit_particles(coords: Vector2i, building: Building) -> void:
	if building.is_tile:
		return

	self.reset_particles()

	# TODO make particles a child of building scene and customize there instead
	var size := Vector2i(len(building.cells[0]), len(building.cells))
	var multiplier := sqrt((size.x + size.y) / 2.0) * 1.25
	$BuildingParticles.position = self.map_to_local(coords + size / 2)
	self.particles_material.emission_sphere_radius = size.length() / 2
	$BuildingParticles.amount *= multiplier
	self.particles_material.scale_min *= multiplier
	self.particles_material.scale_max *= multiplier
	self.particles_material.initial_velocity_min *= multiplier
	self.particles_material.initial_velocity_max *= multiplier
	self.particles_material.linear_accel_min *= multiplier
	self.particles_material.linear_accel_max *= multiplier
	$BuildingParticles.restart()


func place_building(coords: Vector2i, id: int, force := false) -> Placement:
	var building: Building = self.BUILDINGS[id]

	# Prevent placement if building overlaps any existing buildings
	for building_coords in building.get_cells(coords):
		if self.get_type(self.get_coords(building_coords)) != 0:
			return null

	# Check if building can be built in the first place
#	if self.gp + floor(building.gp) < 0:
#		return null

	# Give GP based on nearby buildings
	var building_value := self.get_building_value(coords, id)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if self.gp + gp_change < 0 and not force:
		return null

	$BuildingPlaceSound.play()
	self.emit_particles(coords, building)

	var neighbor_groups: Array[int] = []
	if building.groupable:
		for neighbor in get_orthogonal(coords):
			var neighbor_type := get_type(get_coords(neighbor))
			if neighbor_type == id:
				neighbor_groups.append(get_base_group(get_group(neighbor)))
		var x := coords.x
		var y := coords.y
		# If no neighboring groups exist, make a new group
		if len(neighbor_groups) == 0:
			self.groups[x][y] = self.group_index
			self.group_joins.append(self.group_index)
			self.adjacent_buildings.append([])
			self.group_index += 1
		# If there's exactly one neighboring group, use that
		elif len(neighbor_groups) == 1:
			self.groups[x][y] = neighbor_groups[0]
		# If this tile bridges more than one group, join them all
		else:
			var joined_group: int = neighbor_groups.min()
			for group in neighbor_groups:
				self.group_joins[group] = joined_group
			self.groups[x][y] = joined_group

		# Update the list of buildings adjacent to the group
		self.adjacent_buildings[self.groups[x][y]] = self.get_adjacent_buildings(coords)
	else:
		# Update all adjacency lists to include this building
		var adjacent_groups: Array[int] = []
		for adjacent_coords in building.get_adjacent_cells(coords):
			var group := self.get_base_group(self.get_group(adjacent_coords))
			if group >= self.BASE_GROUP_INDEX and not adjacent_groups.has(group):
				adjacent_groups.append(group)
				self.adjacent_buildings[group].append(self.building_index)

	# Instance a new sprite if this building is not a tile
	if not building.is_tile:
		var instance: Sprite2D = self.building_scene.instantiate()
		instance.position = self.map_to_local(coords)
		instance.texture = building.texture
		instance.set_name("building_%d" % self.building_index)
		$Buildings.add_child(instance)

	self.set_buildingv(coords, id)
	return Placement.new(id, coords, gp_change, vp_change, neighbor_groups)


func destroy_building(coords: Vector2i, id := self.INVALID_BUILDING) -> void:
	# If an ID is given, use it to offset the coords, ensuring that we won't
	# select part of the building with empty space
	# DON'T supply an ID if the coords is already a tile the building occupies
	# Use it for deletion where you only know the root coords
	# There may be an edge case for a building with an empty center (e.g. a 3x3
	# donut-shaped building)
	if id != self.INVALID_BUILDING:
		coords += self.BUILDINGS[self.get_type(id)].get_cell_offset()
	id = self.get_coords(coords)
	if id == self.INVALID_BUILDING:
		return

	var is_tile: bool = id < self.BASE_BUILDING_INDEX

	var type: int = id
	if not is_tile:
		# If this isn't a tile building, free its sprite
		var instance := self.get_building_sprite(id)
		if instance and not instance.is_queued_for_deletion():
			instance.free()
		type = self.building_types[id]
	var building: Building = self.BUILDINGS[type]

	$BuildingDestroySound.play()
	self.emit_particles(coords - building.get_cell_offset(), building)

	var root := coords
	if is_tile:
		self.set_buildingv(coords, 0)
		self.groups[coords.x][coords.y] = 0

		var adjacent_groups: Array[int] = []
		for adjacent_coords in self.get_orthogonal(coords):
			var group := self.get_base_group(self.get_group(adjacent_coords))
			if group >= self.BASE_GROUP_INDEX and not adjacent_groups.has(group):
				self.adjacent_buildings[group] = self.get_adjacent_buildings(adjacent_coords)
	else:
		# Reset all cells (in the world map and groups) occupied by this building
		# Does NOT modify the group_joins array; currently handled by the undo code
		root = self.building_roots[id]
		for building_coords in building.get_cells(root):
			self.set_buildingv(building_coords, 0)
			self.groups[building_coords.x][building_coords.y] = 0

		var adjacent_groups: Array[int] = []
		for adjacent_coords in building.get_adjacent_cells(root):
			var group := self.get_base_group(self.get_group(adjacent_coords))
			if group >= self.BASE_GROUP_INDEX and not adjacent_groups.has(group):
				self.adjacent_buildings[group].erase(id)

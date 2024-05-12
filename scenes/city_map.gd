class_name CityMap extends TileMap

signal gp_changed(gp: int)
signal vp_changed(vp: int)
signal game_over
signal turn_changed(turn: int)

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


enum BuildingType {
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


static var BUILDINGS := {
	BuildingType.EMPTY: null,
	BuildingType.ROAD: Building.new(
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
	BuildingType.HOUSE: Building.new(
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
			BuildingType.SHOP: 2,
		},
		{ # vp_interactions
			BuildingType.STATUE: 2,
		}
	),
	BuildingType.SHOP: Building.new(
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
			BuildingType.HOUSE: 1,
			BuildingType.SHOP: -5,
			BuildingType.MANSION: 2,
			BuildingType.FORGE: 3,
		},
		{ # vp_interactions
			BuildingType.CATHEDRAL: -5,
		}
	),
	BuildingType.MANSION: Building.new(
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
			BuildingType.SHOP: 4,
			BuildingType.MANSION: -2,
		}, {
			BuildingType.STATUE: 4,
		}
	),
	BuildingType.FORGE: Building.new(
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
			BuildingType.SHOP: 3,
			BuildingType.FORGE: -5,
		},
		{ # vp_interactions
			BuildingType.CATHEDRAL: -5,
			BuildingType.KEEP: 5,
		}
	),
	BuildingType.STATUE: Building.new(
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
			BuildingType.HOUSE: 1,
			BuildingType.MANSION: 2,
			BuildingType.STATUE: -5,
			BuildingType.CATHEDRAL: 5,
		}
	),
	BuildingType.CATHEDRAL: Building.new(
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
			BuildingType.FORGE: 10,  # Forge
			BuildingType.CATHEDRAL: -20, # Cathedral
		},
		{ # vp_interactions
			BuildingType.SHOP: -10,
			BuildingType.FORGE: -10,
			BuildingType.STATUE: 10,
			BuildingType.CATHEDRAL: -20,
		}
	),
	BuildingType.KEEP: Building.new(
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
			BuildingType.FORGE: 10,
			BuildingType.KEEP: -40,
		},
		{ # vp_interactions
			BuildingType.FORGE: 10,
			BuildingType.KEEP: -20,
			BuildingType.TOWER: 20,
		}
	),
	BuildingType.TOWER: Building.new(
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
			BuildingType.FORGE: 5,
		},
		{ # vp_interactions
			BuildingType.KEEP: 20,
			BuildingType.TOWER: -10,
		}
	),
	BuildingType.PYRAMID: Building.new(
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
			BuildingType.HOUSE: -5,
			BuildingType.SHOP: -5,
			BuildingType.MANSION: -5,
			BuildingType.FORGE: -5,
			BuildingType.STATUE: -5,
			BuildingType.CATHEDRAL: -5,
			BuildingType.KEEP: -5,
			BuildingType.TOWER: -5,
			BuildingType.PYRAMID: -5,
		},
		{ # vp_interactions
			BuildingType.HOUSE: 5,
			BuildingType.SHOP: 5,
			BuildingType.MANSION: 5,
			BuildingType.FORGE: 5,
			BuildingType.STATUE: 5,
			BuildingType.CATHEDRAL: 5,
			BuildingType.KEEP: 5,
			BuildingType.TOWER: 5,
			BuildingType.PYRAMID: 5,
		}
	),
}


class Placement:
	var type: BuildingType
	var coords: Vector2i
	var gp_change: int
	var vp_change: int
	var group_joins: Array[int]

	func _init(
		type: BuildingType,
		coords: Vector2i,
		gp_change: int,
		vp_change: int,
		group_joins: Array[int]
	):
		self.type = type
		self.coords = coords
		self.gp_change = gp_change
		self.vp_change = vp_change
		self.group_joins = group_joins


const INVALID_BUILDING := -1
const INVALID_COORDS := Vector2i(-1, -1)
const INVALID_GROUP := -1

const EMPTY_COORDS := Vector2i(0, 0)
const SELECTION_COORDS := Vector2i(1, 0)
const ROAD_TERRAIN_SET := 0
const ROAD_TERRAIN := 0

const TILE_SIZE := 8 # TODO determine from node properties
const BASE_BUILDING_INDEX := 20 # First unused index
const BASE_GROUP_INDEX := 1
const DEFAULT_BUILDING := 11

const building_scene := preload("res://scenes/building.tscn")

@export_group("Preview Colors")
@export var default_color: Color
@export var invalid_color: Color
@export var good_color: Color
@export var mixed_color: Color
@export var bad_color: Color

@export_group("Mouse Input")
@export var mouse_speed: float
@export var mouse_speed_min: float
@export var mouse_acceleration: float

@export_group("External Nodes")
@export var camera: Camera
@export var preview_label: Label
@export var preview_node: Control

@export_group("Internal Nodes")
@export var building_place_error_sound: AudioStreamPlayer
@export var building_place_sound: AudioStreamPlayer
@export var building_destroy_sound: AudioStreamPlayer
@export var buildings_node: Node2D
@export var preview_area: TileMap
@export var preview_tile: TileMap
@export var preview_building: Sprite2D
@export var building_particles: GPUParticles2D

# 2D array of building IDs; 0 is empty, and all tile buildings share the same ID
var world_map: Array[Array] = []
# 1D array mapping a building ID (the index into this array) to its type (an
# index in the BUILDINGS array)
# Content starts at BASE_BUILDING_INDEX, everything before that is null
var building_types: Array[BuildingType] = []
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

var gp: int:
	set(value):
		gp = value
		self.gp_changed.emit(self.gp)

var vp: int:
	set(value):
		vp = value
		self.vp_changed.emit(self.vp)

var selected_building := self.DEFAULT_BUILDING

var history: Array[Placement] = []
var future: Array[Placement] = []

var mouse_coords := self.INVALID_COORDS
var preview_coords := self.INVALID_COORDS
var modulated_buildings: Array[int] = []
var mouse_direction := Vector2.ZERO

@onready var particles_material: ParticleProcessMaterial = self.building_particles.process_material
@onready var particles_amount := self.building_particles.amount
@onready var particles_scale := self.particles_material.scale_min
@onready var particles_velocity := self.particles_material.initial_velocity_min
@onready var particles_accel := self.particles_material.linear_accel_min


func _ready() -> void:
	self.gp = Global.initial_gp
	self.vp = 0

	self._update_mouse_coords()
	self._update_labels()

	for x in range(0, Global.game_size):
		self.world_map.append([])
		self.groups.append([])
		for y in range(0, Global.game_size):
			self.world_map[x].append(0)
			self.groups[x].append(0)
			super.set_cell(0, Vector2i(x, y), 0, CityMap.EMPTY_COORDS)

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
		self.mouse_direction = mouse_input_direction * self.mouse_speed_min
	else:
		self.mouse_direction = self.mouse_direction.lerp(
			mouse_input_direction,
			self.mouse_acceleration * delta
		)
	var mouse_velocity := self.mouse_direction * self.mouse_speed * delta
	self.get_viewport().warp_mouse(get_viewport().get_mouse_position() + mouse_velocity)

	if not Global.is_menu_open:
		# Update the preview if the mouse has moved to a different cell
		self._update_mouse_coords()
		if self.mouse_coords != self.preview_coords:
			self._update_preview()
	else:
		self._clear_preview()


func select_cell(coords: Vector2i) -> void:
	self.get_viewport().warp_mouse(self.coords_to_screen_position(coords))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"place_building"):
		self._clear_preview()

		var building: Building = CityMap.BUILDINGS[self.selected_building]
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
			self.turn_changed.emit(self.get_turn())
			self._update_labels()
			if self.is_game_over():
				self.game_over.emit()
		else:
			if event is InputEventMouseButton:
				self.building_place_error_sound.play()
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
		self.destroy_building(prev_placement.coords, prev_placement.type)
		self.gp -= prev_placement.gp_change
		self.vp -= prev_placement.vp_change
		for join in prev_placement.group_joins:
			self.group_joins[join] = join
		self.future.append(prev_placement)
		self.turn_changed.emit(self.get_turn())
		self._update_labels()


func redo() -> void:
	self._clear_preview()
	var next_placement: Placement = self.future.pop_back()
	if next_placement:
		self.place_building(next_placement.coords, next_placement.type, true)
		self.gp += next_placement.gp_change
		self.vp += next_placement.vp_change
		self.history.append(next_placement)
		self.turn_changed.emit(self.get_turn())
		self._update_labels()


func is_in_bounds(coords: Vector2i) -> bool:
	return (
		coords.x >= 0
		and coords.x < len(self.world_map)
		and coords.y >= 0
		and coords.y < len(self.world_map[coords.x])
	)


# Return the building ID at the given coords
func get_building(coords: Vector2i) -> int:
	if not self.is_in_bounds(coords):
		return self.INVALID_BUILDING
	return self.world_map[coords.x][coords.y]


# Updates world map, building types, and building roots where applicable
# Does NOT spawn a building sprite, update groups, or fully clean up destroyed
# buildings
func set_building(coords: Vector2i, tile: int) -> void:
	assert(self.is_in_bounds(coords))
	assert(tile in CityMap.BUILDINGS or tile == self.INVALID_BUILDING)

	var building: Building = CityMap.BUILDINGS[tile]
	if building and not building.is_tile:
		# TODO move to place_building or other helper method
		for building_coords in building.get_cells(coords):
			self.world_map[building_coords.x][building_coords.y] = self.building_index
			# Hide the empty tiles behind the building by setting them to invalid
			super.set_cell(0, building_coords, -1)
		self.building_types.append(tile)
		self.building_roots.append(coords)
		self.building_index += 1
		return

	self.world_map[coords.x][coords.y] = tile

	# Update autotiling (assumes all tiles are roads)
	if building != null:
		super.set_cells_terrain_connect(
			0,
			[coords],
			CityMap.ROAD_TERRAIN_SET,
			CityMap.ROAD_TERRAIN
		)
		return

	# We're removing this tile, so update the autotiling of all surrounding
	# tiles, as it's not done automatically
	var terrain_cells: Array[Vector2i] = []
	super.set_cell(0, coords, tile, CityMap.EMPTY_COORDS)
	for orthogonal in self.get_orthogonal(coords):
		if self.get_type(self.get_building(orthogonal)) == BuildingType.ROAD:
			# Delete and recreate surrounding roads to force them to refresh
			# Only calling set_cells_terrain_connect is insufficient
			super.set_cell(0, orthogonal, tile, CityMap.EMPTY_COORDS)
			terrain_cells.append(orthogonal)
	super.set_cells_terrain_connect(
		0,
		terrain_cells,
		self.ROAD_TERRAIN_SET,
		self.ROAD_TERRAIN
	)


# Helper function to get a building's type (an index into the BUILDINGS array)
# from its ID
func get_type(id: int) -> BuildingType:
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
			var adjacent_id := self.get_building(adjacent_coords)
			if adjacent_id >= self.BASE_BUILDING_INDEX:
				var adjacent_building: Building = CityMap.BUILDINGS[self.get_type(adjacent_id)]
				if (
					not adjacent_building.is_tile
					and not adjacent.has(adjacent_id)
				):
					adjacent.append(adjacent_id)
	return adjacent


func _select_building(type: BuildingType) -> void:
	var building: Building = CityMap.BUILDINGS[type]
	if not building:
		return
	self.selected_building = type
	if not building.is_tile:
		self.preview_building.texture = building.texture
	self._update_preview()


func get_turn() -> int:
	return len(self.history)


func get_turns_remaining() -> int:
	return Global.num_turns - self.get_turn()


func is_game_over() -> bool:
	return not Global.endless and self.get_turns_remaining() == 0


func coords_to_screen_position(coords: Vector2i) -> Vector2:
	return (
		(self.map_to_local(coords) - self.camera.get_screen_center_position()) * self.camera.zoom
		+ self.get_viewport_rect().size / 2
	)


func get_building_sprite(id: int) -> Sprite2D:
	return self.buildings_node.get_node("building_%d" % id) as Sprite2D


# Returns the buildings connected by road to the given building
func get_road_connections(coords: Vector2i, type: BuildingType) -> Array[int]:
	var building: Building = CityMap.BUILDINGS[type]
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
	var turns_remaining := self.get_turns_remaining()


func _update_mouse_coords() -> void:
	self.mouse_coords = self.local_to_map(self.get_local_mouse_position())


func _clear_preview() -> void:
	if self.preview_coords != self.INVALID_COORDS:
		#self.set_building(self.preview_coords, 0)
		self.preview_coords = self.INVALID_COORDS
		self.preview_area.clear()
		self.preview_tile.clear()
		self.preview_building.visible = false
		self.preview_label.text = ""
		self.preview_node.visible = false
		for modulated_building in self.modulated_buildings:
			var sprite := self.get_building_sprite(modulated_building)
			if sprite != null and not sprite.is_queued_for_deletion():
				sprite.modulate = Color.WHITE
		self.modulated_buildings.clear()


# Modulates the building with the given ID based on its interaction with the
# given building type
# id is the modulated building's ID, building is what it's modulated relative to
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
		modulation = self.good_color
	elif (
		(gp_interaction < 0 and vp_interaction <= 0)
		or (gp_interaction <= 0 and vp_interaction < 0)
	):
		modulation = self.bad_color
	elif (
		(gp_interaction < 0 and vp_interaction > 0)
		or (gp_interaction > 0 and vp_interaction < 0)
	):
		modulation = self.mixed_color
	else:
		modulation = self.default_color

	self.get_building_sprite(id).modulate = modulation
	self.modulated_buildings.append(id)


func _update_preview() -> void:
	self._clear_preview()
	self.preview_node.visible = true
	self.preview_coords = self.mouse_coords
	var building: Building = CityMap.BUILDINGS[self.selected_building]
	var building_coords: Vector2i = self.preview_coords - building.get_cell_offset()

	# Move the building preview
	self.preview_building.position = self.map_to_local(building_coords)
	if building.is_tile:
		self.preview_tile.set_cells_terrain_connect(
			0,
			[building_coords],
			self.ROAD_TERRAIN_SET,
			self.ROAD_TERRAIN
		)
	else:
		self.preview_building.visible = true

	# Shade preview building in red if the placement is blocked
	if building.is_tile:
		self.preview_tile.modulate = self.default_color
		if self.get_building(building_coords) != 0:
			self.preview_tile.modulate = self.invalid_color
	else:
		self.preview_building.modulate = self.default_color
		for coords in building.get_cells(building_coords):
			if self.get_building(coords) != 0:
				self.preview_building.modulate = self.invalid_color
				break

	# Show area of current building with a 50% opacity white square
	for coords in building.get_area_cells(building_coords):
		self.preview_area.set_cell(0, coords, 0, CityMap.SELECTION_COORDS)
		var id := self.get_building(coords)
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
			self.preview_tile.modulate = self.invalid_color
		else:
			self.preview_building.modulate = self.invalid_color


# Gets the total value that would result from placing the building with the
# given ID at the given coords, returned in the form [gp, vp]
# Includes the building's flat GP and VP, as well as interactions
func get_building_value(
	coords: Vector2i,
	type: BuildingType,
	get_road_connections := true,
	road_connections: Array[int] = []
) -> Array[int]:
	var building: Building = CityMap.BUILDINGS[type]
	var gp_value := building.gp
	var vp_value := building.vp
	var counted_ids: Array[int] = []
	var occupied_cells := building.get_cells(coords)

	# Account for nearby buildings
	for area_coords in building.get_area_cells(coords):
		# Ignore the exact cells where the building is being placed
		if occupied_cells.has(area_coords):
			continue

		var neighbor_id := self.get_building(area_coords)
		if counted_ids.has(neighbor_id):
			continue
		counted_ids.append(neighbor_id)

		var neighbor_type := self.get_type(neighbor_id)
		gp_value += building.gp_interactions.get(neighbor_type, 0)
		vp_value += building.vp_interactions.get(neighbor_type, 0)

	# Account for buildings connected via road
	if get_road_connections:
		assert(road_connections == [])
		road_connections = self.get_road_connections(coords, type)

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
	self.building_particles.amount = self.particles_amount
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
	self.building_particles.position = self.map_to_local(coords + size / 2)
	self.particles_material.emission_sphere_radius = size.length() / 2
	self.building_particles.amount = self.particles_amount * multiplier
	self.particles_material.scale_min = self.particles_scale * multiplier
	self.particles_material.scale_max = self.particles_scale * multiplier
	self.particles_material.initial_velocity_min = self.particles_velocity * multiplier
	self.particles_material.initial_velocity_max = self.particles_velocity * multiplier
	self.particles_material.linear_accel_min = self.particles_accel * multiplier
	self.particles_material.linear_accel_max = self.particles_accel * multiplier
	self.building_particles.restart()


func place_building(coords: Vector2i, type: BuildingType, force := false) -> Placement:
	var building: Building = CityMap.BUILDINGS[type]

	# Prevent placement if building overlaps any existing buildings
	for building_coords in building.get_cells(coords):
		if self.get_type(self.get_building(building_coords)) != 0:
			return null

	# Check if building can be built in the first place
#	if self.gp + floor(building.gp) < 0:
#		return null

	# Give GP based on nearby buildings
	var building_value := self.get_building_value(coords, type)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if self.gp + gp_change < 0 and not force:
		return null

	self.building_place_sound.play()
	self.emit_particles(coords, building)

	var neighbor_groups: Array[int] = []
	if building.groupable:
		for neighbor in get_orthogonal(coords):
			var neighbor_type := get_type(get_building(neighbor))
			if neighbor_type == type:
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
		self.buildings_node.add_child(instance)

	self.set_building(coords, type)
	return Placement.new(type, coords, gp_change, vp_change, neighbor_groups)


func destroy_building(coords: Vector2i, type: BuildingType = self.INVALID_BUILDING) -> void:
	# If an ID is given, use it to offset the coords, ensuring that we won't
	# select part of the building with empty space
	# DON'T supply an ID if the coords is already a tile the building occupies
	# Use it for deletion where you only know the root coords
	# There may be an edge case for a building with an empty center (e.g. a 3x3
	# donut-shaped building)
	if type != self.INVALID_BUILDING:
		coords += CityMap.BUILDINGS[type].get_cell_offset()
	var id := self.get_building(coords)
	if id == self.INVALID_BUILDING:
		return

	var is_tile: bool = id < self.BASE_BUILDING_INDEX

	if is_tile:
		type = id
	else:
		# If this isn't a tile building, free its sprite
		var instance := self.get_building_sprite(id)
		if instance and not instance.is_queued_for_deletion():
			instance.free()
		type = self.building_types[id]
	var building: Building = CityMap.BUILDINGS[type]

	self.building_destroy_sound.play()
	self.emit_particles(coords - building.get_cell_offset(), building)

	var root := coords
	if is_tile:
		self.set_building(coords, 0)
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
			self.set_building(building_coords, 0)
			self.groups[building_coords.x][building_coords.y] = 0

		var adjacent_groups: Array[int] = []
		for adjacent_coords in building.get_adjacent_cells(root):
			var group := self.get_base_group(self.get_group(adjacent_coords))
			if group >= self.BASE_GROUP_INDEX and not adjacent_groups.has(group):
				self.adjacent_buildings[group].erase(id)


func _on_palette_building_selected(id: BuildingType) -> void:
	self._select_building(id)

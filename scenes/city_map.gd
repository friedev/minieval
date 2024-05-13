class_name CityMap extends TileMap

signal gp_changed(gp: int)
signal vp_changed(vp: int)
signal game_over
signal turn_changed(turn: int)


class Placement:
	var building_type: BuildingType
	var coords: Vector2i
	var gp_change: int
	var vp_change: int
	var group_joins: Array[int]

	func _init(
		building_type: BuildingType,
		coords: Vector2i,
		gp_change: int,
		vp_change: int,
		group_joins: Array[int]
	):
		self.building_type = building_type
		self.coords = coords
		self.gp_change = gp_change
		self.vp_change = vp_change
		self.group_joins = group_joins


const INVALID_COORDS := Vector2i(-1, -1)
const EMPTY_COORDS := Vector2i(0, 0)
const SELECTION_COORDS := Vector2i(1, 0)

const INVALID_BUILDING_INDEX := -1
const EMPTY_BUILDING_INDEX := 0
const ROAD_BUILDING_INDEX := 1
const FIRST_BUILDING_INDEX := 2 # First unused index

const INVALID_GROUP := -1
const NO_GROUP := -1
const FIRST_GROUP := 1

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

# Maps a cell to its building index
# Each index uniquely identifies a building, except for tile buildings, which
# all share the same index
var world_map: Array[Array] = [] # Array[Array[int]]
# Maps a building index to its type
# Content starts at FIRST_BUILDING_INDEX, everything before that is null
var building_types: Array[BuildingType] = []
# Maps a building index to its root (top left) coords
# Content starts at FIRST_BUILDING_INDEX, everything before that is null
var building_roots: Array[Vector2i] = []
# Maps a cell to its group
var groups: Array[Array] = [] # Array[Array[int]]
# Maps a group to the group it has been merged into (another group)
# A root group will map to its own index
# Recursively indexing into this array will get you to a root
var group_joins: Array[int] = []
# Maps a group to the list of building indices adjacent to the group
var adjacent_buildings: Array[Array] = [] # Array[Array[int]]

var building_index := self.FIRST_BUILDING_INDEX
var group_index := self.FIRST_GROUP

var gp: int:
	set(value):
		gp = value
		self.gp_changed.emit(self.gp)

var vp: int:
	set(value):
		vp = value
		self.vp_changed.emit(self.vp)

var selected_building_type: BuildingType

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

	for i in range(self.FIRST_BUILDING_INDEX):
		self.building_types.append(null)
		self.building_roots.append(self.INVALID_COORDS)
	self.building_types[self.ROAD_BUILDING_INDEX] = preload("res://scenes/building_types/road.tres")

	for i in range(self.FIRST_GROUP):
		self.groups.append([])
		self.group_joins.append(self.INVALID_GROUP)
		self.adjacent_buildings.append([])


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
	self.get_viewport().warp_mouse(self.get_viewport().get_mouse_position() + mouse_velocity)

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

		var placement: Placement = self.place_building(
			self.mouse_coords + self.selected_building_type.offset,
			self.selected_building_type,
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
		self.destroy_building(prev_placement.coords, prev_placement.building_type)
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
		self.place_building(next_placement.coords, next_placement.building_type, true)
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


# Return the building index at the given coords
func get_building_index(coords: Vector2i) -> int:
	if not self.is_in_bounds(coords):
		return self.INVALID_BUILDING_INDEX
	return self.world_map[coords.x][coords.y]


# Updates world map, building types, and building roots where applicable
# Does NOT spawn a building sprite, update groups, or fully clean up destroyed
# buildings
func set_building_type(coords: Vector2i, building_type: BuildingType) -> void:
	assert(self.is_in_bounds(coords))

	if building_type != null and not building_type.is_tile:
		for building_coords in building_type.get_cells(coords):
			self.world_map[building_coords.x][building_coords.y] = self.building_index
			# Hide the empty tiles behind the building by setting them to invalid
			super.set_cell(0, building_coords, -1)
		self.building_types.append(building_type)
		self.building_roots.append(coords)
		self.building_index += 1
		return

	# Update autotiling (assumes all tiles are terrains)
	if building_type != null:
		# Assumes all tiles are roads
		self.world_map[coords.x][coords.y] = self.ROAD_BUILDING_INDEX
		super.set_cells_terrain_connect(
			0,
			[coords],
			building_type.terrain_set,
			building_type.terrain
		)
		return

	# We're removing this tile, so update the autotiling of all surrounding
	# tiles, as it's not done automatically
	self.world_map[coords.x][coords.y] = self.EMPTY_BUILDING_INDEX
	var terrain_cells: Array[Vector2i] = []
	super.set_cell(0, coords, 0, CityMap.EMPTY_COORDS)
	for orthogonal_coords in self.get_orthogonal(coords):
		var orthogonal_building_index := self.get_building_index(orthogonal_coords)
		var orthogonal_building_type := self.get_building_type(orthogonal_building_index)
		if orthogonal_building_type != null and orthogonal_building_type.is_tile:
			# Delete and recreate surrounding terrains to force them to refresh
			# Only calling set_cells_terrain_connect is insufficient
			super.set_cell(0, orthogonal_coords, 0, CityMap.EMPTY_COORDS)
			super.set_cells_terrain_connect(
				0,
				[orthogonal_coords],
				orthogonal_building_type.terrain_set,
				orthogonal_building_type.terrain
			)


# Helper function to get a building's type (an index into the BUILDINGS array)
# from its index
func get_building_type(building_index: int) -> BuildingType:
	if building_index <= self.EMPTY_BUILDING_INDEX:
		return null
	return self.building_types[building_index]


func get_group(coords: Vector2i) -> int:
	if (
		coords.x < 0 or coords.x >= len(self.world_map)
		or coords.y < 0 or coords.y >= len(self.world_map[coords.x])
	):
		return self.INVALID_GROUP
	return self.groups[coords.x][coords.y]


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_root_group(group: int) -> int:
	if group < self.FIRST_GROUP or group >= len(self.groups):
		return self.INVALID_GROUP
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
	adjacent_buildings: Array[int] = [],
	visited: Array[Vector2i] = []
) -> Array[int]:
	var group := self.get_root_group(self.get_group(coords))
	if group < self.FIRST_GROUP:
		return []
	visited.append(coords)
	for adjacent_coords in self.get_orthogonal(coords):
		var adjacent_group := self.get_root_group(self.get_group(adjacent_coords))
		if adjacent_group == group:
			if not visited.has(adjacent_coords):
				adjacent_buildings = self.get_adjacent_buildings(
					adjacent_coords,
					adjacent_buildings,
					visited
				)
		else:
			var adjacent_id := self.get_building_index(adjacent_coords)
			if adjacent_id >= self.FIRST_BUILDING_INDEX:
				var adjacent_building_type: BuildingType = self.get_building_type(adjacent_id)
				if (
					not adjacent_building_type.is_tile
					and not adjacent_buildings.has(adjacent_id)
				):
					adjacent_buildings.append(adjacent_id)
	return adjacent_buildings


func select_building_type(building_type: BuildingType) -> void:
	self.selected_building_type = building_type
	if not building_type.is_tile:
		self.preview_building.texture = building_type.texture
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


func get_building_sprite(building_index: int) -> Sprite2D:
	return self.buildings_node.get_node("building_%d" % building_index) as Sprite2D


# Returns the buildings connected by road to the given building
func get_road_connections(coords: Vector2i, building_type: BuildingType) -> Array[int]:
	var road_connections: Array[int] = []
	var counted_groups: Array[int] = []
	for adjacent_coords in building_type.get_adjacent_cells(coords):
		if not self.is_in_bounds(adjacent_coords):
			continue
		var adjacent_group := self.get_root_group(self.get_group(adjacent_coords))
		if (
			adjacent_group >= self.FIRST_GROUP
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
		#self.set_building_type(self.preview_coords, 0)
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


# Modulate the "to" building based on the interaction the "from" building has
# with it
# The "from" building is being placed and we want to highlight the "to" building
# to show whether it's good or bad that's it next to the "from" building
func modulate_building(
	from_building_type: BuildingType,
	to_building_index: int,
	road_connection: bool
) -> void:
	if to_building_index < self.FIRST_BUILDING_INDEX:
		return

	var to_building_type := self.get_building_type(to_building_index)
	var gp_interaction: int = from_building_type.gp_interactions.get(to_building_type.key, 0)
	var vp_interaction: int = (
		0
		if road_connection
		else from_building_type.vp_interactions.get(to_building_type.key, 0)
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

	self.get_building_sprite(to_building_index).modulate = modulation
	self.modulated_buildings.append(to_building_index)


func _update_preview() -> void:
	self._clear_preview()
	if self.selected_building_type == null:
		return
	self.preview_node.visible = true
	self.preview_coords = self.mouse_coords
	var building_coords: Vector2i = self.preview_coords + self.selected_building_type.offset

	# Move the building preview
	self.preview_building.position = self.map_to_local(building_coords)
	if self.selected_building_type.is_tile:
		self.preview_tile.set_cells_terrain_connect(
			0,
			[building_coords],
			self.selected_building_type.terrain_set,
			self.selected_building_type.terrain
		)
	else:
		self.preview_building.visible = true

	# Shade preview building in red if the placement is blocked
	if self.selected_building_type.is_tile:
		self.preview_tile.modulate = self.default_color
		if self.get_building_index(building_coords) != 0:
			self.preview_tile.modulate = self.invalid_color
	else:
		self.preview_building.modulate = self.default_color
		for coords in self.selected_building_type.get_cells(building_coords):
			if self.get_building_index(coords) != 0:
				self.preview_building.modulate = self.invalid_color
				break

	# Show area of current building with a 50% opacity white square
	for coords in self.selected_building_type.get_area_cells(building_coords):
		self.preview_area.set_cell(0, coords, 0, CityMap.SELECTION_COORDS)
		var building_index := self.get_building_index(coords)
		self.modulate_building(self.selected_building_type, building_index, false)

	var road_connections := self.get_road_connections(building_coords, self.selected_building_type)
	for connected_building in road_connections:
		if not self.modulated_buildings.has(connected_building):
			self.modulate_building(self.selected_building_type, connected_building, true)

	# Update preview label with expected building value
	var value := self.get_building_value(
		building_coords,
		self.selected_building_type,
		false,
		road_connections
	)
	self.preview_label.text = "%s\n%s" % self.format_value(value)
	self.preview_node.position = self.coords_to_screen_position(
		Vector2i(self.preview_coords.x, building_coords.y)
	)
	self.preview_node.position.y -= self.tile_set.tile_size.y / 2 * self.camera.zoom.y

	# Shade preview building in red if you can't afford to place it
	if value[0] + self.gp < 0:
		if self.selected_building_type.is_tile:
			self.preview_tile.modulate = self.invalid_color
		else:
			self.preview_building.modulate = self.invalid_color


# Gets the total value that would result from placing the building with the
# given ID at the given coords, returned in the form [gp, vp]
# Includes the building's flat GP and VP, as well as interactions
func get_building_value(
	coords: Vector2i,
	building_type: BuildingType,
	get_road_connections := true,
	road_connections: Array[int] = []
) -> Array[int]:
	var gp_value := building_type.gp
	var vp_value := building_type.vp
	var counted_building_indices: Array[int] = []
	var occupied_cells := building_type.get_cells(coords)

	# Account for nearby buildings
	for area_coords in building_type.get_area_cells(coords):
		# Ignore the exact cells where the building is being placed
		if occupied_cells.has(area_coords):
			continue

		var neighbor_building_index := self.get_building_index(area_coords)
		if counted_building_indices.has(neighbor_building_index):
			continue
		counted_building_indices.append(neighbor_building_index)

		var neighbor_building_type := self.get_building_type(neighbor_building_index)
		if neighbor_building_type != null:
			gp_value += building_type.gp_interactions.get(neighbor_building_type.key, 0)
			vp_value += building_type.vp_interactions.get(neighbor_building_type.key, 0)

	# Account for buildings connected via road
	if get_road_connections:
		assert(road_connections == [])
		road_connections = self.get_road_connections(coords, building_type)

	for connected_building_index in road_connections:
		if not connected_building_index in counted_building_indices:
			counted_building_indices.append(connected_building_index)
			# Only add gp value
			var connected_building_type := self.get_building_type(connected_building_index)
			gp_value += building_type.gp_interactions.get(connected_building_type.key, 0)

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


func emit_particles(coords: Vector2i, building_type: BuildingType) -> void:
	if building_type.is_tile:
		return

	self.reset_particles()

	# TODO better building size bounding
	var size := Vector2(building_type.area.size) / 3
	var multiplier := sqrt((size.x + size.y) / 2.0) * 1.25
	self.building_particles.position = self.map_to_local(Vector2i(Vector2(coords) + size / 2))
	self.particles_material.emission_sphere_radius = size.length() / 2
	self.building_particles.amount = self.particles_amount * multiplier
	self.particles_material.scale_min = self.particles_scale * multiplier
	self.particles_material.scale_max = self.particles_scale * multiplier
	self.particles_material.initial_velocity_min = self.particles_velocity * multiplier
	self.particles_material.initial_velocity_max = self.particles_velocity * multiplier
	self.particles_material.linear_accel_min = self.particles_accel * multiplier
	self.particles_material.linear_accel_max = self.particles_accel * multiplier
	self.building_particles.restart()


func place_building(
	coords: Vector2i,
	building_type: BuildingType,
	force := false
) -> Placement:
	# Prevent placement if building overlaps any existing buildings
	for building_coords in building_type.get_cells(coords):
		if self.get_building_type(self.get_building_index(building_coords)) != null:
			return null

	# Give GP based on nearby buildings
	var building_value := self.get_building_value(coords, building_type)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if self.gp + gp_change < 0 and not force:
		return null

	self.building_place_sound.play()
	self.emit_particles(coords, building_type)

	var neighbor_groups: Array[int] = []
	# Assumes all tiles are groupable
	if building_type.is_tile:
		for neighbor in get_orthogonal(coords):
			var neighbor_type := self.get_building_type(self.get_building_index(neighbor))
			if neighbor_type == building_type:
				neighbor_groups.append(self.get_root_group(self.get_group(neighbor)))
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
		for adjacent_coords in building_type.get_adjacent_cells(coords):
			if not self.is_in_bounds(adjacent_coords):
				continue
			var group := self.get_root_group(self.get_group(adjacent_coords))
			if group >= self.FIRST_GROUP and not adjacent_groups.has(group):
				adjacent_groups.append(group)
				self.adjacent_buildings[group].append(self.building_index)

	# Instance a new sprite if this building is not a tile
	if not building_type.is_tile:
		var instance: Sprite2D = self.building_scene.instantiate()
		instance.position = self.map_to_local(coords)
		instance.texture = building_type.texture
		instance.set_name("building_%d" % self.building_index)
		self.buildings_node.add_child(instance)

	self.set_building_type(coords, building_type)
	return Placement.new(building_type, coords, gp_change, vp_change, neighbor_groups)


func destroy_building(coords: Vector2i, building_type: BuildingType = null) -> void:
	# If an ID is given, use it to offset the coords, ensuring that we won't
	# select part of the building with empty space
	# DON'T supply an ID if the coords is already a tile the building occupies
	# Use it for deletion where you only know the root coords
	# There may be an edge case for a building with an empty center (e.g. a 3x3
	# donut-shaped building)
	if building_type == null:
		coords -= building_type.offset
	var building_index := self.get_building_index(coords)
	assert(building_index != self.INVALID_BUILDING_INDEX)
	if building_type == null:
		building_type = self.building_types[building_index]
		assert(building_type != null)

	if not building_type.is_tile:
		# If this isn't a tile building, free its sprite
		var instance := self.get_building_sprite(building_index)
		if instance != null and not instance.is_queued_for_deletion():
			instance.free()
		building_type = self.building_types[building_index]

	self.building_destroy_sound.play()
	self.emit_particles(coords + building_type.offset, building_type)

	var root := coords
	if building_type.is_tile:
		self.set_building_type(coords, null)
		self.groups[coords.x][coords.y] = 0

		var adjacent_groups: Array[int] = []
		for adjacent_coords in self.get_orthogonal(coords):
			var group := self.get_root_group(self.get_group(adjacent_coords))
			if group >= self.FIRST_GROUP and not adjacent_groups.has(group):
				self.adjacent_buildings[group] = self.get_adjacent_buildings(adjacent_coords)
	else:
		# Reset all cells (in the world map and groups) occupied by this building
		# Does NOT modify the group_joins array; currently handled by the undo code
		root = self.building_roots[building_index]
		for building_coords in building_type.get_cells(root):
			self.set_building_type(building_coords, null)
			self.groups[building_coords.x][building_coords.y] = 0

		var adjacent_groups: Array[int] = []
		for adjacent_coords in building_type.get_adjacent_cells(root):
			if not self.is_in_bounds(adjacent_coords):
				continue
			var group := self.get_root_group(self.get_group(adjacent_coords))
			if group >= self.FIRST_GROUP and not adjacent_groups.has(group):
				self.adjacent_buildings[group].erase(building_index)


func _on_palette_building_selected(building_type: BuildingType) -> void:
	self.select_building_type(building_type)

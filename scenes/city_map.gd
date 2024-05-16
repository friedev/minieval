class_name CityMap extends TileMap

signal gp_changed(gp: int)
signal vp_changed(vp: int)
signal game_over
signal turn_changed(turn: int)

class Placement:
	var building: Building
	var gp_change: int
	var vp_change: int
	var group_joins: Array[int]

const INVALID_COORDS := Vector2i(-1, -1)
const EMPTY_COORDS := Vector2i(0, 0)
const SELECTION_COORDS := Vector2i(1, 0)

const INVALID_GROUP := -1
const NO_GROUP := -1
const FIRST_GROUP := 1

const building_sprite_scene := preload("res://scenes/building_sprite.tscn")

@export_group("Action Repeat")
## Initial action repeat wait time.
@export var initial_wait_time: float
## Final action repeat wait time, after a certain number of action repeats.
@export var final_wait_time: float
## The number of actions it will take for the wait time to go from the initial
## to the final wait time, changing linearly along the way.
@export var actions_until_final_wait_time: int

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
@export var input_repeat_timer: Timer

# Maps a cell to the building occupying that cell
var building_map := {} # Dictionary[Vector2i, Building]
# Maps a group to the group it has been merged into (another group)
# A root group will map to its own index
# Recursively indexing into this array will get you to a root
var group_joins: Array[int] = []
# Maps a group to the list of buildings adjacent to the group
var adjacent_buildings: Array[Array] = [] # Array[Array[Building]]

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

var action_to_repeat: StringName

var mouse_coords := self.INVALID_COORDS
var preview_coords := self.INVALID_COORDS
var modulated_buildings: Array[Building] = []
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

	for x in range(Global.game_size):
		for y in range(Global.game_size):
			super.set_cell(0, Vector2i(x, y), 0, CityMap.EMPTY_COORDS)

	self.camera.position = self.map_to_local(
		Vector2(Global.game_size / 2, Global.game_size / 2)
	) - self.camera.offset

	for i in range(self.FIRST_GROUP):
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
	self.move_mouse(self.get_viewport().get_mouse_position() + mouse_velocity)

	if not Global.is_menu_open:
		self.update_mouse()
	else:
		self._clear_preview()


func update_mouse() -> void:
	self._update_mouse_coords()
	# Update the preview if the mouse has moved to a different cell
	if self.mouse_coords != self.preview_coords:
		if Input.is_action_pressed(&"place_building"):
			self.handle_place_building_input(false)
		self._update_preview()


func move_mouse(mouse_position: Vector2) -> void:
	self.get_viewport().warp_mouse(mouse_position)
	self.update_mouse()


func select_cell(coords: Vector2i) -> bool:
	if self.is_in_bounds(coords):
		self.move_mouse(self.coords_to_screen_position(coords))
		return true
	return false


func handle_place_building_input(error_sound := true) -> bool:
	self._clear_preview()

	var placement: Placement = self.place_building(
		self.mouse_coords + self.selected_building_type.offset,
		self.selected_building_type,
	)

	if placement != null:
		self.gp += placement.gp_change
		self.vp += placement.vp_change
		self.history.append(placement)
		self.future.clear()
		self.turn_changed.emit(self.get_turn())
		self._update_labels()
		if self.is_game_over():
			self.game_over.emit()
		return true
	else:
		if error_sound:
			self.building_place_error_sound.play()
		return false


# Returns true if the action should be repeated
# This usually means the action was successful
func handle_action(action: StringName) -> bool:
	match action:
		&"place_building":
			# Don't try to repeat placing a building, since it will never work
			self.handle_place_building_input()
			return false
		&"undo":
			return self.undo()
		&"redo":
			return self.redo()
		&"select_cell_left":
			return self.select_cell(self.mouse_coords + Vector2i.LEFT)
		&"select_cell_right":
			return self.select_cell(self.mouse_coords + Vector2i.RIGHT)
		&"select_cell_up":
			return self.select_cell(self.mouse_coords + Vector2i.UP)
		&"select_cell_down":
			return self.select_cell(self.mouse_coords + Vector2i.DOWN)
		_:
			push_error("Unknown action %s" % action)
			return false


func _unhandled_input(event: InputEvent) -> void:
	for action in [
		&"place_building",
		&"undo",
		&"redo",
		&"select_cell_left",
		&"select_cell_right",
		&"select_cell_up",
		&"select_cell_down",
	]:
		if event.is_action_pressed(action):
			if self.handle_action(action):
				self.action_to_repeat = action
				self.input_repeat_timer.start(self.initial_wait_time)


func undo() -> bool:
	self._clear_preview()
	var prev_placement: Placement = self.history.pop_back()
	if not prev_placement:
		return false

	self.destroy_building(prev_placement.building)
	self.gp -= prev_placement.gp_change
	self.vp -= prev_placement.vp_change
	for join in prev_placement.group_joins:
		self.group_joins[join] = join
	self.future.append(prev_placement)
	self.turn_changed.emit(self.get_turn())
	self._update_labels()
	return true


func redo() -> bool:
	self._clear_preview()
	var next_placement: Placement = self.future.pop_back()
	if not next_placement:
		return false

	# Can't reuse next_placement, since its Building object will have a
	# reference to a freed sprite
	var new_placement := self.place_building(
		next_placement.building.coords,
		next_placement.building.type
	)
	self.gp += next_placement.gp_change
	self.vp += next_placement.vp_change
	self.history.append(new_placement)
	self.turn_changed.emit(self.get_turn())
	self._update_labels()
	return true


func is_in_bounds(coords: Vector2i) -> bool:
	return (
		coords.x >= 0
		and coords.x < Global.game_size
		and coords.y >= 0
		and coords.y < Global.game_size
	)


# Wrapper for building_map.get to provide static typing
func get_building(coords: Vector2i) -> Building:
	return self.building_map.get(coords)


# Is the cell occupied by a building (tile or non-tile)?
func is_occupied(coords: Vector2i) -> bool:
	return coords in self.building_map


# Is the cell open for a building to be placed in?
func is_open(coords: Vector2i) -> bool:
	return self.is_in_bounds(coords) and not self.is_occupied(coords)


func get_group(coords: Vector2i) -> int:
	var building := self.get_building(coords)
	if building == null:
		return self.INVALID_GROUP
	return building.group


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_root_group(group: int) -> int:
	if group < self.FIRST_GROUP or group >= len(self.group_joins):
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


# Returns a list of all buildings adjacent to a group, starting at given tile
# Uses a recursive depth-first search
func get_adjacent_buildings(
	coords: Vector2i,
	adjacent_buildings: Array[Building] = [],
	visited: Array[Vector2i] = []
) -> Array[Building]:
	var group := self.get_root_group(self.get_group(coords))
	if group < self.FIRST_GROUP:
		return []
	visited.append(coords)
	for adjacent_coords in self.get_orthogonal(coords):
		var adjacent_group := self.get_root_group(self.get_group(adjacent_coords))
		if adjacent_group == group:
			if not adjacent_coords in visited:
				adjacent_buildings = self.get_adjacent_buildings(
					adjacent_coords,
					adjacent_buildings,
					visited
				)
		else:
			var adjacent_building := self.get_building(adjacent_coords)
			if adjacent_building != null and not adjacent_building in adjacent_buildings:
				adjacent_buildings.append(adjacent_building)
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


# Returns the buildings connected by road to the given building
func get_road_connections(coords: Vector2i, building_type: BuildingType) -> Array[Building]:
	var road_connections: Array[Building] = []
	var counted_groups: Array[int] = []
	for adjacent_coords in building_type.get_adjacent_cells(coords):
		if not self.is_in_bounds(adjacent_coords):
			continue
		var adjacent_group := self.get_root_group(self.get_group(adjacent_coords))
		if (
			adjacent_group >= self.FIRST_GROUP
			and not adjacent_group in counted_groups
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
		self.preview_coords = self.INVALID_COORDS
		self.preview_area.clear()
		self.preview_tile.clear()
		self.preview_building.visible = false
		self.preview_label.text = ""
		self.preview_node.visible = false
		for modulated_building in self.modulated_buildings:
			modulated_building.sprite.modulate = Color.WHITE
		self.modulated_buildings.clear()


# Modulate the "to" building based on the interaction the "from" building has
# with it
# The "from" building is being placed and we want to highlight the "to" building
# to show whether it's good or bad that's it next to the "from" building
func modulate_building(
	from_building_type: BuildingType,
	to_building: Building,
	road_connection: bool
) -> void:
	assert(to_building != null)
	assert(to_building.sprite != null)

	var gp_interaction: int = from_building_type.gp_interactions.get(to_building.type.key, 0)
	var vp_interaction: int = (
		0
		if road_connection
		else from_building_type.vp_interactions.get(to_building.type.key, 0)
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

	to_building.sprite.modulate = modulation
	self.modulated_buildings.append(to_building)


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
	var blocked := false
	for coords in self.selected_building_type.get_cells(building_coords):
		if not self.is_open(coords):
			blocked = true
			break
	var modulate_color := self.invalid_color if blocked else self.default_color
	if self.selected_building_type.is_tile:
		self.preview_tile.modulate = modulate_color
	else:
		self.preview_building.modulate = modulate_color

	# Show area of current building with a 50% opacity white square
	for coords in self.selected_building_type.get_area_cells(building_coords):
		self.preview_area.set_cell(0, coords, 0, CityMap.SELECTION_COORDS)
		var building := self.get_building(coords)
		if building != null and building.sprite != null:
			self.modulate_building(self.selected_building_type, building, false)

	var road_connections := self.get_road_connections(building_coords, self.selected_building_type)
	for connected_building in road_connections:
		if not connected_building in self.modulated_buildings and connected_building.sprite != null:
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
	road_connections: Array[Building] = []
) -> Array[int]:
	var gp_value := building_type.gp
	var vp_value := building_type.vp
	var counted_buildings: Array[Building] = []
	var occupied_cells := building_type.get_cells(coords)

	# Account for nearby buildings
	for area_coords in building_type.get_area_cells(coords):
		# Ignore the exact cells where the building is being placed
		if area_coords in occupied_cells:
			continue

		var neighbor_building := self.get_building(area_coords)
		if neighbor_building != null and not neighbor_building in counted_buildings:
			counted_buildings.append(neighbor_building)
			gp_value += building_type.gp_interactions.get(neighbor_building.type.key, 0)
			vp_value += building_type.vp_interactions.get(neighbor_building.type.key, 0)

	# Account for buildings connected via road
	if get_road_connections:
		assert(road_connections == [])
		road_connections = self.get_road_connections(coords, building_type)

	for connected_building in road_connections:
		if not connected_building in counted_buildings:
			counted_buildings.append(connected_building)
			# Only add gp value
			gp_value += building_type.gp_interactions.get(connected_building.type.key, 0)

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


func place_building(coords: Vector2i, building_type: BuildingType) -> Placement:
	# Prevent placement if building overlaps any existing buildings
	for building_coords in building_type.get_cells(coords):
		if not self.is_open(building_coords):
			return null

	# Give GP based on nearby buildings
	var building_value := self.get_building_value(coords, building_type)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if self.gp + gp_change < 0:
		return null

	var building := Building.new()
	building.type = building_type
	building.coords = coords

	for building_coords in building_type.get_cells(coords):
		self.building_map[building_coords] = building
		# Hide the empty tiles behind the building by setting them to invalid
		super.set_cell(0, building_coords, -1)

	var neighbor_groups: Array[int] = []
	# Assumes all tiles are groupable with tiles of the same type
	if building_type.is_tile:
		for neighbor_coords in self.get_orthogonal(coords):
			var neighbor_building := self.get_building(neighbor_coords)
			if neighbor_building != null and neighbor_building.type == building_type:
				neighbor_groups.append(self.get_root_group(self.get_group(neighbor_coords)))
		# If no neighboring groups exist, make a new group
		if len(neighbor_groups) == 0:
			building.group = self.group_index
			self.group_joins.append(self.group_index)
			self.adjacent_buildings.append([])
			self.group_index += 1
		# If there's exactly one neighboring group, use that
		elif len(neighbor_groups) == 1:
			building.group = neighbor_groups[0]
		# If this tile bridges more than one group, join them all
		else:
			var joined_group: int = neighbor_groups.min()
			for group in neighbor_groups:
				self.group_joins[group] = joined_group
			building.group = joined_group

		# Update the list of buildings adjacent to the group
		self.adjacent_buildings[building.group] = self.get_adjacent_buildings(coords)
	else:
		# Update all adjacency lists to include this building
		building.group = self.INVALID_GROUP
		var adjacent_groups: Array[int] = []
		for adjacent_coords in building_type.get_adjacent_cells(coords):
			if not self.is_in_bounds(adjacent_coords):
				continue
			var group := self.get_root_group(self.get_group(adjacent_coords))
			if group >= self.FIRST_GROUP and not group in adjacent_groups:
				adjacent_groups.append(group)
				self.adjacent_buildings[group].append(building)

	# Update autotiling (assumes all tiles are terrains)
	if building_type.is_tile:
		super.set_cells_terrain_connect(
			0,
			[coords],
			building_type.terrain_set,
			building_type.terrain
		)
	# Instance a new Building scene
	else:
		var building_sprite: BuildingSprite = self.building_sprite_scene.instantiate()
		building_sprite.building = building
		building_sprite.position = self.map_to_local(coords)
		self.buildings_node.add_child(building_sprite)
		building.sprite = building_sprite

	self.building_place_sound.play()
	self.emit_particles(coords, building_type)

	var placement := Placement.new()
	placement.building = building
	placement.gp_change = gp_change
	placement.vp_change = vp_change
	placement.group_joins = neighbor_groups
	return placement


func destroy_building(building: Building) -> void:
	self.building_destroy_sound.play()
	self.emit_particles(building.coords + building.type.offset, building.type)

	# Reset all cells (in the world map and groups) occupied by this building
	# Does NOT modify the group_joins array; currently handled by the undo code
	for building_coords in building.type.get_cells(building.coords):
		self.building_map.erase(building_coords)
		super.set_cell(0, building_coords, 0, CityMap.EMPTY_COORDS)

	# Update the autotiling of all surrounding tiles, as it's not done automatically
	if building.type.is_tile:
		for orthogonal_coords in self.get_orthogonal(building.coords):
			var orthogonal_building := self.get_building(orthogonal_coords)
			if orthogonal_building != null and orthogonal_building.type.is_tile:
				# Delete and recreate surrounding terrains to force them to refresh
				# Only calling set_cells_terrain_connect is insufficient
				super.set_cell(0, orthogonal_coords, 0, CityMap.EMPTY_COORDS)
				super.set_cells_terrain_connect(
					0,
					[orthogonal_coords],
					orthogonal_building.type.terrain_set,
					orthogonal_building.type.terrain
				)

	var adjacent_groups: Array[int] = []
	for adjacent_coords in building.type.get_adjacent_cells(building.coords):
		var group := self.get_root_group(self.get_group(adjacent_coords))
		if group >= self.FIRST_GROUP and not group in adjacent_groups:
			if building.type.is_tile:
				self.adjacent_buildings[group] = self.get_adjacent_buildings(adjacent_coords)
			else:
				self.adjacent_buildings[group].erase(building)

	if building.sprite != null:
		building.sprite.queue_free()


func _on_palette_building_selected(building_type: BuildingType) -> void:
	self.select_building_type(building_type)


func _on_input_repeat_timer_timeout() -> void:
	if (
		Input.is_action_pressed(self.action_to_repeat)
		and self.handle_action(self.action_to_repeat)
	):
		var wait_time_delta := absf(
			(self.final_wait_time - self.initial_wait_time)
			/ self.actions_until_final_wait_time
		)
		var new_wait_time := move_toward(
			self.input_repeat_timer.wait_time,
			self.final_wait_time,
			wait_time_delta
		)
		self.input_repeat_timer.start(new_wait_time)

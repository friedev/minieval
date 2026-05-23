class_name CityMap
extends TileMapLayer

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
@export var gp_preview_label: Label
@export var vp_preview_label: Label
@export var preview_node: Container

@export_group("Internal Nodes")
@export var building_place_error_sound: AudioStreamPlayer
@export var building_place_sound: AudioStreamPlayer
@export var building_destroy_sound: AudioStreamPlayer
@export var buildings_node: Node2D
@export var preview_area: TileMapLayer
@export var preview_tile: TileMapLayer
@export var preview_building: Sprite2D
@export var building_particles: GPUParticles2D
@export var input_repeat_timer: Timer

# Maps a cell to the building occupying that cell
var building_map: Dictionary[Vector2i, Building] = { }
# Maps a group to the group it has been merged into (another group)
# A root group will map to its own index
# Recursively indexing into this array will get you to a root
var group_joins: Array[int] = []
# Maps a group to the list of buildings adjacent to the group
var adjacent_buildings: Array[Array] = [] # Array[Array[Building]]

var group_index := 0

var gp: int:
	set(value):
		gp = value
		gp_changed.emit(gp)

var vp: int:
	set(value):
		vp = value
		vp_changed.emit(vp)

var selected_building_type: BuildingType

var history: Array[Placement] = []
var future: Array[Placement] = []

var action_to_repeat: StringName

var mouse_coords := INVALID_COORDS
var preview_coords := INVALID_COORDS
var modulated_buildings: Array[Building] = []
var mouse_direction := Vector2.ZERO
## Mouse position needs updating?
var mouse_dirty := false

@onready var particles_material: ParticleProcessMaterial = building_particles.process_material
@onready var particles_amount := building_particles.amount
@onready var particles_scale := particles_material.scale_min
@onready var particles_velocity := particles_material.initial_velocity_min
@onready var particles_accel := particles_material.linear_accel_min


func _ready() -> void:
	gp = Global.initial_gp
	vp = 0

	_update_mouse_coords()
	_update_labels()

	for x in range(Global.game_size):
		for y in range(Global.game_size):
			super.set_cell(Vector2i(x, y), 0, CityMap.EMPTY_COORDS)

	camera.position = map_to_local(
		Vector2(Global.game_size / 2, Global.game_size / 2),
	) - camera.offset


func _process(delta: float) -> void:
	var mouse_input_direction := Input.get_vector(
		&"mouse_left",
		&"mouse_right",
		&"mouse_up",
		&"mouse_down",
	)
	if mouse_input_direction.is_zero_approx():
		mouse_direction = Vector2.ZERO
		# Update mouse position if dirty, even if it wasn't manually moved
		if mouse_dirty:
			update_mouse()
			# Always update preview just to be safe (could be optimized)
			_update_preview()
		return

	if (
		mouse_direction.is_zero_approx()
		or mouse_direction.angle_to(mouse_input_direction) > PI / 2
	):
		mouse_direction = mouse_input_direction * mouse_speed_min
	else:
		mouse_direction = mouse_direction.lerp(
			mouse_input_direction,
			mouse_acceleration * delta,
		)
	var mouse_velocity := mouse_direction * mouse_speed * delta
	move_mouse(get_viewport().get_mouse_position() + mouse_velocity)


func update_mouse() -> void:
	mouse_dirty = false
	_update_mouse_coords()
	# Update the preview if the mouse has moved to a different cell
	if mouse_coords != preview_coords:
		if Input.is_action_pressed(&"place_building"):
			handle_place_building_input(false)
		else:
			_update_preview()


func move_mouse(mouse_position: Vector2) -> void:
	get_viewport().warp_mouse(mouse_position)
	update_mouse()


func clamp_mouse_to_map() -> void:
	var coords := mouse_coords.clamp(Vector2.ZERO, Vector2.ONE * Global.game_size)
	move_mouse(coords_to_screen_position(coords))


func select_cell(coords: Vector2i) -> bool:
	if is_in_bounds(coords):
		move_mouse(coords_to_screen_position(coords))
		return true
	return false


func move_mouse_by_cell(delta: Vector2i) -> bool:
	clamp_mouse_to_map()
	return select_cell(mouse_coords + delta)


func handle_place_building_input(error_sound := true) -> bool:
	_clear_preview()

	var placement: Placement = place_building(
		mouse_coords + selected_building_type.offset,
		selected_building_type,
	)

	if placement != null:
		gp += placement.gp_change
		vp += placement.vp_change
		history.append(placement)
		future.clear()
		turn_changed.emit(get_turn())
		_update_labels()
		if is_game_over():
			game_over.emit()
		return true
	else:
		if error_sound:
			building_place_error_sound.play()
		return false


# Returns true if the action should be repeated
# This usually means the action was successful
func handle_action(action: StringName) -> bool:
	match action:
		&"place_building":
			# Don't try to repeat placing a building, since it will never work
			handle_place_building_input()
			return false
		&"undo":
			return undo()
		&"redo":
			return redo()
		&"select_cell_left":
			return move_mouse_by_cell(Vector2i.LEFT)
		&"select_cell_right":
			return move_mouse_by_cell(Vector2i.RIGHT)
		&"select_cell_up":
			return move_mouse_by_cell(Vector2i.UP)
		&"select_cell_down":
			return move_mouse_by_cell(Vector2i.DOWN)
		&"select_cell_left_up":
			return move_mouse_by_cell(Vector2i(-1, -1))
		&"select_cell_left_down":
			return move_mouse_by_cell(Vector2i(-1, +1))
		&"select_cell_right_up":
			return move_mouse_by_cell(Vector2i(+1, -1))
		&"select_cell_right_down":
			return move_mouse_by_cell(Vector2i(+1, +1))
		_:
			assert(false, "Unknown action %s" % action)
			return false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_mouse()

	for action in [
		&"place_building",
		&"undo",
		&"redo",
		&"select_cell_left",
		&"select_cell_right",
		&"select_cell_up",
		&"select_cell_down",
		&"select_cell_left_up",
		&"select_cell_left_down",
		&"select_cell_right_up",
		&"select_cell_right_down",
	]:
		if event.is_action_pressed(action):
			if handle_action(action):
				action_to_repeat = action
				input_repeat_timer.start(initial_wait_time)
				break


func undo() -> bool:
	_clear_preview()
	var prev_placement: Placement = history.pop_back()
	if not prev_placement:
		return false

	destroy_building(prev_placement.building)
	gp -= prev_placement.gp_change
	vp -= prev_placement.vp_change
	for join in prev_placement.group_joins:
		group_joins[join] = join
	future.append(prev_placement)
	turn_changed.emit(get_turn())
	_update_labels()
	return true


func redo() -> bool:
	_clear_preview()
	var next_placement: Placement = future.pop_back()
	if not next_placement:
		return false

	# Can't reuse next_placement, since its Building object will have a
	# reference to a freed sprite
	var new_placement := place_building(
		next_placement.building.coords,
		next_placement.building.type,
	)
	gp += next_placement.gp_change
	vp += next_placement.vp_change
	history.append(new_placement)
	turn_changed.emit(get_turn())
	_update_labels()
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
	return building_map.get(coords)


# Is the cell occupied by a building (tile or non-tile)?
func is_occupied(coords: Vector2i) -> bool:
	return coords in building_map


# Is the cell open for a building to be placed in?
func is_open(coords: Vector2i) -> bool:
	return is_in_bounds(coords) and not is_occupied(coords)


func get_group(coords: Vector2i) -> int:
	var building := get_building(coords)
	if building == null:
		return INVALID_GROUP
	return building.group


# Gets the base group of the given group by recursively indexing into the
# group_joins list until reaching a root
func get_root_group(group: int) -> int:
	if group < 0 or group >= len(group_joins):
		return INVALID_GROUP
	var join: int = group_joins[group]
	while join != group:
		group = join
		join = group_joins[group]
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
		visited: Array[Vector2i] = [],
) -> Array[Building]:
	var group := get_root_group(get_group(coords))
	if group < 0:
		return []
	visited.append(coords)
	for adjacent_coords in get_orthogonal(coords):
		var adjacent_group := get_root_group(get_group(adjacent_coords))
		if adjacent_group == group:
			if not adjacent_coords in visited:
				adjacent_buildings = get_adjacent_buildings(
					adjacent_coords,
					adjacent_buildings,
					visited,
				)
		else:
			var adjacent_building := get_building(adjacent_coords)
			if adjacent_building != null and not adjacent_building in adjacent_buildings:
				adjacent_buildings.append(adjacent_building)
	return adjacent_buildings


func select_building_type(building_type: BuildingType) -> void:
	selected_building_type = building_type
	if not building_type.is_tile:
		preview_building.texture = building_type.texture
	_update_preview()


func get_turn() -> int:
	return len(history)


func get_turns_remaining() -> int:
	return Global.num_turns - get_turn()


func is_game_over() -> bool:
	return not Global.endless and get_turns_remaining() == 0


func coords_to_screen_position(coords: Vector2i) -> Vector2:
	return (
		(map_to_local(coords) - camera.get_screen_center_position()) * camera.zoom
		+ get_viewport_rect().size / 2
	)


# Returns the buildings connected by road to the given building
func get_road_connections(coords: Vector2i, building_type: BuildingType) -> Array[Building]:
	var road_connections: Array[Building] = []
	var counted_groups: Array[int] = []
	for adjacent_coords in building_type.get_adjacent_cells(coords):
		if not is_in_bounds(adjacent_coords):
			continue
		var adjacent_group := get_root_group(get_group(adjacent_coords))
		if adjacent_group >= 0 and not adjacent_group in counted_groups:
			counted_groups.append(adjacent_group)
			for adjacent_building in adjacent_buildings[adjacent_group]:
				# Only add GP value
				road_connections.append(adjacent_building)
	return road_connections


# Updates the GP/VP label and turn label
func _update_labels() -> void:
	var turns_remaining := get_turns_remaining()


func _update_mouse_coords() -> void:
	mouse_coords = local_to_map(get_local_mouse_position())


func _clear_preview() -> void:
	if preview_coords != INVALID_COORDS:
		preview_coords = INVALID_COORDS
		preview_area.clear()
		preview_tile.clear()
		preview_building.visible = false
		gp_preview_label.text = ""
		vp_preview_label.text = ""
		preview_node.visible = false
		for modulated_building in modulated_buildings:
			modulated_building.sprite.modulate = Color.WHITE
		modulated_buildings.clear()


# Modulate the "to" building based on the interaction the "from" building has
# with it
# The "from" building is being placed and we want to highlight the "to" building
# to show whether it's good or bad that's it next to the "from" building
func modulate_building(
		from_building_type: BuildingType,
		to_building: Building,
		road_connection: bool,
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
		modulation = good_color
	elif (
		(gp_interaction < 0 and vp_interaction <= 0)
		or (gp_interaction <= 0 and vp_interaction < 0)
	):
		modulation = bad_color
	elif (
		(gp_interaction < 0 and vp_interaction > 0)
		or (gp_interaction > 0 and vp_interaction < 0)
	):
		modulation = mixed_color
	else:
		modulation = default_color

	to_building.sprite.modulate = modulation
	modulated_buildings.append(to_building)


func _update_preview() -> void:
	_clear_preview()
	if selected_building_type == null:
		return
	preview_node.visible = true
	preview_coords = mouse_coords
	var building_coords: Vector2i = preview_coords + selected_building_type.offset

	# Move the building preview
	preview_building.position = get_building_center(building_coords, selected_building_type)
	if selected_building_type.is_tile:
		preview_tile.set_cells_terrain_connect(
			[building_coords],
			selected_building_type.terrain_set,
			selected_building_type.terrain,
		)
	else:
		preview_building.visible = true

	# Shade preview building in red if the placement is blocked
	var blocked := false
	for coords in selected_building_type.get_cells(building_coords):
		if not is_open(coords):
			blocked = true
			break
	var modulate_color := invalid_color if blocked else default_color
	if selected_building_type.is_tile:
		preview_tile.modulate = modulate_color
	else:
		preview_building.modulate = modulate_color

	# Show area of current building with a 50% opacity white square
	for coords in selected_building_type.get_area_cells(building_coords):
		preview_area.set_cell(coords, 0, CityMap.SELECTION_COORDS)
		var building := get_building(coords)
		if building != null and building.sprite != null:
			modulate_building(selected_building_type, building, false)

	var road_connections := get_road_connections(building_coords, selected_building_type)
	for connected_building in road_connections:
		if not connected_building in modulated_buildings and connected_building.sprite != null:
			modulate_building(selected_building_type, connected_building, true)

	# Update preview labels with expected building value
	var value := get_building_value(
		building_coords,
		selected_building_type,
		false,
		road_connections,
	)
	var formatted_value := format_value(value)
	gp_preview_label.text = formatted_value[0]
	vp_preview_label.text = formatted_value[1]
	# Force fit to content
	preview_node.size = Vector2.ZERO
	preview_node.position = coords_to_screen_position(
		Vector2i(preview_coords.x, building_coords.y),
	)
	preview_node.position -= preview_node.size / 2
	preview_node.position.y -= 40

	# Shade preview building in red if you can't afford to place it
	if value[0] + gp < 0:
		if selected_building_type.is_tile:
			preview_tile.modulate = invalid_color
		else:
			preview_building.modulate = invalid_color


# Gets the total value that would result from placing the building with the
# given ID at the given coords, returned in the form [gp, vp]
# Includes the building's flat GP and VP, as well as interactions
func get_building_value(
		coords: Vector2i,
		building_type: BuildingType,
		get_road_connections := true,
		road_connections: Array[Building] = [],
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

		var neighbor_building := get_building(area_coords)
		if neighbor_building != null and not neighbor_building in counted_buildings:
			counted_buildings.append(neighbor_building)
			gp_value += building_type.gp_interactions.get(neighbor_building.type.key, 0)
			vp_value += building_type.vp_interactions.get(neighbor_building.type.key, 0)

	# Account for buildings connected via road
	if get_road_connections:
		assert(road_connections == [])
		road_connections = get_road_connections(coords, building_type)

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


## Gets the pixel position of the center of the given building type.
func get_building_center(coords: Vector2i, building_type: BuildingType) -> Vector2:
	return map_to_local(coords) + Rect2(building_type.bounds).get_center() * Vector2(tile_set.tile_size)


func reset_particles() -> void:
	building_particles.amount = particles_amount
	particles_material.scale_min = particles_scale
	particles_material.scale_max = particles_scale
	particles_material.initial_velocity_min = particles_velocity
	particles_material.initial_velocity_max = particles_velocity
	particles_material.linear_accel_min = particles_accel
	particles_material.linear_accel_max = particles_accel


func emit_particles(coords: Vector2i, building_type: BuildingType) -> void:
	if building_type.is_tile:
		return

	reset_particles()

	# Technically, the size of the bounds of a one-tile building (e.g. house) is
	# 0, so set a minimum size for particle emission purposes
	var size := Vector2(building_type.bounds.size).max(Vector2.ONE * 0.5)
	var multiplier := sqrt((size.x + size.y) * 0.5) * 1.25
	building_particles.position = get_building_center(coords, building_type)
	particles_material.emission_sphere_radius = size.length() / 2
	building_particles.amount = particles_amount * multiplier
	particles_material.scale_min = particles_scale * multiplier
	particles_material.scale_max = particles_scale * multiplier
	particles_material.initial_velocity_min = particles_velocity * multiplier
	particles_material.initial_velocity_max = particles_velocity * multiplier
	particles_material.linear_accel_min = particles_accel * multiplier
	particles_material.linear_accel_max = particles_accel * multiplier
	building_particles.restart()


func place_building(coords: Vector2i, building_type: BuildingType) -> Placement:
	# Prevent placement if building overlaps any existing buildings
	for building_coords in building_type.get_cells(coords):
		if not is_open(building_coords):
			return null

	# Give GP based on nearby buildings
	var building_value := get_building_value(coords, building_type)
	var gp_change: int = building_value[0]
	var vp_change: int = building_value[1]

	# Check if the additional GP from interactions would lead to negative GP
	if gp + gp_change < 0:
		return null

	var building := Building.new()
	building.type = building_type
	building.coords = coords

	for building_coords in building_type.get_cells(coords):
		building_map[building_coords] = building
		# Hide the empty tiles behind the building by setting them to invalid
		super.set_cell(building_coords, -1)

	var neighbor_groups: Array[int] = []
	# Assumes all tiles are groupable with tiles of the same type
	if building_type.is_tile:
		for neighbor_coords in get_orthogonal(coords):
			var neighbor_building := get_building(neighbor_coords)
			if neighbor_building != null and neighbor_building.type == building_type:
				neighbor_groups.append(get_root_group(get_group(neighbor_coords)))
		# If no neighboring groups exist, make a new group
		if len(neighbor_groups) == 0:
			building.group = group_index
			group_joins.append(group_index)
			adjacent_buildings.append([])
			group_index += 1
		# If there's exactly one neighboring group, use that
		elif len(neighbor_groups) == 1:
			building.group = neighbor_groups[0]
		# If this tile bridges more than one group, join them all
		else:
			var joined_group: int = neighbor_groups.min()
			for group in neighbor_groups:
				group_joins[group] = joined_group
			building.group = joined_group

		# Update the list of buildings adjacent to the group
		adjacent_buildings[building.group] = get_adjacent_buildings(coords)
	else:
		# Update all adjacency lists to include this building
		building.group = INVALID_GROUP
		var adjacent_groups: Array[int] = []
		for adjacent_coords in building_type.get_adjacent_cells(coords):
			if not is_in_bounds(adjacent_coords):
				continue
			var group := get_root_group(get_group(adjacent_coords))
			if group >= 0 and not group in adjacent_groups:
				adjacent_groups.append(group)
				adjacent_buildings[group].append(building)

	# Update autotiling (assumes all tiles are terrains)
	if building_type.is_tile:
		super.set_cells_terrain_connect(
			[coords],
			building_type.terrain_set,
			building_type.terrain,
		)
	# Instance a new Building scene
	else:
		var building_sprite: BuildingSprite = building_sprite_scene.instantiate()
		building_sprite.building = building
		building_sprite.position = get_building_center(coords, building_type)
		buildings_node.add_child(building_sprite)
		building.sprite = building_sprite

	building_place_sound.play()
	emit_particles(coords, building_type)

	var placement := Placement.new()
	placement.building = building
	placement.gp_change = gp_change
	placement.vp_change = vp_change
	placement.group_joins = neighbor_groups
	return placement


func destroy_building(building: Building) -> void:
	building_destroy_sound.play()
	emit_particles(building.coords, building.type)

	# Reset all cells (in the world map and groups) occupied by this building
	# Does NOT modify the group_joins array; currently handled by the undo code
	for building_coords in building.type.get_cells(building.coords):
		building_map.erase(building_coords)
		super.set_cell(building_coords, 0, CityMap.EMPTY_COORDS)

	# Update the autotiling of all surrounding tiles, as it's not done automatically
	if building.type.is_tile:
		for orthogonal_coords in get_orthogonal(building.coords):
			var orthogonal_building := get_building(orthogonal_coords)
			if orthogonal_building != null and orthogonal_building.type.is_tile:
				# Delete and recreate surrounding terrains to force them to refresh
				# Only calling set_cells_terrain_connect is insufficient
				super.set_cell(orthogonal_coords, 0, CityMap.EMPTY_COORDS)
				super.set_cells_terrain_connect(
					[orthogonal_coords],
					orthogonal_building.type.terrain_set,
					orthogonal_building.type.terrain,
				)

	var adjacent_groups: Array[int] = []
	for adjacent_coords in building.type.get_adjacent_cells(building.coords):
		var group := get_root_group(get_group(adjacent_coords))
		if group >= 0 and not group in adjacent_groups:
			if building.type.is_tile:
				adjacent_buildings[group] = get_adjacent_buildings(adjacent_coords)
			else:
				adjacent_buildings[group].erase(building)

	if building.sprite != null:
		building.sprite.destroy()


func _on_palette_building_selected(building_type: BuildingType) -> void:
	select_building_type(building_type)


func _on_input_repeat_timer_timeout() -> void:
	if (
		Input.is_action_pressed(action_to_repeat)
		and handle_action(action_to_repeat)
	):
		var wait_time_delta := absf(
			(final_wait_time - initial_wait_time)
			/ actions_until_final_wait_time,
		)
		var new_wait_time := move_toward(
			input_repeat_timer.wait_time,
			final_wait_time,
			wait_time_delta,
		)
		input_repeat_timer.start(new_wait_time)


func _on_camera_zoom_changed() -> void:
	mouse_dirty = true


func _on_camera_2d_position_changed() -> void:
	mouse_dirty = true

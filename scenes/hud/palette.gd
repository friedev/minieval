class_name Palette extends Control

signal building_selected(id: int)

const INVALID_BUILDING := -1

@export_group("Internal Nodes")
@export var selection: TileMap
@export var tile_map: TileMap
@export var tooltip: BuildingTooltip

@onready var tooltip_position: Vector2 = self.tooltip.position
var last_tooltip_id := -1


func update_tooltip(id: int, coords: Vector2i) -> void:
	if id == self.last_tooltip_id:
		return

	self.last_tooltip_id = id
	self.tooltip.set_building(id)

	# Do this refresh twice because Godot doesn't wanna refresh it I guess
	for _i in range(2):
		# Hide and re-show the tooltip to force a layout refresh
		# Shrink tooltip to size 0 to force fit-to-content
		self.tooltip.hide()
		self.tooltip.size = Vector2(0, 0)
		self.tooltip.show()

		# Add the horizonal offset corresponding to the hovered tile
		# Move the tooltip strictly above the palette
		self.tooltip.position = self.tooltip_position + Vector2(
			coords.x * 64,
			-self.tooltip.size.y + 32
		)


func _input(event: InputEvent):
	var coords: Vector2i
	var hover := event is InputEventMouseMotion
	var click: bool = event is InputEventMouseButton and event.pressed
	var key = event is InputEventKey and event.pressed

	if hover or click:
		coords = ((event.position - self.global_position) / 64).floor()
	elif key:
		if event.keycode == KEY_0:
			coords = Vector2i(9, 0)
		else:
			coords = Vector2i(event.keycode - KEY_1, 0)
	else:
		return

	var id := self.tile_map.get_cell_source_id(0, coords)
	if id == self.INVALID_BUILDING:
		self.tooltip.visible = false
		return

	# Hack to map nice road icon (21) to actual road ID (2)
	if id == 21:
		id = CityMap.BuildingType.ROAD

	if hover:
		tooltip.show()
		self.update_tooltip(id, coords)
	else:
		self.selection.clear()
		self.selection.set_cell(0, coords, CityMap.BuildingType.SELECTION)
		self.building_selected.emit(id)

class_name Palette extends Control

signal palette_selection(id)

const INVALID_BUILDING := -1

@export var gp_str: String
@export var gp_color: Color
@export var vp_str: String
@export var vp_color: Color
@export var positive_color: Color
@export var negative_color: Color

@export_group("External Nodes")
@export var city_map: CityMap

@export_group("Internal Nodes")
@export var tile_map: TileMap
@export var tooltip: Control
@export var name_label: Label
@export var gp_label: Label
@export var vp_label: Label
@export var interactions_label: RichTextLabel
@export var selection: TileMap

@onready var buildings: Dictionary = self.city_map.BUILDINGS
@onready var building_ids: Array = self.city_map.BUILDINGS.keys()

@onready var tooltip_position: Vector2 = self.tooltip.position
var last_tooltip_id := -1


func _ready():
	self.building_ids.remove_at(self.city_map.EMPTY) # or erase()?
	self.building_ids.sort()


# Returns plaintext string
func push_interaction_value(value: int, type: String, type_color: Color) -> String:
	var length := 0
	var string: String
	if value > 0:
		self.interactions_label.push_color(self.positive_color)
		string = "+%d" % value
	else:
		self.interactions_label.push_color(self.negative_color)
		string = "%d" % value
	self.interactions_label.add_text(string)
	self.interactions_label.pop()

	self.interactions_label.add_text(" ")
	string += " "

	self.interactions_label.push_color(type_color)
	self.interactions_label.add_text(type)
	string += type
	self.interactions_label.pop()

	return string


# Returns plaintext string
func push_interaction(building_str: String, gp: int, vp: int) -> String:
	var string: String = "%s: " % building_str
	self.interactions_label.add_text(string)

	if gp != 0:
		string += self.push_interaction_value(gp, self.gp_str, self.gp_color)

	if vp != 0:
		if gp != 0:
			self.interactions_label.add_text(", ")
			string += ", "

		string += self.push_interaction_value(vp, self.vp_str, self.vp_color)

	return string


# Returns array of plaintext strings
func push_all_interactions(id: int) -> Array:
	var building = self.buildings[id]
	if id == self.city_map.PYRAMID:
		# Hack to avoid printing a line for every pyramid interaction
		return [
			self.push_interaction(
				"ANY",
				building.gp_interactions[self.city_map.HOUSE],
				building.vp_interactions[self.city_map.HOUSE]
			)
		]

	var first := true
	var lines := []
	for other_id in self.building_ids:
		var gp: int = building.gp_interactions.get(other_id, 0)
		var vp: int = building.vp_interactions.get(other_id, 0)
		if gp == 0 and vp == 0:
			continue

		if first:
			first = false
		else:
			self.interactions_label.newline()

		lines.append(self.push_interaction(self.buildings[other_id].name, gp, vp))
	return lines


func max_line_width(lines: Array) -> float:
	var max_width := 0.0
	for line in lines:
		var width: float = self.interactions_label.get_theme_font(&"normal_font").get_string_size(line).x
		if width > max_width:
			max_width = width
	return max_width


func update_tooltip(id: int) -> void:
	var building = self.buildings[id]
	self.name_label.text = building.name
	self.gp_label.text = str(-building.gp)
	self.vp_label.text = str(building.vp)
	self.interactions_label.clear()
	var lines := self.push_all_interactions(id)
	if len(lines) > 0:
		self.interactions_label.show()
		# Dynamically resize interactions_label
		# RichTextLabel does not have fit_content_width or get_content_width()
		# Instead, determine the length of the string (in plain text) in the chosen font
		self.interactions_label.custom_minimum_size.x = self.max_line_width(lines)
	else:
		self.interactions_label.hide()


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
		id = self.city_map.ROAD

	if hover:
		tooltip.show()
		if id == self.last_tooltip_id:
			return
		self.last_tooltip_id = id
		self.update_tooltip(id)

		# Do this refresh twice because Godot doesn't wanna refresh it I guess
		for _i in range(2):
			# Hide and re-show the tooltip to force a layout refresh
			# Shrink tooltip to size 0 to force fit-to-content
			self.tooltip.hide()
			self.tooltip.size = Vector2(0, 0)
			self.tooltip.show()

			# Add the horizonal offset corresponding to the hovered tile
			# Move the tooltip strictly above the palette
			self.tooltip.position = self.tooltip_position + Vector2(coords.x * 64, -self.tooltip.size.y + 32)
	else:
		self.selection.clear()
		self.selection.set_cell(0, coords, self.city_map.SELECTION)
		self.palette_selection.emit(id)

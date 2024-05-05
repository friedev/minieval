extends TileMap

signal palette_selection(id)

const INVALID_CELL := -1

const GP_STR := "GP"
const GP_COLOR := Color(1.0, 0.75, 0.0)
const VP_STR := "VP"
const VP_COLOR := Color(0.0, 0.75, 1.0)
const POSITIVE_COLOR := Color(0.0, 1.0, 0.0)
const NEGATIVE_COLOR := Color(1.0, 0.0, 0.0)

@onready var tooltip := get_node("../Tooltip")
@onready var name_label := tooltip.get_node("VBoxContainer/NameLabel")
@onready var gp_label := tooltip.get_node("VBoxContainer/GPContainer/GPLabel")
@onready var vp_label := tooltip.get_node("VBoxContainer/VPContainer/VPLabel")
@onready var interactions_label: RichTextLabel = tooltip.get_node("VBoxContainer/InteractionsLabel")
@onready var selection := get_node("../Selection")
@onready var tile_map := get_node("/root/Main/TileMap")
@onready var buildings: Dictionary = tile_map.BUILDINGS
@onready var building_ids: Array = tile_map.BUILDINGS.keys()

@onready var tooltip_position: Vector2 = tooltip.position
var last_tooltip_id := -1


func _ready():
	building_ids.remove_at(tile_map.EMPTY) # or erase()?
	building_ids.sort()


# Returns plaintext string
func push_interaction_value(value: int, type: String, type_color: Color) -> String:
	var length := 0
	var string: String
	if value > 0:
		interactions_label.push_color(POSITIVE_COLOR)
		string = "+%d" % value
	else:
		interactions_label.push_color(NEGATIVE_COLOR)
		string = "%d" % value
	interactions_label.add_text(string)
	interactions_label.pop()

	interactions_label.add_text(" ")
	string += " "

	interactions_label.push_color(type_color)
	interactions_label.add_text(type)
	string += type
	interactions_label.pop()

	return string


# Returns plaintext string
func push_interaction(building_str: String, gp: int, vp: int) -> String:
	var string: String = "%s: " % building_str
	interactions_label.add_text(string)

	if gp != 0:
		string += push_interaction_value(gp, GP_STR, GP_COLOR)

	if vp != 0:
		if gp != 0:
			interactions_label.add_text(", ")
			string += ", "

		string += push_interaction_value(vp, VP_STR, VP_COLOR)

	return string


# Returns array of plaintext strings
func push_all_interactions(id: int) -> Array:
	var building = buildings[id]
	if id == tile_map.PYRAMID:
		# Hack to avoid printing a line for every pyramid interaction
		return [
			push_interaction(
				"ANY",
				building.gp_interactions[tile_map.HOUSE],
				building.vp_interactions[tile_map.HOUSE]
			)
		]

	var first := true
	var lines := []
	for other_id in building_ids:
		var gp: int = building.gp_interactions.get(other_id, 0)
		var vp: int = building.vp_interactions.get(other_id, 0)
		if gp == 0 and vp == 0:
			continue

		if first:
			first = false
		else:
			interactions_label.newline()

		lines.append(push_interaction(buildings[other_id].name, gp, vp))
	return lines


func max_line_width(lines: Array) -> float:
	return 64.0
#	var max_width := 0.0
#	for line in lines:
#		var width: float = interactions_label.get_font("normal_font").get_string_size(line).x
#		if width > max_width:
#			max_width = width
#	return max_width


func update_tooltip(id: int) -> void:
	var building = buildings[id]
	name_label.text = building.name
	gp_label.text = str(-building.gp)
	vp_label.text = str(building.vp)
	interactions_label.clear()
	var lines := push_all_interactions(id)
	if len(lines) > 0:
		interactions_label.show()
		# Dynamically resize interactions_label
		# RichTextLabel does not have fit_content_width or get_content_width()
		# Instead, determine the length of the string (in plain text) in the chosen font
		interactions_label.custom_minimum_size.x = max_line_width(lines)
	else:
		interactions_label.hide()


func _input(event: InputEvent):
	var cellv: Vector2i
	var hover := event is InputEventMouseMotion
	var click: bool = event is InputEventMouseButton and event.pressed
	var key = event is InputEventKey and event.pressed

	if hover or click:
		cellv = ((event.position - self.global_position) / 64).floor()
	elif key:
		if event.keycode == KEY_0:
			cellv = Vector2i(9, 0)
		else:
			cellv = Vector2i(event.keycode - KEY_1, 0)
	else:
		return

	var id := self.get_cell_source_id(0, cellv)
	if id == INVALID_CELL:
		tooltip.visible = false
		return

	# Hack to map nice road icon (21) to actual road ID (2)
	if id == 21:
		id = tile_map.ROAD

	if hover:
		tooltip.visible = true
		if id == last_tooltip_id:
			return
		# Hide and re-show the tooltip to force a layout refresh
		tooltip.hide()
		last_tooltip_id = id
		# Add the horizonal offset corresponding to the hovered tile
		# Add to y to fine-tune the vertical offset
		tooltip.position = tooltip_position + Vector2(cellv.x * 64, 16)
		# Shrink tooltip to size 0 to force fit-to-content
		tooltip.size = Vector2(0, 0)
		update_tooltip(id)
		tooltip.show()
	else:
		selection.clear()
		selection.set_cell(0, cellv, tile_map.SELECTION)
		emit_signal("palette_selection", id)

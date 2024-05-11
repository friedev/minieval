class_name BuildingTooltip extends Control

@export var gp_str: String
@export var gp_color: Color
@export var vp_str: String
@export var vp_color: Color
@export var positive_color: Color
@export var negative_color: Color

@export_group("Internal Nodes")
@export var name_label: Label
@export var gp_label: Label
@export var vp_label: Label
@export var interactions_label: RichTextLabel

@onready var buildings: Dictionary = CityMap.BUILDINGS
@onready var building_ids: Array = self.buildings.keys()


func _ready():
	self.building_ids.remove_at(CityMap.BuildingType.EMPTY) # or erase()?
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
func push_all_interactions(id: int) -> Array[String]:
	var building = self.buildings[id]
	if id == CityMap.BuildingType.PYRAMID:
		# Hack to avoid printing a line for every pyramid interaction
		return [
			self.push_interaction(
				"ANY",
				building.gp_interactions[CityMap.BuildingType.HOUSE],
				building.vp_interactions[CityMap.BuildingType.HOUSE]
			)
		]

	var first := true
	var lines: Array[String] = []
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
		var width: float = (
			self.interactions_label.get_theme_font(&"normal_font").get_string_size(line).x
		)
		if width > max_width:
			max_width = width
	return max_width


func set_building(id: int) -> void:
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

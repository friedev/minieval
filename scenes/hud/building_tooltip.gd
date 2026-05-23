class_name BuildingTooltip
extends Control

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


# Returns plaintext string
func push_interaction_value(value: int, type: String, type_color: Color) -> String:
	var length := 0
	var string: String
	if value > 0:
		interactions_label.push_color(positive_color)
		string = "+%d" % value
	else:
		interactions_label.push_color(negative_color)
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
		string += push_interaction_value(gp, gp_str, gp_color)

	if vp != 0:
		if gp != 0:
			interactions_label.add_text(", ")
			string += ", "

		string += push_interaction_value(vp, vp_str, vp_color)

	return string


# Returns array of plaintext strings
func push_all_interactions(building_type: BuildingType) -> Array[String]:
	if building_type.key == &"pyramid":
		# Hack to avoid printing a line for every pyramid interaction
		return [
			push_interaction(
				"ANY",
				building_type.gp_interactions[&"pyramid"],
				building_type.vp_interactions[&"pyramid"],
			),
		]

	var first := true
	var lines: Array[String] = []
	for other_building_type_key in Global.building_types:
		var other_building_type: BuildingType = Global.building_types[other_building_type_key]
		var gp: int = building_type.gp_interactions.get(other_building_type_key, 0)
		var vp: int = building_type.vp_interactions.get(other_building_type_key, 0)
		if gp == 0 and vp == 0:
			continue

		if first:
			first = false
		else:
			interactions_label.newline()

		lines.append(push_interaction(other_building_type.display_name, gp, vp))
	return lines


func max_line_width(lines: Array) -> float:
	var max_width := 0.0
	for line in lines:
		var width: float = (
			interactions_label.get_theme_font(&"normal_font").get_string_size(line).x
		)
		if width > max_width:
			max_width = width
	return max_width


func set_building_type(building_type: BuildingType) -> void:
	name_label.text = building_type.display_name
	gp_label.text = str(-building_type.gp)
	vp_label.text = str(building_type.vp)
	interactions_label.clear()
	var lines := push_all_interactions(building_type)
	if len(lines) > 0:
		interactions_label.show()
		# Dynamically resize interactions_label
		# RichTextLabel does not have fit_content_width or get_content_width()
		# Instead, determine the length of the string (in plain text) in the chosen font
		interactions_label.custom_minimum_size.x = max_line_width(lines)
	else:
		interactions_label.hide()

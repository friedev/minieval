extends TileMap

signal palette_selection(id)

onready var tooltip := get_node("../Tooltip")
onready var name_label := tooltip.get_node("VBoxContainer/NameLabel")
onready var gp_label := tooltip.get_node("VBoxContainer/GPContainer/GPLabel")
onready var vp_label := tooltip.get_node("VBoxContainer/VPContainer/VPLabel")
onready var interactions_label := tooltip.get_node("VBoxContainer/InteractionsLabel")
onready var tile_map := get_node("/root/Root/TileMap")
onready var buildings: Dictionary = tile_map.BUILDINGS
onready var building_ids: Array = tile_map.BUILDINGS.keys()

onready var tooltip_position: Vector2 = tooltip.rect_position
var last_tooltip_id := -1


func _ready():
	building_ids.remove(tile_map.EMPTY)
	building_ids.sort()


func get_interaction_str(value: int, resource: String) -> String:
	var value_str: String = ("+%d" if value > 0 else "%d") % value
	return "%s %s" % [value_str, resource]


func get_interactions_str(id: int, gp: int, vp: int) -> String:
	var building = buildings[id]
	var interaction_strings := []
	if gp != 0:
		interaction_strings.append(get_interaction_str(gp, "GP"))
	if vp != 0:
		interaction_strings.append(get_interaction_str(vp, "VP"))
	var interactions_string := ", ".join(interaction_strings)
	return "%s: %s\n" % [building.name, interactions_string]


func get_interactions_text(building) -> String:
	var interactions_text := ""
	for other_id in building_ids:
		var gp: int = building.gp_interactions.get(other_id, 0)
		var vp: int = building.vp_interactions.get(other_id, 0)
		if gp == 0 and vp == 0:
			continue
		interactions_text += get_interactions_str(other_id, gp, vp)
	return interactions_text.rstrip("\n")


func update_tooltip(id: int) -> void:
	var building = buildings[id]
	name_label.text = building.name
	gp_label.text = str(-building.gp)
	vp_label.text = str(building.vp)
	var interactions_text: String
	if id == tile_map.PYRAMID:
		# Hack to avoid printing a line for every pyramid interaction
		interactions_text = "ANY: %s, %s" % [
			get_interaction_str(building.gp_interactions[tile_map.HOUSE], "GP"),
			get_interaction_str(building.vp_interactions[tile_map.HOUSE], "VP"),
		]
	else:
		interactions_text = get_interactions_text(building)
	interactions_label.text = interactions_text
	interactions_label.visible = len(interactions_text) > 0


func _input(event: InputEvent):
	var cellv: Vector2
	var hover := event is InputEventMouseMotion
	var click: bool = event is InputEventMouseButton and event.pressed
	var key = event is InputEventKey and event.pressed

	if hover or click:
		cellv = ((event.position - self.global_position) / 64).floor()
	elif key:
		if event.scancode == KEY_0:
			cellv = Vector2(9, 0)
		else:
			cellv = Vector2(event.scancode - KEY_1, 0)
	else:
		return

	var id := self.get_cellv(cellv)
	if id == INVALID_CELL:
		tooltip.visible = false
		return

	# Hack to map nice road icon (21) to actual road ID (2)
	if id == 21:
		id = 2

	if hover:
		tooltip.visible = true
		if id == last_tooltip_id:
			return
		# Hide and re-show the tooltip to force a layout refresh
		tooltip.hide()
		last_tooltip_id = id
		tooltip.rect_position = tooltip_position + Vector2(cellv.x * 64, 0)
		tooltip.rect_size = Vector2(0, 0)
		update_tooltip(id)
		tooltip.show()
	else:
		emit_signal("palette_selection", id)

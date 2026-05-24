class_name Palette
extends Control

signal building_selected(building_type: BuildingType)

@export_group("Internal Nodes")
@export var icon_container: Control
@export var tooltip: BuildingTooltip

var last_tooltip_building_type: BuildingType = null
var current_selection: PaletteIcon = null


func update_tooltip(icon: PaletteIcon) -> void:
	if icon.building_type == last_tooltip_building_type:
		return

	last_tooltip_building_type = icon.building_type
	tooltip.set_building_type(icon.building_type)

	# Do this refresh twice because Godot doesn't wanna refresh it I guess
	for _i in range(2):
		# Hide and re-show the tooltip to force a layout refresh
		# Shrink tooltip to size 0 to force fit-to-content
		tooltip.hide()
		tooltip.size = Vector2(0, 0)
		tooltip.show()

		# Align the tooltip with the hovered icon
		tooltip.global_position = icon.global_position
		# Center the tooltip horizontally
		tooltip.position.x += icon.size.x / 2 - tooltip.size.x / 2
		# Move the tooltip strictly above the palette
		tooltip.position.y -= tooltip.size.y + 16


func _input(event: InputEvent):
	if event.is_action_pressed(&"select_next_building_type"):
		select_icon_by_relative_index(+1)
	elif event.is_action_pressed(&"select_previous_building_type"):
		select_icon_by_relative_index(-1)
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		var icon_index: int
		if key_event.keycode == KEY_0:
			icon_index = 9
		else:
			icon_index = key_event.keycode - KEY_1
		if icon_index >= 0 and icon_index < icon_container.get_child_count():
			select_icon_by_index(icon_index)


func select_icon_by_relative_index(relative_index: int) -> void:
	var current_index := current_selection.get_index()
	var absolute_index := wrapi(
		current_index + relative_index,
		0,
		icon_container.get_child_count(),
	)
	select_icon_by_index(absolute_index)


func select_icon_by_index(index: int) -> void:
	var icon := icon_container.get_child(index) as PaletteIcon
	select_icon(icon)


func select_icon(icon: PaletteIcon) -> void:
	if current_selection == icon:
		return
	if current_selection != null:
		current_selection.set_selected(false)
	current_selection = icon
	current_selection.set_selected(true)
	building_selected.emit(icon.building_type)


func _on_palette_icon_clicked(icon: PaletteIcon) -> void:
	select_icon(icon)


func _on_palette_icon_hovered(icon: PaletteIcon) -> void:
	tooltip.show()
	update_tooltip(icon)


func _on_palette_icon_unhovered(icon: PaletteIcon) -> void:
	tooltip.hide()

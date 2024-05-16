class_name Palette extends Control

signal building_selected(building_type: BuildingType)

@export_group("Internal Nodes")
@export var icon_container: Control
@export var tooltip: BuildingTooltip

var last_tooltip_building_type: BuildingType = null
var current_selection: PaletteIcon = null


func update_tooltip(icon: PaletteIcon) -> void:
	if icon.building_type == self.last_tooltip_building_type:
		return

	self.last_tooltip_building_type = icon.building_type
	self.tooltip.set_building_type(icon.building_type)

	# Do this refresh twice because Godot doesn't wanna refresh it I guess
	for _i in range(2):
		# Hide and re-show the tooltip to force a layout refresh
		# Shrink tooltip to size 0 to force fit-to-content
		self.tooltip.hide()
		self.tooltip.size = Vector2(0, 0)
		self.tooltip.show()

		# Align the tooltip with the hovered icon
		self.tooltip.global_position = icon.global_position
		# Center the tooltip horizontally
		self.tooltip.position.x += icon.size.x / 2 - self.tooltip.size.x / 2
		# Move the tooltip strictly above the palette
		self.tooltip.position.y -= self.tooltip.size.y + 16


func _input(event: InputEvent):
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var icon_index: int
		if key_event.keycode == KEY_0:
			icon_index = 9
		else:
			icon_index = key_event.keycode - KEY_1
		if icon_index >= 0 and icon_index < self.icon_container.get_child_count():
			var icon := self.icon_container.get_child(icon_index) as PaletteIcon
			self.select_icon(icon)


func select_icon(icon: PaletteIcon) -> void:
	if self.current_selection == icon:
		return
	if self.current_selection != null:
		self.current_selection.set_selected(false)
	self.current_selection = icon
	self.current_selection.set_selected(true)
	self.building_selected.emit(icon.building_type)


func _on_palette_icon_clicked(icon: PaletteIcon) -> void:
	self.select_icon(icon)


func _on_palette_icon_hovered(icon: PaletteIcon) -> void:
	self.tooltip.show()
	self.update_tooltip(icon)


func _on_palette_icon_unhovered(icon: PaletteIcon) -> void:
	self.tooltip.hide()

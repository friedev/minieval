class_name PaletteIcon extends Control

signal clicked(icon: PaletteIcon)
signal hovered(icon: PaletteIcon)
signal unhovered(icon: PaletteIcon)

@export var building: CityMap.BuildingType
@export var initially_selected: bool

@export_group("Internal Nodes")
@export var selected_texture_rect: TextureRect


func _ready() -> void:
	if self.initially_selected:
		self.clicked.emit(self)


func set_selected(is_selected: bool) -> void:
	self.selected_texture_rect.visible = is_selected


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			self.clicked.emit(self)
			self.accept_event()


func _on_mouse_entered() -> void:
	self.hovered.emit(self)


func _on_mouse_exited() -> void:
	self.unhovered.emit(self)

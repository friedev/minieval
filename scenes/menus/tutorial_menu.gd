class_name TutorialMenu extends Control

@export_group("External Nodes")
@export var city_map: CityMap
@export var pause: PauseMenu
@export var black_overlay: ColorRect


func _ready() -> void:
	if Global.tutorial_seen:
		self.close_tutorial()
	else:
		self.open_tutorial()


func open_tutorial() -> void:
	self.pause.set_process_input(false)
	self.show.call_deferred()


func close_tutorial() -> void:
	self.hide()
	self.pause.set_process_input(true)
	Global.tutorial_seen = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		self.close_tutorial()


func _on_Tutorial_visibility_changed() -> void:
	if self.black_overlay != null:
		self.black_overlay.visible = self.visible
	if self.city_map != null:
		self.city_map.in_menu = self.visible


func _on_play_button_pressed() -> void:
	self.close_tutorial()

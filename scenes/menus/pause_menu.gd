# This node needs to be placed below other menu nodes in the scene tree so that
# it handles the pause input action before other menus handle it as ui_cancel.
class_name PauseMenu extends Menu

signal options_pressed(previous: Menu)
signal tutorial_pressed(previous: Menu)

@export_file("*.tscn") var title_scene: String


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if not Global.is_menu_open:
			self.open()
			return
	super._input(event)


func _on_main_menu_button_pressed() -> void:
	Global.change_scene_to_file(self.title_scene)


func _on_options_button_pressed() -> void:
	self.hide()
	self.options_pressed.emit(self)


func _on_tutorial_button_pressed() -> void:
	self.hide()
	self.tutorial_pressed.emit(self)

class_name MainMenu extends Menu

signal custom_game_pressed(previous: Menu)
signal options_pressed(previous: Menu)
signal credits_pressed(previous: Menu)

@export_file("*.tscn") var main_scene: String

@export_group("Internal Nodes")
@export var quit_button: Button


func _ready() -> void:
	self.quit_button.visible = OS.get_name() != "Web"
	self.open()


func _on_play_button_pressed() -> void:
	Global.reset_game_parameters()
	Global.change_scene_to_file(self.main_scene)


func _on_custom_game_button_pressed() -> void:
	self.hide()
	self.custom_game_pressed.emit(self)


func _on_options_button_pressed() -> void:
	self.hide()
	self.options_pressed.emit(self)


func _on_credits_button_pressed() -> void:
	self.hide()
	self.credits_pressed.emit(self)


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()

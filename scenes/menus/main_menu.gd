class_name MainMenu extends Control

signal custom_game_menu_opened
signal options_menu_opened

@export_file("*.tscn") var main_scene: String

@export_group("Internal Nodes")
@export var quit_button: Button


func _ready() -> void:
	self.quit_button.visible = OS.get_name() != "HTML5"
	self.show.call_deferred()


func _on_play_button_pressed() -> void:
	Global.reset_game_parameters()
	self.get_tree().change_scene_to_file(self.main_scene)


func _on_custom_game_button_pressed() -> void:
	self.hide()
	self.custom_game_menu_opened.emit()


func _on_options_button_pressed() -> void:
	self.hide()
	self.options_menu_opened.emit()


func _on_options_menu_closed() -> void:
	self.show()


func _on_custom_game_ui_menu_closed() -> void:
	self.show()


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()

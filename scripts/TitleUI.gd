extends Popup

const main_scene := "res://scenes/Main.tscn"

onready var title := self.get_node("/root/Title")
onready var options_menu := self.title.find_node("Options")
onready var custom_game_ui := self.title.find_node("CustomGameUI")
onready var exit_game_button := self.find_node("ExitGameButton")


func _ready() -> void:
	if not TitleMusic.playing:
		TitleMusic.play()
	self.exit_game_button.visible = OS.get_name() != "HTML5"
	self.call_deferred("popup")


func _on_PlayButton_pressed() -> void:
	Global.reset_game_parameters()
	get_tree().change_scene(main_scene)


func _on_CustomGameButton_pressed() -> void:
	self.hide()
	self.custom_game_ui.popup()


func _on_OptionsButton_pressed() -> void:
	self.hide()
	self.options_menu.popup()


func _on_ExitGameButton_pressed() -> void:
	get_tree().quit()

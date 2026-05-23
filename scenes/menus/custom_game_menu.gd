class_name CustomGameMenu
extends Menu

@export_file("*.tscn") var main_scene: String

@export_group("Internal Nodes")
@export var turn_limit_line_edit: LineEdit
@export var game_size_line_edit: LineEdit

@onready var old_turn_limit: String = turn_limit_line_edit.text
@onready var old_game_size: String = game_size_line_edit.text


func _on_turn_limit_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if str(int(new_text)) != new_text or int(new_text) <= 0:
		turn_limit_line_edit.text = old_turn_limit
	else:
		old_turn_limit = new_text


func _on_map_size_line_edit_text_changed(new_text: String) -> void:
	if new_text == "" or str(int(new_text)) != new_text or int(new_text) < 0:
		game_size_line_edit.text = old_game_size
	else:
		old_game_size = new_text


func _on_play_button_pressed() -> void:
	if turn_limit_line_edit.text == "":
		Global.num_turns = 0
		Global.endless = true
	else:
		Global.num_turns = int(turn_limit_line_edit.text)
		Global.endless = false

	Global.game_size = int(game_size_line_edit.text)
	Global.change_scene_to_file(main_scene)

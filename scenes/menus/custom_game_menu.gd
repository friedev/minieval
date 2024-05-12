class_name CustomGameMenu extends Menu

@export_file("*.tscn") var main_scene: String

@onready var turn_limit := %TurnLimitLineEdit
@onready var game_size := %MapSizeLineEdit

@onready var old_turn_limit: String = turn_limit.text
@onready var old_game_size: String = game_size.text


func _on_turn_limit_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if str(int(new_text)) != new_text or int(new_text) <= 0:
		self.turn_limit.text = self.old_turn_limit
	else:
		self.old_turn_limit = new_text


func _on_map_size_line_edit_text_changed(new_text: String) -> void:
	if new_text == "" or str(int(new_text)) != new_text or int(new_text) < 0:
		self.game_size.text = self.old_game_size
	else:
		self.old_game_size = new_text


func _on_play_button_pressed() -> void:
	if self.turn_limit.text == "":
		Global.num_turns = 0
		Global.endless = true
	else:
		Global.num_turns = int(self.turn_limit.text)
		Global.endless = false

	Global.game_size = int(self.game_size.text)
	Global.change_scene_to_file(self.main_scene)

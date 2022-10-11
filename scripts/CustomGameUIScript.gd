extends Panel

onready var turn_limit := $TurnLimitInput
onready var game_size := $GameSizeInput

onready var old_turn_limit: String = turn_limit.text
onready var old_game_size: String = game_size.text

const title_scene := "res://scenes/Title.tscn"


func _on_BackToChooseModeButton_pressed() -> void:
	get_tree().change_scene(title_scene)


func _on_PlayButton_pressed() -> void:
	if turn_limit.text == '':
		Global.num_turns = 0
		Global.endless = true
	else:
		Global.num_turns = int(turn_limit.text)
		Global.endless = false

	Global.game_size = int(game_size.text)
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_TurnLimitInput_text_changed(new_text) -> void:
	if new_text == '':
		return
	if str(int(new_text)) != new_text or int(new_text) <= 0:
		turn_limit.text = old_turn_limit
	else:
		old_turn_limit = new_text


func _on_MapSizeInput_text_changed(new_text) -> void:
	if not new_text or str(int(new_text)) != new_text or int(new_text) < 0:
		game_size.text = old_game_size
	else:
		old_game_size = new_text

extends Panel

onready var turn_limit = $TurnLimitInput
onready var time_limit = $TimeLimitInput
onready var game_size = $GameSizeInput
onready var creative_mode = $CreativeMode

onready var old_turn_limit = turn_limit.text
onready var old_time_limit = time_limit.text
onready var old_game_size = game_size.text


func _on_BackToChooseModeButton_pressed():
	get_tree().change_scene("res://scenes/Title.tscn")


func _on_PlayButton_pressed():
	if turn_limit.text == '':
		Global.num_turns = 0
	else:
		Global.num_turns = int(turn_limit.text)
		Global.game_mode = 0

	if time_limit.text == '':
		Global.game_time = 0
	else:
		Global.num_turns = 0
		Global.game_time = int(time_limit.text)
		Global.game_mode = 1

	if creative_mode.pressed:
		Global.game_mode = 3
	elif turn_limit.text == '' and time_limit.text == '':
		Global.game_mode = 2

	Global.game_size = int(game_size.text)
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_TurnLimitInput_text_changed(new_text):
	if new_text == '':
		return
	if str(int(new_text)) != new_text or int(new_text) <= 0:
		turn_limit.text = old_turn_limit
	else:
		old_turn_limit = new_text


func _on_TimeLimitInput_text_changed(new_text):
	if new_text == '':
		return
	if str(int(new_text)) != new_text or int(new_text) <= 0:
		time_limit.text = old_time_limit
	else:
		old_time_limit = new_text


func _on_MapSizeInput_text_changed(new_text):
	if not new_text or str(int(new_text)) != new_text or int(new_text) < 0:
		game_size.text = old_game_size
	else:
		old_game_size = new_text

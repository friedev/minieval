extends Popup

const main_scene := "res://scenes/Main.tscn"

onready var title := self.get_node("/root/Title")
onready var title_ui := self.title.find_node("TitleUI")

onready var turn_limit := self.find_node("TurnLimitLineEdit")
onready var game_size := self.find_node("MapSizeLineEdit")

onready var old_turn_limit: String = turn_limit.text
onready var old_game_size: String = game_size.text


func _go_back() -> void:
	self.hide()
	self.title_ui.popup()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self._go_back()


func _on_BackToChooseModeButton_pressed() -> void:
	self._go_back()


func _on_PlayButton_pressed() -> void:
	if turn_limit.text == '':
		Global.num_turns = 0
		Global.endless = true
	else:
		Global.num_turns = int(turn_limit.text)
		Global.endless = false

	Global.game_size = int(game_size.text)
	get_tree().change_scene(main_scene)


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

extends Panel

#Use tilemap node for variables

func _on_BackToChooseModeButton_pressed():
	get_tree().change_scene("res://Interface/NewGameUI.tscn")


func _on_50TurnsButton_pressed():
	Global.num_turns = 50
	var turns50button = get_node(@"SelectionContainer/50TurnsButton")
	turns50button.pressed = true


func _on_100TurnsButton_pressed():
	Global.num_turns = 100


func _on_250TurnsButton_pressed():
	Global.num_turns = 250


func _on_32x32SizeButton_pressed():
	Global.game_size = 32


func _on_64x64SizeButton_pressed():
	Global.game_size = 64


func _on_128x128SizeButton_pressed():
	Global.game_size = 128


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Main.tscn")

extends Panel

onready var size32 = get_node(@"SelectionContainer/32x32SizeButton")
onready var size64 = get_node(@"SelectionContainer/64x64SizeButton")
onready var size128 = get_node(@"SelectionContainer/128x128SizeButton")

func _ready():
	if Global.game_size == 32:
		size32.pressed = true
	elif Global.game_size == 64:
		size64.pressed = true
	elif Global.game_size == 128:
		size128.pressed = true


func _on_BackToChooseModeButton_pressed():
	get_tree().change_scene("res://Interface/NewGameUI.tscn")


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Main.tscn")


func _on_32x32SizeButton_pressed():
	Global.game_size = 32
	size32.pressed = true
	size64.pressed = false
	size128.pressed = false


func _on_64x64SizeButton_pressed():
	Global.game_size = 64
	size32.pressed = false
	size64.pressed = true
	size128.pressed = false


func _on_128x128SizeButton_pressed():
	Global.game_size = 128
	size32.pressed = false
	size64.pressed = false
	size128.pressed = true



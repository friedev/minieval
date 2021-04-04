extends Panel

onready var size32 = get_node(@"SelectionContainer/32x32SizeButton")
onready var size64 = get_node(@"SelectionContainer/64x64SizeButton")
onready var size128 = get_node(@"SelectionContainer/128x128SizeButton")
onready var turn50 = get_node(@"SelectionContainer/50TurnsButton")
onready var turn100 = get_node(@"SelectionContainer/100TurnsButton")
onready var turn250 = get_node(@"SelectionContainer/250TurnsButton")

func _ready():
	if Global.num_turns == 50:
		turn50.pressed = true
	elif Global.num_turns == 100:
		turn100.pressed = true
	elif Global.num_turns == 250:
		turn250.pressed = true
	
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


func _on_50TurnsButton_pressed():
	Global.num_turns = 50
	turn50.pressed = true
	turn100.pressed = false
	turn250.pressed = false


func _on_100TurnsButton_pressed():
	Global.num_turns = 100
	turn50.pressed = false
	turn100.pressed = true
	turn250.pressed = false


func _on_250TurnsButton_pressed():
	Global.num_turns = 250
	turn50.pressed = false
	turn100.pressed = false
	turn250.pressed = true


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

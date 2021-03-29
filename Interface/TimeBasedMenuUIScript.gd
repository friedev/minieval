extends Panel

onready var size32 = get_node(@"SelectionContainer/32x32SizeButton")
onready var size64 = get_node(@"SelectionContainer/64x64SizeButton")
onready var size128 = get_node(@"SelectionContainer/128x128SizeButton")
onready var minute1 = get_node(@"SelectionContainer/1minButton")
onready var minute5 = get_node(@"SelectionContainer/5minButton")
onready var minute10 = get_node(@"SelectionContainer/10minButton")
onready var minute30 = get_node(@"SelectionContainer/30minButton")

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


func _on_1minButton_pressed():
	Global.game_time = 60
	minute1.pressed = true
	minute5.pressed = false
	minute10.pressed = false
	minute30.pressed = false


func _on_5minButton_pressed():
	Global.game_time = 300
	minute1.pressed = false
	minute5.pressed = true
	minute10.pressed = false
	minute30.pressed = false


func _on_10minButton_pressed():
	Global.game_time = 600
	minute1.pressed = false
	minute5.pressed = false
	minute10.pressed = true
	minute30.pressed = false


func _on_30minButton_pressed():
	Global.game_time = 1800
	minute1.pressed = false
	minute5.pressed = false
	minute10.pressed = false
	minute30.pressed = true



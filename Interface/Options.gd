extends Control






# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.last_scene == "res://Interface/Title.tscn":
		visible = true



func _on_ReturnToGame_pressed():
	if Global.last_scene == "res://Interface/Title.tscn":
		get_tree().change_scene(Global.last_scene)
	visible = false
	
